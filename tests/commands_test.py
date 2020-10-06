import re
from dim import db
from dim.commands import pool_report, update_history
from dim.models import AllocationHistory, Pool
from tests.util import RPCTest
from datetime import datetime, timedelta


class CommandsTest(RPCTest):
    def test_pool_report(self):
        assert 'does not exist' in pool_report('pool')

        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '12.0.0.0/24')
        self.r.ippool_add_subnet('pool', '13.0.0.0/24')
        assert re.search('usage *n/a *n/a *n/a', pool_report('pool'))

        pool = Pool.query.filter_by(name='pool').one()
        now = datetime.now()
        db.session.add_all(
            [AllocationHistory(pool=pool, date=now - timedelta(days=30), total_ips=512, used_ips=4),
             AllocationHistory(pool=pool, date=now - timedelta(days=7), total_ips=512, used_ips=40),
             AllocationHistory(pool=pool, date=now - timedelta(days=1), total_ips=512, used_ips=44)])
        db.session.commit()
        assert self.r.ippool_get_delegation('pool', 26)
        report = pool_report('pool')
        assert re.search('usage *24 *28 *64', report)
        assert '444 IPs are still free' in report
        assert 'Based on data from the last 30 days, the pool will be full in 208.1 days.' in report

    def test_pool_reportv6(self):
        self.r.ipblock_create('12::/32', status='Container')
        self.r.ipblock_create('13::/32', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '12::/56', dont_reserve_network_broadcast=True)
        self.r.ippool_add_subnet('pool', '13::/56', dont_reserve_network_broadcast=True)
        pool = Pool.query.filter_by(name='pool').one()
        now = datetime.now()
        db.session.add_all(
            [AllocationHistory(pool=pool, date=now - timedelta(days=30), total_ips=2 ** 57, used_ips=4 * 2 ** 64),
             AllocationHistory(pool=pool, date=now - timedelta(days=7), total_ips=2 ** 57, used_ips=40 * 2 ** 64),
             AllocationHistory(pool=pool, date=now - timedelta(days=1), total_ips=2 ** 57, used_ips=44 * 2 ** 64)])
        db.session.commit()
        assert self.r.ippool_get_delegation('pool', 58)
        report = pool_report('pool', prefix=64)
        assert re.search('usage *20 *24 *60', report)
        assert '448 /64 blocks are still free' in report
        assert 'Based on data from the last 30 days, the pool will be full in 224.0 days.' in report

    def test_update_history(self):
        self.r.ipblock_create('12::/32', status='Container')
        self.r.ipblock_create('13::/32', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '12::/56')
        self.r.ippool_add_subnet('pool', '13::/56')
        assert self.r.ippool_get_delegation('pool', 58)
        update_history()

        pool = Pool.query.filter_by(name='pool').one()
        ah = pool.allocation_history(0)
        assert ah.total_ips == 512 * 2 ** 64
        assert ah.used_ips == 64 * 2 ** 64 + 2
