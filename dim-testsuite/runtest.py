#!/usr/bin/env python
'''
This script will run the tests from the requirements repository (from t/) and
output the result of the run in the same format (into out/).

Usage: ./runtest.py [-x] [<test> ...]

If no tests are specified, all tests found in t/ will be run.

-x will cause the testing to stop at the first failure

-p automatically add zones to a pdns output (for every test where outputs are not used) and compare
   dim and pdns for every zone change (exiting if a difference is detected)
'''


import configparser
import errno
import logging
import os.path
import re
import shlex
import sys
from io import StringIO
from itertools import zip_longest
from subprocess import Popen, PIPE, DEVNULL, STDOUT

from dimcli import CLI, config
from dimclient import DimClient

from tests.pdns_util import diff_files, test_pdns_output_process, setup_pdns_output, compare_dim_pdns_zones


topdir = os.path.dirname(os.path.abspath(__file__))
T_DIR = os.path.join(topdir, 't')
OUT_DIR = os.getenv('TEST_OUTPUT_DIR', os.path.join(topdir, 'out'))
PDNS_ADDRESS = '127.1.1.1'
PDNS_DB_URI = 'mysql://pdns:pdns@127.0.0.1:3307/pdns1'
DIM_MYSQL_OPTIONS = '-h127.0.0.1 -P3307 -udim -pdim dim'
DIM_MYSQL_COMMAND = 'mysql ' + DIM_MYSQL_OPTIONS


server = None
pdns_output_proc = None


class PDNSOutputProcess(object):
    def __init__(self, needed):
        self.needed = needed

    def __enter__(self):
        if self.needed:
            self.proc = test_pdns_output_process(False)
        return self

    def __exit__(self, *args):
        if self.needed:
            self.proc.kill()
            self.proc = None

    def wait_updates(self):
        '''Wait for all updates to be processed'''
        if self.needed:
            while True:
                out = Popen(DIM_MYSQL_COMMAND, shell=True, stdin=PIPE, stdout=PIPE)\
                      .communicate(input='SELECT COUNT(*) FROM outputupdate')[0]
                if int(out.split()[1]) == 0:
                    break
                else:
                    os.read(self.proc.stdout.fileno(), 1024)


def is_ignorable(line: str):
    return len(line.strip()) == 0 or line.startswith(b'#')


def generates_table(line):
    return line.startswith(b'$ ndcli list') or line.startswith(b'$ ndcli dump zone') or line.startswith(b'$ ndcli history')


def generates_map(line):
    return line.startswith(b'$ ndcli show') or line.startswith(b'$ ndcli modify rr') \
        or re.search(b'(get|mark) (ip|delegation)', line) or re.search(b'ndcli create rr .* from', line)


def is_pdns_query(line):
    return any(cmd in line for cmd in (b'dig', b'drill'))


def _ndcli(cmd: str, cmd_input=None):
    proc = Popen(['ndcli' , '-s', 'http://localhost:5000/'] + cmd, stdin=PIPE, stdout=PIPE, stderr=STDOUT)
    out, err = proc.communicate(input=cmd_input if cmd_input != None else None)
    return out


def clean_database():
    commands = [
        'echo "delete from domains; delete from records;" | mysql -h127.0.0.1 -P3307 -updns -ppdns pdns1',
        'echo "delete from domains; delete from records;" | mysql -h127.0.0.1 -P3307 -updns -ppdns pdns2']
    clean_sql = os.path.join(OUT_DIR, 'clean.sql')
    if not hasattr(clean_database, 'dumped'):
        commands.extend([
            "echo 'drop database dim; create database dim;' | " + DIM_MYSQL_COMMAND,
            'manage_db clear',
            'mysqldump ' + DIM_MYSQL_OPTIONS + ' >' + clean_sql])
        clean_database.dumped = True
    else:
        commands.extend([DIM_MYSQL_COMMAND + ' <' + clean_sql])
    if os.system(';'.join(commands)) != 0:
        sys.exit(1)


def run_command(line, cmd_input=None):
    cmd = shlex.split(line[7:].decode('utf-8'))
    out = _ndcli(cmd, cmd_input)
    return out


def run_system_command(*args, **kwargs):
    kwargs.setdefault('shell', True)
    kwargs['close_fds'] = True
    kwargs['stdout'] = PIPE
    kwargs['stderr'] = PIPE
    sp = Popen(*args, **kwargs)
    stdout, stderr = sp.communicate()
    return stdout.splitlines() + stderr.splitlines()


def process_command(actual_output, expected_output, out, sort_before=False):
    passed = True
    if sort_before:
        actual_output.sort()
        expected_output.sort()
    for actual, expected in zip_longest(actual_output, expected_output, fillvalue=''):
        expected = expected.strip('\n')
        if expected.endswith(' re'):
            if re.match(expected[:-3], actual):
                out.write(expected + '\n')
            else:
                out.write(actual + b'\n')
                passed = False
        else:
            out.write(actual + b'\n')
            if (actual != expected):
                passed = False
    return passed


def table_from_lines(lines: list[bytes], cmd: str) -> list[bytes]:
    if generates_map(cmd):
        result = []
        for line in lines:
            if not is_ignorable(line):
                result.append(line.split(b':', 1))
        return result
    elif b' -H' in cmd or b'dump zone' in cmd:
        result = []
        for line in lines:
            if is_ignorable(line):
                continue
            result.append(line.split(b'\t'))
        return result
    else:
        result = []
        while lines and is_ignorable(lines[0]):
            lines.pop(0)
        if not lines:
            return result
        while lines and re.match(b'^(INFO|WARNING)', lines[0]):
            result.append([lines.pop(0)])
        headers = lines[0].split()
        offsets = []
        for header in headers:
            # some headers are substrings of others
            start_find = offsets[-1] + 1 if offsets else 0
            offsets.append(lines[0].find(header, start_find))
        for line in lines:
            if is_ignorable(line):
                continue
            row = [b''] * len(offsets)
            for col, offset in enumerate(offsets):
                if offset < len(line):
                    next_offset = len(line)
                    if col < len(offsets) - 1:
                        next_offset = min(offsets[col + 1], len(line))
                    row[col] = line[offset:next_offset].strip()
            result.append(row)
        return result


def add_regex(table, cmd):
    def check_regexes(table, regexes):
        regexes = [re.compile(r) for r in regexes]
        for row in table:
            for regex in regexes:
                if re.search(regex, row[0]):
                    row[0] = regex
                    break

    if generates_map(cmd):
        for (no, row) in enumerate(table):
            if row[0] in [b'created', b'modified']:
                table[no][1] = re.compile(b'.*')
            elif row[0] in [b'created_by', b'modified_by']:
                table[no][1] = re.compile(b'.*')
    elif generates_table(cmd):
        if re.search(b'list zone .* keys', cmd):
            for row in table:
                row[0] = re.compile(b'.*_[zk]sk_.*')
                row[2] = re.compile(b'\d*')
                row[5] = re.compile(b'.*')
        if re.search(b'list zone .* dnskeys', cmd):
            for row in table:
                row[0] = re.compile(b'\d*')
                row[1] = re.compile(b'\d*')
                row[3] = re.compile(b'.*')
        if re.search(b'list zone .* keys', cmd):
            for row in table:
                row[0] = re.compile(b'.*')
                row[2] = re.compile(b'\d*')
                row[5] = re.compile(b'.*')
        if re.search(b'list zone .* ds', cmd):
            for row in table[1:]:
                row[0] = re.compile(b'\d*')
                row[2] = re.compile(b'\d')
                row[3] = re.compile(b'.*')
        if b'dcli list zone' in cmd or b'dcli dump zone' in cmd or b'dcli list rrs' in cmd:
            for rr_row in table:
                for rr_col in [2, 3, 4]:
                    if (rr_col + 1) < len(rr_row):
                        if rr_row[rr_col] == b'SOA':
                            stuff = rr_row[rr_col + 1].split()
                            rr_row[rr_col + 1] = re.compile(b'%s %s \d+ \d+ \d+ \d+ \d+' % (stuff[0], stuff[1]))
                        elif rr_row[rr_col] == b'DS':
                            rr_row[rr_col + 1] = re.compile(b'\d+ 8 2 .*')
        elif b'dcli history' in cmd:
            for row in table:
                if row[0] != b'timestamp':
                    row[0] = re.compile(b'.*')
                if row[-1].startswith(b'set_attr serial='):
                    row[-1] = re.compile(b'set_attr serial=\d+')
                if row[4] == b'key':
                    row[5] = re.compile(b'.*')
    elif b'dnssec enable' in cmd or b'dnssec new' in cmd:
        check_regexes(table, [b'.*Created key .*_[zk]sk_.* for zone (.*)',
                              b'.*Creating RR .* DS \d+ 8 2 .* in zone .*'])
    elif b'dnssec disable' in cmd or b'dnssec delete' in cmd or b'delete zone' in cmd:
        check_regexes(table, [b'.*Deleting RR .* DS \d+ 8 2 .* from zone .*'])
    return table


def match_table(actual_table, expected_table, actual_raw, expected_raw) -> list[str]:
    def match(row, info):
        if len(row) != len(info):
            return False
        for i, should in enumerate(info):
            if type(should) == bytes and should != row[i]:
                return False
            elif type(should) != bytes and re.match(should, row[i]) is None:
                return False
        return True

    result = []
    if len(actual_table) != len(expected_table):
        return actual_raw
    offset = 0
    for no, row in enumerate(actual_raw):
        if row.strip() == b'' and expected_raw[no].strip() == b'':
            offset += 1
            result.append(row)
            continue
        matched = match(actual_table[no - offset], expected_table[no - offset])
        if matched:
            result.append(expected_raw[no])
        else:
            result.append(row)
    return result


def split_cat_command(line):
    return b'EOF', b'$' + line.split(b'|')[1]


def get_cat_input(lines, word, out):
    cat_input = b''
    while len(lines) > 0:
        line = lines.pop(0)
        out.write(line)
        if line == word + b'\n':
            break
        else:
            cat_input += line
    return cat_input


def check_pdns_output(line, out):
    zone_commands = [c + o
                     for c in ('create ', 'delete ', 'modify ')
                     for o in ('rr', 'zone', 'zone-profile', 'zone-group')]
    if not any(line[8:].startswith(cmd) for cmd in zone_commands):
        return True
    zone_view_map = setup_pdns_output(server)
    pdns_output_proc.wait_updates()
    if not compare_dim_pdns_zones(server, PDNS_ADDRESS, zone_view_map):
        out.write("Zone incorrectly exported\n")
        return False
    return True


def run_test(testfile, outfile, stop_on_error=False, auto_pdns_check=False):
    with open(testfile, 'rb') as f:
        lines = f.readlines()
    # ignore auto_pdns_check if zone-groups or outputs are involved
    pdns_needed = False
    for line in lines:
        if b'create zone-group' in line or b'create output' in line:
            auto_pdns_check = False
        if b'drill' in line or b'dig' in line:
            pdns_needed = True
    if auto_pdns_check:
        pdns_needed = True

    global pdns_output_proc
    with PDNSOutputProcess(pdns_needed) as pdns_output_proc:
        clean_database()
        run_command(b'$ ndcli login -u admin -p p')
        if auto_pdns_check:
            global server
            server = DimClient(config['server'], cookie_file=os.path.expanduser('~/.ndcli.cookie'))
            server.output_create('pdns_output', 'pdns-db', db_uri=PDNS_DB_URI)
            server.zone_group_create('pdns_group')
            server.output_add_group('pdns_output', 'pdns_group')

        with open(outfile, 'wb') as out:
            while len(lines) > 0:
                line = lines.pop(0)
                out.write(line)
                cmd_input = None
                if line.startswith(b'$ cat <<EOF | ndcli'):
                    word, line = split_cat_command(line)
                    cmd_input = get_cat_input(lines, word, out)

                if line.startswith(b'$ '):
                    expected_result = []
                    while len(lines) > 0 and not lines[0].startswith(b'$ '):
                        expected_result.append(lines.pop(0))
                    while len(expected_result) > 0 and is_ignorable(expected_result[-1]):
                        lines.insert(0, expected_result.pop())
                    if line.startswith(b'$ ndcli'):
                        result = run_command(line, cmd_input)

                        if generates_table(line) or generates_map(line):
                            actual_table = table_from_lines(result.split(b'\n'), line)
                            expected_table = table_from_lines([x.strip(b'\n') for x in expected_result], line)
                        else:
                            actual_table = [[x] for x in result.splitlines(True)]
                            expected_table = [[x] for x in expected_result]
                        expected_table = add_regex(expected_table, line)
                        output = match_table(actual_table,
                                             expected_table,
                                             result.splitlines(True),
                                             expected_result)
                        out.writelines(list[str](output))

                        ok = output == expected_result
                        if not ok:
                            print("results didn't match:\nexpected: {}\nbut got: {}".format(expected_result, output))
                        if auto_pdns_check and not check_pdns_output(line, out):
                            ok = False
                    else:
                        line = line.strip(b'\n')
                        if is_pdns_query(line):
                            pdns_output_proc.wait_updates()
                        result = run_system_command(line[2:])
                        ok = process_command(result, expected_result, out, is_pdns_query(line))
                    if stop_on_error and not ok:
                        return False
        return not os.system('diff %s %s >/dev/null' % (testfile, outfile))


if __name__ == '__main__':
    # start the server process
    server = Popen(['manage_dim', 'runserver'], stderr=DEVNULL, stdout=DEVNULL)

    stop_on_error = False
    auto_pdns_check = False
    run_diff = False
    diff_left = OUT_DIR
    diff_right = T_DIR
    tests = []
    for test in sys.argv[1:]:
        if test == '-x':
            stop_on_error = True
        elif test == '-p':
            auto_pdns_check = True
        elif test == '-d':
            run_diff = True
        else:
            tests.append(test)
    if not tests:
        tests = sorted(os.listdir(T_DIR))
    failed = 0

    try:
        os.makedirs(OUT_DIR)
    except OSError as exc:
        if exc.errno != errno.EEXIST:
            server.kill()
            raise

    for test in tests:
        testfile = os.path.join(T_DIR, test)
        outfile = os.path.join(OUT_DIR, test)
        print('%s ... ' % test, end='')
        sys.stdout.flush()
        try:
            ok = run_test(testfile, outfile, stop_on_error, auto_pdns_check)
        except Exception:
            logging.exception('')
            ok = False
        print('ok' if ok else 'fail')
        sys.stdout.flush()
        if not ok:
            failed += 1
            if stop_on_error or len(tests) == 1:
                diff_left = outfile
                diff_right = testfile
            if stop_on_error:
                break
    if failed and run_diff:
        diff_files(diff_left, diff_right)
    server.kill()
    sys.exit(1 if failed else 0)
