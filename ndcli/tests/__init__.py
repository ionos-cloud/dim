import logging
import os
import os.path
import shlex
import sys
import re
from cStringIO import StringIO
from dimcli import CLI, logger

cli = CLI()


# taken from unittest/python 2.7
def assertDictSubset(actual, expected, msg=None):
    """Checks whether actual is a superset of expected."""
    missing = []
    mismatched = []
    for key, value in expected.iteritems():
        if key not in actual:
            missing.append(key)
        elif value != actual[key]:
            mismatched.append('%s, expected: %s, actual: %s' %
                              (repr(key), repr(value),
                               repr(actual[key])))

    if not (missing or mismatched):
        return
    msg = ''
    if missing:
        msg = 'Missing: %s' % ','.join(repr(m) for m in missing)
    if mismatched:
        if msg:
            msg += '; '
        msg += 'Mismatched values: %s' % ','.join(mismatched)
    raise AssertionError(msg)


class NdcliResult(object):
    def __init__(self, code, stdout, stderr):
        self.code = code
        self.stdout = stdout
        self.stderr = stderr

    @property
    def ok(self):
        return self.code == 0

    @property
    def err(self):
        return self.code != 0

    def __repr__(self):
        return self.stdout

    @property
    def table(self):
        return [l.split('\t') for l in self.stdout.splitlines()]

    @property
    def attrs(self):
        return dict(l.split(':', 1) for l in self.stdout.splitlines())


def _ndcli(cmd, level=logging.WARNING):
    stderr = StringIO()
    stderrHandler = logging.StreamHandler(stderr)
    stderrHandler.setFormatter(logging.Formatter('%(levelname)s - %(message)s'))
    stderrHandler.setLevel(level)
    logger.addHandler(stderrHandler)
    old_stdout = sys.stdout
    sys.stdout = stdout = StringIO()
    code = cli.run(['ndcli'] + shlex.split(cmd))
    sys.stdout = old_stdout
    logger.removeHandler(stderrHandler)
    return NdcliResult(code, stdout.getvalue(), stderr.getvalue())


# --username needs AUTHENTICATION_METHOD = None in dim.cfg
def reset_session():
    try:
        os.remove(os.path.expanduser('~/.ndcli.cookie'))
    except:
        pass
    global cli
    cli = CLI()


def admin(cmd):
    reset_session()
    return _ndcli("--username admin --password admin " + cmd)

ndcli = admin


def net(cmd):
    reset_session()
    return _ndcli("--username net --password net " + cmd)


def user(cmd):
    reset_session()
    return _ndcli("--username user --password user " + cmd)


def assert_match_table(table, matching_info):
    def match(row, info):
        if len(row) != len(info):
            return False
        for i in range(len(row)):
            if type(info[i]) == str and info[i] != row[i]:
                return False
            elif re.match(info[i], row[i]) is None:
                return False
        return True
    matches = {}
    for t, row in enumerate(table):
        matched = False
        for m, info in enumerate(matching_info):
            if match(row, info):
                matched = True
                matches[m] = t
                break
        if not matched:
            raise AssertionError('Cannot match row %r' % row)
    if len(matches) < len(matching_info):
        raise AssertionError('Missing rows:\n' + '\n'.join(str(info) for m, info in enumerate(matching_info) if m not in matches))
