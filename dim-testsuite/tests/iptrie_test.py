from dim.ipaddr import IP
from dim.iptrie import IPTrie


def test_create():
    t = IPTrie(4)

    ip2 = IP('12.0.0.0/24')
    t.insert(ip2, 2)
    assert t.parent(ip2) is None
    assert t.find(ip2).data == 2
    t.insert(ip2, 3)
    assert t.find(ip2).data == 3

    ip1 = IP('12.0.0.0/8')
    t.insert(ip1, data=1)
    assert t.parent(ip1) is None
    assert t.parent(ip2) is t.find(ip1)

    ip3 = IP('12.0.0.0/28')
    t.insert(ip3, 4)
    assert t.parent(ip3) is t.find(ip2)
    t.delete(ip2)
    assert t.parent(ip3) is t.find(ip1)

    t.delete_subtree(ip2)
    assert t.find(ip3) is None

    t.delete_subtree(ip1)
    assert t.find(ip1) is None
