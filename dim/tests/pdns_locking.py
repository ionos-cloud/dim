#
# Test the correctness of the pdns daemon in case of random failures in a
# load-balanced scenario.
#
# $ python -m tests.pdns_locking
#
import logging
import os
import random
import subprocess
import threading
import time

from sqlalchemy import create_engine

from tests.pdns_test import PDNSTest


def run_checks(pdns_uri):
    with create_engine(pdns_uri).begin() as conn:
        records = conn.execute('select * from records').fetchall()
        if len(records) >= 3:
            print(records)
            os.killpg(os.getpgid(0), 9)
        assert conn.execute('select count(*) from records').scalar() < 3


def event_generator():
    test = PDNSTest('__init__')
    test.setUp()
    logging.getLogger().setLevel(logging.WARNING)

    test.r.zone_create('test.com')
    test.create_output_for_zone('test.com')
    test.r.rr_create(name='a.test.com.', type='txt', strings=['0'])
    for i in range(1, 10000):
        test.r.rr_delete(name='a.test.com.', type='txt', strings=[str(i - 1)])
        test.r.rr_create(name='a.test.com.', type='txt', strings=[str(i)])
        run_checks(test.pdns_uri)
        time.sleep(0.05)


class PDNSDaemon(object):
    def __init__(self):
        self.start()

    def start(self):
        self.p = subprocess.Popen(['python', 'manage_dim', 'pdns', '-t'])

    def stop(self):
        self.p.kill()
        self.p.wait()

    def restart(self):
        self.stop()
        self.start()


def chaos_monkey():
    services = [PDNSDaemon() for _ in range(2)]
    while True:
        time.sleep(random.uniform(0, 0.3))
        random.choice(services).restart()


if __name__ == '__main__':
    threading.Thread(target=event_generator).start()
    chaos_monkey()
