from tests.util import RPCTest
from dim.models import Zone


def zone(name):
    return Zone.query.filter_by(name=name).first()


class RevzoneTest(RPCTest):
    def assert_mark_revzone(self, ip, expected_revzone):
        self.r.ip_mark(ip)
        revzone = self.r.ipblock_get_attrs(ip)['reverse_zone']
        if revzone != expected_revzone:
            raise AssertionError("Reverse zone for %s is %s, expected %s" % (ip, revzone, expected_revzone))

    def test_attrs_v4(self):
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '12.0.0.0/24', gateway='12.0.0.1')
        self.assertDictSubset(
            self.r.ipblock_get_attrs('12.0.0.0/24'),
            {'gateway': '12.0.0.1',
             'status': 'Subnet',
             'ip': '12.0.0.0/24',
             'mask': '255.255.255.0',
             'pool': 'pool',
             'reverse_zone': '0.0.12.in-addr.arpa',
             })
        self.r.ip_mark('12.0.0.1', pool='pool', attributes={'key': 'value'})
        self.assertDictSubset(
            self.r.ipblock_get_attrs('12.0.0.1'),
            {'ip': '12.0.0.1',
             'gateway': '12.0.0.1',
             'status': 'Static',
             'subnet': '12.0.0.0/24',
             'mask': '255.255.255.0',
             'key': 'value',
             'pool': 'pool',
             'reverse_zone': '0.0.12.in-addr.arpa',
             })
        self.r.ippool_get_ip('pool', attributes={'key': 'value'})
        self.assertDictSubset(
            self.r.ipblock_get_attrs('12.0.0.2'),
            {'ip': '12.0.0.2',
             'gateway': '12.0.0.1',
             'status': 'Static',
             'subnet': '12.0.0.0/24',
             'mask': '255.255.255.0',
             'key': 'value',
             'pool': 'pool',
             'reverse_zone': '0.0.12.in-addr.arpa',
             })

    def test_simple_v6(self):
        self.r.ipblock_create('2001::/16', status='Container')
        self.r.ippool_create('pool6')
        self.r.ippool_add_subnet('pool6', '2001:08d8:0640:0000:0000:0000:0000:0000/55')
        self.assertDictSubset(
            self.r.ipblock_get_attrs('2001:08d8:0640:0180:0000:0000:0071:0119'),
            {'status': 'Available',
             'reverse_zone': '1.0.0.4.6.0.8.d.8.0.1.0.0.2.ip6.arpa',
             })

    def test_mark_v4(self):
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ippool_create("pool")
        self.r.ippool_add_subnet("pool", '12.0.0.0/22')
        self.assert_mark_revzone('12.0.0.1', '0.0.12.in-addr.arpa')
        self.assert_mark_revzone('12.0.1.1', '1.0.12.in-addr.arpa')
        self.assert_mark_revzone('12.0.2.1', '2.0.12.in-addr.arpa')
        self.assert_mark_revzone('12.0.3.1', '3.0.12.in-addr.arpa')

    def test_small_subnets_v4(self):
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ippool_create("pool")
        self.r.ippool_add_subnet("pool", '13.0.0.0/25')
        self.r.ippool_add_subnet("pool", '13.0.0.128/25')
        self.assert_mark_revzone('13.0.0.1', '0.0.13.in-addr.arpa')
        self.assert_mark_revzone('13.0.0.129', '0.0.13.in-addr.arpa')

    def test_delete_subnet_v4(self):
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ippool_create("pool")
        self.r.ippool_add_subnet("pool", '13.0.0.0/25')
        self.r.ippool_add_subnet("pool", '13.0.0.128/25')
        assert self.r.ippool_delete("pool", force=True, delete_subnets=True)
        # The reverse zone is deleted when the last subnet for it is deleted.
        # ND-91
        assert not zone('0.0.13.in-addr.arpa')
        assert not zone('0.0.12.in-addr.arpa')
        assert not zone('1.0.12.in-addr.arpa')
        assert not zone('2.0.12.in-addr.arpa')
        assert not zone('3.0.12.in-addr.arpa')

    def test_nosplit_v6(self):
        self.r.ipblock_create('3001::/16', status='Container')
        self.r.ippool_create("pool6")
        self.r.ippool_add_subnet("pool6", '3001:08d8:a640:0000:0000:0000:0000:0000/56')
        self.assert_mark_revzone('3001:08d8:a640:0080:0000:0000:0071:0119',
                                 '0.0.0.4.6.a.8.d.8.0.1.0.0.3.ip6.arpa')
        assert not zone('1.0.0.4.6.a.8.d.8.0.1.0.0.3.ip6.arpa')
        assert self.r.ippool_delete("pool6", force=True, delete_subnets=True)
        assert not zone('0.0.0.4.6.a.8.d.8.0.1.0.0.3.ip6.arpa')

    def test_split_v6(self):
        self.r.ipblock_create('2001::/16', status='Container')
        self.r.ippool_create("pool6")
        self.r.ippool_add_subnet("pool6", '2001:08d8:0640:0200:0000:0000:0000:0000/55')
        self.assert_mark_revzone('2001:08d8:0640:02ff:ffff:ffff:ffff:ffff',
                                 '2.0.0.4.6.0.8.d.8.0.1.0.0.2.ip6.arpa')
        self.assert_mark_revzone('2001:08d8:0640:03ff:ffff:ffff:ffff:ffff',
                                 '3.0.0.4.6.0.8.d.8.0.1.0.0.2.ip6.arpa')
        assert not zone('4.0.0.4.6.0.8.d.8.0.1.0.0.2.ip6.arpa')
        assert self.r.ippool_delete("pool6", force=True, delete_subnets=True)
        assert not zone('2.0.0.4.6.0.8.d.8.0.1.0.0.2.ip6.arpa')
        assert not zone('3.0.0.4.6.0.8.d.8.0.1.0.0.2.ip6.arpa')
