from dim.ipaddr import IP


def test_mask():
    ip1 = IP('12.0.0.0/24')
    assert ip1.hostmask == 0x000000ff
    assert ip1.netmask == 0xffffff00


def test_contains():
    ip1 = IP('12.0.0.0/25')
    ip2 = IP('12.0.0.0/24')
    assert ip1 in ip2
    assert ip2 not in ip1
    assert ip1 in ip1

    assert IP('12.0.0.2') in ip1
