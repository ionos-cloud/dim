from datetime import datetime, timedelta
from contextlib import contextmanager
from dim.models import db, Ipblock, IpblockAttr
from dim.ipaddr import IP
from dim.errors import InvalidIPError, AlreadyExistsError, InvalidPoolError, InvalidStatusError, DimError
from tests.util import RPCTest, raises, query_ip


def get_ipblock(ip):
    return query_ip(ip).one()


def ip_status(l):
    return [dict(ip=d['ip'], status=d['status']) for d in l]


def ips(l):
    return [d['ip'] for d in l]


@contextmanager
def modifies(block, should=True):
    ipb = get_ipblock(block)
    ipb.modified = datetime.utcnow() - timedelta(days=1)
    ipb.modified_by = 'dummy_modifies'
    db.session.commit()
    yield
    ipb = get_ipblock(block)
    was_modified = datetime.utcnow() - ipb.modified < timedelta(minutes=1)
    assert should == was_modified
    if was_modified:
        assert ipb.modified_by != 'dummy_modifies'
    else:
        assert ipb.modified_by == 'dummy_modifies'


class IpblockTest(RPCTest):
    def test_create(self):
        self.r.ip_mark('12.0.0.1')
        self.r.ipblock_create('12.0.0.0/16', status='Container')
        self.r.ip_mark('12.0.0.2')
        self.r.ipblock_create('12.0.0.0/24', status='Container')
        self.r.ip_mark('12.0.0.3')
        assert get_ipblock('12.0.0.0/16').parent is None
        assert get_ipblock('12.0.0.0/24').parent.ip == IP('12.0.0.0/16')
        assert get_ipblock('12.0.0.1').parent.ip == IP('12.0.0.0/24')
        assert get_ipblock('12.0.0.2').parent.ip == IP('12.0.0.0/24')
        assert get_ipblock('12.0.0.3').parent.ip == IP('12.0.0.0/24')
        with raises(AlreadyExistsError):
            self.r.ipblock_create('12.0.0.0/16')

    def test_create_errors(self):
        with raises(InvalidIPError):
            self.r.ipblock_create('12.0.0.1/24')

    def test_delete1(self):
        self.r.ipblock_create('12.0.0.0/16', status='Container')
        self.r.ipblock_create('12.0.0.0/24', status='Container')
        self.r.ip_mark('12.0.0.1')

        with raises(DimError):
            self.r.ipblock_remove('12.0.0.0/24')
        self.r.ip_free('12.0.0.1')
        assert self.r.ipblock_remove('12.0.0.0/24')
        self.r.ip_mark('12.0.0.1')
        assert Ipblock.query.count() == 2
        assert query_ip('12.0.0.0/24').count() == 0

        self.r.ipblock_remove('12.0.0.0/16', force=True)
        assert Ipblock.query.count() == 1
        assert query_ip('12.0.0.0/16').count() == 0

    def test_recursive_delete1(self):
        self.r.ipblock_create('12.0.0.0/16', status='Container')
        self.r.ipblock_create('12.0.0.0/24', status='Container')
        self.r.ip_mark('12.0.0.1')
        self.r.ipblock_remove('12.0.0.0/16', force=True, recursive=True)
        assert Ipblock.query.count() == 0

    def test_recursive_delete2(self):
        self.r.ipblock_create('12::/16', status='Container')
        self.r.ipblock_create('12::/24', status='Container')
        self.r.ip_mark('12::1')
        self.r.ipblock_remove('12::/24', force=True, recursive=True)
        assert Ipblock.query.count() == 1

    def test_parents(self):
        self.r.ipblock_create('192.168.0.0/16', status='Container')
        self.r.ip_mark('192.168.0.1')
        assert get_ipblock('192.168.0.1').parent.ip == IP('192.168.0.0/16')

        self.r.ipblock_create('192.168.0.0/24', status='Container')
        assert get_ipblock('192.168.0.1').parent.ip == IP('192.168.0.0/24')

        self.r.ipblock_remove('192.168.0.0/24', force=True)
        assert get_ipblock('192.168.0.1').parent.ip == IP('192.168.0.0/16')

        self.r.ipblock_create('192.168.0.0/24', status='Container')
        assert get_ipblock('192.168.0.1').parent.ip == IP('192.168.0.0/24')

    def test_ip_mark(self):
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '12.0.0.0/24')
        with raises(InvalidPoolError):
            self.r.ip_mark('12.0.0.2', pool='test')
        self.r.ip_mark('12.0.0.2')
        with raises(AlreadyExistsError):
            self.r.ip_mark('12.0.0.2')
        assert self.r.ip_mark('12.0.0.5')['status'] == 'Static'
        with raises(AlreadyExistsError):
            self.r.ip_mark('12.0.0.5')
        assert self.r.ip_free('12.0.0.5') == 1
        assert self.r.ip_free('12.0.0.5') == 0
        assert self.r.ip_free('5.0.0.5') == 0
        assert self.r.ipblock_get_attrs('12.0.0.5')['status'] == 'Available'
        assert self.r.ip_mark('12.0.0.5')['status'] == 'Static'
        assert self.r.ipblock_get_attrs('12.0.0.0')['status'] == 'Reserved'
        assert self.r.ip_free('12.0.0.0') == -1
        assert self.r.ip_free('12.0.0.0', reserved=True) == 1
        assert self.r.ipblock_get_attrs('12.0.0.0')['status'] == 'Available'

    def test_attrs(self):
        self.r.ipblock_create('12.0.0.0/24', attributes={'team': '1'})

        create_attrs = {'country': 'ro', 'team': 'IT Operations'}
        self.r.ipblock_create('13.0.0.0/24', attributes=create_attrs)

        self.assertDictSubset(self.r.ipblock_get_attrs('13.0.0.0/24'), create_attrs)
        self.r.ipblock_set_attrs('13.0.0.0/24', {'country': 'de'})
        self.assertDictSubset(self.r.ipblock_get_attrs('13.0.0.0/24'), {'country': 'de'})
        self.r.ipblock_delete_attrs('13.0.0.0/24', ['team'])
        assert 'team' not in self.r.ipblock_get_attrs('13.0.0.0/24')

        assert self.r.ipblock_get_attrs('12.0.0.0/24')['team'] == '1'
        assert 'country' not in self.r.ipblock_get_attrs('12.0.0.0/24')

        assert self.r.ipblock_remove('12.0.0.0/24')
        assert self.r.ipblock_remove('13.0.0.0/24')
        assert IpblockAttr.query.count() == 0
        with raises(InvalidIPError):
            self.r.ipblock_get_attrs('12.0.0.0/24')

    def test_invalid_attrs(self):
        self.r.ipblock_create('12.0.0.0/24')
        with raises(Exception):
            self.r.ipblock_set_attrs('12.0.0.0/24', {'ip': '12.0.0.1'})
        with raises(Exception):
            self.r.ipblock_set_attrs('12.0.0.0/24', {'-a': 'b'})

    def test_system_attrs(self):
        self.r.ipblock_create('12.0.0.0/16', status='Container')
        self.r.ippool_create('test')
        self.r.ippool_add_subnet('test', '12.0.0.0/24', gateway='12.0.0.1')
        self.r.ipblock_create('12.0.0.64/26', status='Delegation')
        self.r.ip_mark('12.0.0.65')
        self.assertDictSubset(self.r.ipblock_get_attrs('12.0.0.0'),
                              {'ip': '12.0.0.0',
                               'status': 'Reserved',
                               'subnet': '12.0.0.0/24',
                               'gateway': '12.0.0.1',
                               'mask': '255.255.255.0',
                               'pool': 'test'})
        self.assertDictSubset(self.r.ipblock_get_attrs('12.0.0.64'),
                              {'ip': '12.0.0.64',
                               'status': 'Available',
                               'delegation': '12.0.0.64/26',
                               'subnet': '12.0.0.0/24',
                               'gateway': '12.0.0.1',
                               'mask': '255.255.255.0',
                               'pool': 'test'})
        self.r.subnet_remove_gateway('12.0.0.0/24')
        assert 'gateway' not in self.r.ipblock_get_attrs('12.0.0.64')
        self.r.subnet_set_gateway('12.0.0.0/24', '1.0.0.0')
        assert self.r.ipblock_get_attrs('12.0.0.64')['gateway'] == '1.0.0.0'
        self.assertEqual(self.r.ipblock_get_attrs('1.0.0.0')['status'], 'Unmanaged')

    def test_system_attrs6(self):
        self.r.ipblock_create('12::/32', status='Container')
        self.r.ippool_create('test')
        self.r.ippool_add_subnet('test', '12::/64', gateway='12::1')
        self.r.ipblock_create('12::40/122', status='Delegation')
        self.r.ip_mark('12::65')
        self.assertDictSubset(self.r.ipblock_get_attrs('12::65'),
                              {'ip': '12::65',
                               'status': 'Static',
                               'subnet': '12::/64',
                               'delegation': '12::40/122',
                               'gateway': '12::1',
                               'prefixlength': 64,
                               'pool': 'test'})

    def test_modified(self):
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ip_mark('12.0.0.1')
        self.r.ippool_create('test')
        with modifies('12.0.0.1'):
            self.r.ipblock_set_attrs('12.0.0.1', {'test': 1})
        assert self.r.ipblock_get_attrs('12.0.0.1')['test'] == '1'
        with modifies('12.0.0.1'):
            self.r.ipblock_delete_attrs('12.0.0.1', ['test'])
        with modifies('12.0.0.1', False):
            self.r.ippool_add_subnet('test', '12.0.0.0/24', dont_reserve_network_broadcast=True)
        with modifies('12.0.0.1', False):
            self.r.ipblock_create('12.0.0.0/26', status='Delegation')
        with modifies('12.0.0.1', False):
            with modifies('12.0.0.0/24'):
                self.r.subnet_set_gateway('12.0.0.0/24', '12.0.0.1')
            with modifies('12.0.0.0/24'):
                self.r.subnet_remove_gateway('12.0.0.0/24')
            with modifies('12.0.0.0/24'):
                self.r.subnet_set_priority('12.0.0.0/24', 2)
            with modifies('12.0.0.0/24'):
                self.r.ippool_set_vlan('test', 1)
            with modifies('12.0.0.0/24'):
                self.r.ippool_remove_vlan('test')
        with modifies('12.0.0.1', False):
            assert self.r.ipblock_remove('12.0.0.0/24', status='Subnet', force=True)

    def test_list_ipsv4(self):
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ippool_create('test')
        self.r.ippool_add_subnet('test', '12.0.0.0/24')
        self.r.ip_mark('12.0.0.5')
        assert ip_status(self.r.ip_list(pool='*', type='used')) == \
            [{'ip': '12.0.0.5', 'status': 'Static'}]
        self.r.ip_mark('12.0.0.9', pool='test')
        assert ip_status(self.r.ip_list(pool='*', type='used')) == \
            [{'ip': '12.0.0.5', 'status': 'Static'},
             {'ip': '12.0.0.9', 'status': 'Static'}]
        assert ip_status(self.r.ip_list(pool='*', type='used', limit=1)) == \
            [{'ip': '12.0.0.5', 'status': 'Static'}]
        assert ip_status(self.r.ip_list(pool='*', type='free', limit=5)) == \
            [{'ip': '12.0.0.1', 'status': 'Available'},
             {'ip': '12.0.0.2', 'status': 'Available'},
             {'ip': '12.0.0.3', 'status': 'Available'},
             {'ip': '12.0.0.4', 'status': 'Available'},
             {'ip': '12.0.0.6', 'status': 'Available'}]
        assert ip_status(self.r.ip_list(pool='*', type='all', limit=7)) == \
            [{'ip': '12.0.0.0', 'status': 'Reserved'},
             {'ip': '12.0.0.1', 'status': 'Available'},
             {'ip': '12.0.0.2', 'status': 'Available'},
             {'ip': '12.0.0.3', 'status': 'Available'},
             {'ip': '12.0.0.4', 'status': 'Available'},
             {'ip': '12.0.0.5', 'status': 'Static'},
             {'ip': '12.0.0.6', 'status': 'Available'}]

    def test_list_ipsv6(self):
        self.r.ipblock_create('11::/16', status='Container')
        self.r.ippool_create('poolv6')
        self.r.ippool_add_subnet('poolv6', '11::/126')
        self.r.ip_mark('11::1', pool='poolv6')
        assert ip_status(self.r.ip_list(pool='poolv6', type='all')) == \
            [{'ip': '11::', 'status': 'Reserved'},
             {'ip': '11::1', 'status': 'Static'},
             {'ip': '11::2', 'status': 'Available'},
             {'ip': '11::3', 'status': 'Available'}]
        assert ip_status(self.r.ip_list(pool='poolv6', type='all', full=1)) == \
            [{'ip': '0011:0000:0000:0000:0000:0000:0000:0000', 'status': 'Reserved'},
             {'ip': '0011:0000:0000:0000:0000:0000:0000:0001', 'status': 'Static'},
             {'ip': '0011:0000:0000:0000:0000:0000:0000:0002', 'status': 'Available'},
             {'ip': '0011:0000:0000:0000:0000:0000:0000:0003', 'status': 'Available'}]

    def test_list_ips_after(self):
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ippool_create('pool1', vlan=5)
        self.r.ippool_add_subnet('pool1', '13.0.4.0/22')
        self.r.ippool_add_subnet('pool1', '13.0.0.0/22')
        subnet = IP('13.0.0.0')

        def nth(n):
            return str(IP(subnet.address + n, prefix=32, version=4))

        def iprange(start, end):
            return [nth(i) for i in range(start, end + 1)]
        assert ips(self.r.ip_list(pool='pool1', type='all', limit=5)) == iprange(0, 4)
        assert ips(self.r.ip_list(pool='pool1', type='all', after='13.0.0.4', limit=5)) == iprange(5, 9)
        assert ips(self.r.ip_list(pool='*', type='all', after='13.0.3.207', limit=49)) == iprange(3 * 256 + 207 + 1, 3 * 256 + 207 + 49)
        assert ips(self.r.ip_list(pool='*', type='all', offset=3 * 256 + 207 + 1, limit=49))\
            == iprange(3 * 256 + 207 + 1, 3 * 256 + 207 + 49)

    def test_list_ips_offset(self):
        def iprange(start, end):
            return [str(IP(IP('13.0.0.0').address + i, prefix=32, version=4)) for i in range(start, end + 1)]
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ippool_create('pool1', vlan=5)
        self.r.ippool_add_subnet('pool1', '13.0.0.0/30', dont_reserve_network_broadcast=True)
        self.r.ippool_add_subnet('pool1', '13.0.0.4/30', dont_reserve_network_broadcast=True)
        self.r.ip_mark('13.0.0.2')
        self.r.ip_mark('13.0.0.5')
        assert ips(self.r.ip_list(pool='pool1', type='all', limit=3, offset=1)) == iprange(1, 3)
        assert ips(self.r.ip_list(pool='pool1', type='all', limit=3, offset=4)) == iprange(4, 6)
        assert ips(self.r.ip_list(pool='pool1', type='all', limit=3, offset=3)) == iprange(3, 5)
        free = ['13.0.0.1', '13.0.0.3', '13.0.0.4', '13.0.0.6', '13.0.0.7']
        assert ips(self.r.ip_list(pool='pool1', type='free', limit=5)) == free
        for i in range(5):
            assert ips(self.r.ip_list(pool='pool1', type='free', limit=1, offset=i)) == [free[i]]
        assert ips(self.r.ip_list(pool='pool1', type='used', limit=3)) == ['13.0.0.2', '13.0.0.5']
        assert ips(self.r.ip_list(pool='pool1', type='used', limit=3, offset=1)) == ['13.0.0.5']

    def test_list_ip_attrs(self):
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ipblock_create('14.0.0.0/8', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '13.0.4.0/22')
        self.r.ippool_add_subnet('pool', '14.0.0.0/22')
        self.r.ippool_get_ip('pool', attributes={'k1': 'v1', 'k2': 'v2'})
        self.r.ippool_get_ip('pool', attributes={'k3': 'v3'})
        self.r.ippool_get_ip('pool')

        ips = self.r.ip_list(pool='pool', type='all', limit=5)
        self.assertDictSubset(ips[0], {'ip': '13.0.4.0', 'modified_by': 'test_user', 'status': 'Reserved'})
        self.assertDictSubset(ips[1], {'ip': '13.0.4.1', 'modified_by': 'test_user', 'status': 'Static', 'k1': 'v1', 'k2': 'v2'})
        self.assertDictSubset(ips[2], {'ip': '13.0.4.2', 'modified_by': 'test_user', 'status': 'Static', 'k3': 'v3'})
        self.assertDictSubset(ips[3], {'ip': '13.0.4.3', 'modified_by': 'test_user', 'status': 'Static'})
        self.assertDictSubset(ips[4], {'ip': '13.0.4.4', 'status': 'Available'})

        ips = self.r.ip_list(pool='pool', type='all', limit=5, attributes=['k1', 'k3', 'modified_by'])
        assert set(ips[1].keys()) == set(['ip', 'status', 'modified_by', 'k1', 'layer3domain'])
        assert 'k1' in ips[1]
        assert 'k2' not in ips[1]
        assert 'k3' in ips[2]

    def test_list_ip_attrs_ptr(self):
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ipblock_create('14.0.0.0/8', status='Container')
        self.r.zone_create('test')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '13.0.4.0/22')
        self.r.ippool_add_subnet('pool', '14.0.0.0/22')
        self.r.rr_create_from_pool('a.test.', 'pool', attributes={'k1': 'v1', 'k2': 'v2'})
        self.r.rr_create_from_pool('b.test.', 'pool', attributes={'k3': 'v3'})
        self.r.rr_create_from_pool('c.test.', 'pool')
        import pprint
        pprint.pprint(self.r.ip_list(pool='pool', type='all', limit=5, attributes=None))

    def test_list_ip_attrs_pool(self):
        def has_pool(ips, pool):
            for ip in ips:
                if ip.get('pool', None) != pool:
                    return False
            return True
        self.r.ippool_create('pool')
        self.r.ippool_create('pool2')
        self.r.ipblock_create('13.0.0.0/8', status='Container')
        self.r.ippool_add_subnet('pool', '13.0.4.0/30')
        self.r.ippool_add_subnet('pool2', '13.0.4.4/30')
        assert has_pool(self.r.ip_list(cidr='13.0.4.0/30', attributes=['pool']), 'pool')
        assert has_pool(self.r.ip_list(cidr='13.0.4.0/31', attributes=['pool']), 'pool')
        assert has_pool(self.r.ip_list(cidr='13.0.4.0/32', attributes=['pool']), 'pool')
        assert has_pool(self.r.ip_list(cidr='13.0.4.4/30', attributes=['pool']), 'pool2')
        self.r.ip_list(cidr='13.0.4.0/28', attributes=['pool'])
        # TODO fix pool attr code for ip_list()
        # assert has_pool(both[:4], 'pool')
        # assert has_pool(both[4:], 'pool2')

    def test_list_containers_edge(self):
        assert self.r.container_list() == []
        with raises(InvalidIPError):
            self.r.container_list('12.0.0.0/24')
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ippool_create('pool')
        self.r.ippool_add_subnet('pool', '12.0.0.0/24')
        with raises(InvalidStatusError):
            self.r.container_list('12.0.0.0/24')

    def test_list_containers_simple(self):
        self.r.ipblock_create('0.0.0.0/16', status='Container')
        self.r.ipblock_create('0.0.160.0/19', status='Container')
        self.r.ipblock_create('0.0.192.0/19', status='Container')
        assert ips(self.r.container_list()[0]['children']) == [
            '0.0.0.0/17',
            '0.0.128.0/19',
            '0.0.160.0/19',
            '0.0.192.0/19',
            '0.0.224.0/19']

    def test_list_containers_sort(self):
        self.r.ipblock_create('2001:8d8::/54', status='Container')
        self.r.ippool_create('pool6')
        self.r.ippool_add_subnet('pool6', '2001:8d8::/56')
        assert ips(self.r.container_list('2001:8d8::/54')[0]['children']) == [
            '2001:8d8::/56',
            '2001:8d8:0:100::/56',
            '2001:8d8:0:200::/55']

    def test_list_containers_v6(self):
        self.r.ipblock_create('2001:db8:0:f00::/64', status='Container')
        self.r.ipblock_create('2001:db8:0:f00:22::/80', status='Container')
        assert ips(self.r.container_list('2001:db8:0:f00::/64')[0]['children']) == [
            '2001:db8:0:f00::/75',
            '2001:db8:0:f00:20::/79',
            '2001:db8:0:f00:22::/80',
            '2001:db8:0:f00:23::/80',
            '2001:db8:0:f00:24::/78',
            '2001:db8:0:f00:28::/77',
            '2001:db8:0:f00:30::/76',
            '2001:db8:0:f00:40::/74',
            '2001:db8:0:f00:80::/73',
            '2001:db8:0:f00:100::/72',
            '2001:db8:0:f00:200::/71',
            '2001:db8:0:f00:400::/70',
            '2001:db8:0:f00:800::/69',
            '2001:db8:0:f00:1000::/68',
            '2001:db8:0:f00:2000::/67',
            '2001:db8:0:f00:4000::/66',
            '2001:db8:0:f00:8000::/65']

    def test_ip_list_attributes(self):
        self.r.ipblock_create('12.0.0.0/8', status='Container')
        self.r.ippool_create('test')
        self.r.ippool_add_subnet('test', '12.0.0.0/24')
        self.r.rr_create(ip='12.0.0.1', type='A', name='t.0.0.12.in-addr.arpa.', create_linked=False)
        assert 'ptr_target' not in self.r.ip_list(pool='test', attributes=['ptr_target'], type='used')[0]
        self.r.rr_create(ip='12.0.0.1', type='PTR', ptrdname='test.com.')
        assert self.r.ip_list(pool='test', attributes=['ptr_target'], type='used')[0]['ptr_target'] == 'test.com.'

    # test for ND-94
    def test_add_subnet(self):
        self.r.ippool_create('test')
        # allocate ip without a subnet
        self.r.rr_create(name='some.domain.', type='A', ip='1.1.1.0')
        self.r.ipblock_create('1.0.0.0/8', status='Container')
        self.r.ippool_add_subnet('test', '1.1.1.0/24')

    # test for GPHDIM-432
    def test_delegation_no_parent(self):
        with raises(Exception):
            self.r.ipblock_create('1.0.0.0/30', status='Delegation')

    # test for GPHDIM-432
    def test_subnet_no_pool(self):
        self.r.ipblock_create('1.0.0.0/24', status='Container')
        with raises(Exception):
            self.r.ipblock_create('1.0.0.0/30', status='Subnet')
