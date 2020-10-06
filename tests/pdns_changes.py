import logging
import os
import random
import sys
from functools import wraps
from pprint import pformat
from subprocess import Popen, PIPE
from threading import Thread

from dim import db
from dim.models.dns import OutputUpdate
from dim.rpc import TRPC
from tests.pdns_test import PDNSTest
from tests.pdns_util import compare_dim_pdns_zones, this_dir, test_pdns_output_process


def delete_record(rpc, r):
    rpc.rr_delete(zone=r['zone'], name=r['record'], type=r['type'], **r['value'])


def add_record(rpc, r):
    rpc.rr_create(zone=r['zone'], name=r['record'], type=r['type'], ttl=r['ttl'], **r['value'])


def extract(l, selected_idx):
    '''split l into two lists: elements with indices in selected and the rest'''
    selected = []
    rejected = []
    selected_idx = set(selected_idx)
    for i, e in enumerate(l):
        if i in selected_idx:
            selected.append(e)
        else:
            rejected.append(e)
    return selected, rejected


class TestRequestProxy(object):
    ''''
    Simulate the flask lifecycle of a request by creating a new TRPC instance and request context
    (which in turns creates a new db session)
    '''
    def __init__(self, username, app):
        self.app = app
        self.username = username

    def __getattr__(self, name):
        if not name.startswith('_'):
            obj = TRPC(username=self.username)
            func = getattr(obj, name)
            if callable(func):
                @wraps(func)
                def wrapper(*args, **kwargs):
                    with self.app.test_request_context():
                        return func(*args, **kwargs)
                return wrapper
        raise AttributeError


done = False


def run_test(app, zone, pdns_output, db_uri, pdns_ip):
    global done
    try:
        rpc = TestRequestProxy('test_user', app)

        def check_zone():
            global done
            pdns_output.wait_updates(zone)
            if not compare_dim_pdns_zones(rpc, pdns_ip, {zone: None}):
                done = True
            if done:
                sys.exit()

        check_zone()
        rpc.zone_dnssec_enable(zone, nsec3_algorithm=1, nsec3_iterations=1, nsec3_salt='deadcafe')
        check_zone()
        records = rpc.rr_list(zone=zone, value_as_object=True)
        created = [r for r in records if r['type'] not in ('SOA', 'DNSKEY')]
        deleted = []
        total = len(created)
        for _ in range(30):
            selected = random.sample(range(total), random.randint(1, 5))
            midpoint = len(created)
            to_del, created = extract(created, [i for i in selected if i < midpoint])
            to_add, deleted = extract(deleted, [i - midpoint for i in selected if i >= midpoint])
            created.extend(to_add)
            deleted.extend(to_del)
            print('Adding', pformat(to_add))
            print('Deleting', pformat(to_del))
            for r in to_del:
                delete_record(rpc, r)
            for r in to_add:
                add_record(rpc, r)
            check_zone()
        rpc.zone_dnssec_disable(zone)
        check_zone()
    except:
        logging.exception('Exception in run_test')
        done = True


def import_zone(zone):
    proc = Popen(['ndcli', 'import', 'zone', zone], stdin=PIPE, stdout=PIPE)
    zone_contents = open(this_dir(zone)).read()
    stdout, stderr = proc.communicate(zone_contents)
    if proc.returncode != 0:
        raise Exception('zone import failed')


class PDNSOutputProcess(object):
    def __enter__(self):
        self.proc = test_pdns_output_process(True)
        return self

    def __exit__(self, *args):
        self.proc.kill()
        self.proc = None

    def wait_updates(self, zone):
        '''Wait for all updates to be processed'''
        with test.app.test_request_context():
            while True:
                db.session.rollback()
                if OutputUpdate.query.filter(OutputUpdate.zone_name == zone).count() == 0:
                    break
                else:
                    os.read(self.proc.stdout.fileno(), 1024)


if __name__ == '__main__':
    zones = {'web.de': {'db_uri': 'mysql://pdns:pdns@127.0.0.1:3307/pdns1',
                        'pdns_ip': '127.1.1.1'},
             'web2.de': {'db_uri': 'mysql://pdns:pdns@127.0.0.1:3307/pdns2',
                         'pdns_ip': '127.2.2.2'}}

    global test
    test = PDNSTest('__init__')
    test.setUp()

    for zone in list(zones.keys()):
        test.cleanup_pdns_db(zones[zone]['db_uri'])
        import_zone(zone)
        test.create_output_for_zone(zone, zone, zone, db_uri=zones[zone]['db_uri'])
    with PDNSOutputProcess() as pdns_output:
        threads = []
        for zone, attr in zones.items():
            t = Thread(target=run_test, args=(test.app, zone, pdns_output), kwargs=attr)
            t.start()
            threads.append(t)
        for t in threads:
            while t.isAlive():
                t.join(0.1)
