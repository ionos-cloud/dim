

from ipaddress import ip_address, IPv4Address, IPv6Address, ip_network
from typing import Literal


def valid_block(addr):
    try:
        ip_network(str(addr))
        return True
    except ValueError:
        return False


class IP(object):
    slots = ('version', 'address', 'prefix')

    def __init__(self, address, prefix=None, version=None, auto_correct=False):
        '''
        :param auto_correct: if the address has bits set outside its netmask they will be cleared
        '''
        if isinstance(address, str):
            s = address.split('/')
            if len(s) > 2:
                raise ValueError('Bad prefix')
            if len(s) == 2:
                ip = ip_address(s[0])
                self.prefix = int(s[1])
                self.version = ip.version
            else:
                ip = ip_address(address)
                self.prefix = ip.max_prefixlen
            self.address = ip._ip
            self.version = ip.version
        else:
            self.address = address
            self.version = version
            self.prefix = prefix if prefix is not None else self.bits
        if self.version not in (4, 6):
            raise ValueError('Invalid IP version %s' % repr(version))
        if not (self.prefix >= 0 and self.prefix <= self.bits):
            raise ValueError('Invalid IP prefix %s' % repr(prefix))
        if self.address & self.hostmask != 0:
            if auto_correct:
                self.address &= self.netmask
            else:
                raise ValueError('Invalid IP %s (not base address of the block)' % str(self))

    def __str__(self):
        return self.label(expanded=False)

    def __eq__(self, other):
        return (self.version, self.address, self.prefix) == (other.version, other.address, other.prefix)

    def __ne__(self, other):
        return not self == other

    def label(self, expanded=False):
        tmp = IPv4Address(self.address) if self.version == 4 else IPv6Address(self.address)
        if expanded:
            ret = tmp.exploded
        else:
            ret = tmp.compressed
        if self.prefix == self.bits:
            return ret
        else:
            return ret + "/" + str(self.prefix)

    @property
    def bits(self) -> Literal[32, 128]:
        return 32 if self.version == 4 else 128

    @property
    def is_host(self):
        return self.prefix == self.bits

    @property
    def hostmask(self):
        return 2 ** (self.bits - self.prefix) - 1

    @property
    def netmask(self):
        return (2 ** self.bits - 1) ^ self.hostmask

    @property
    def network(self):
        return IP(self.address, self.bits, self.version)

    @property
    def broadcast(self):
        return IP(self.address | self.hostmask, self.bits, self.version)

    @property
    def numhosts(self) -> int:
        return self.broadcast.address - self.network.address + 1

    def __contains__(self, item):
        if self.version != item.version:
            return False
        if self.prefix > item.prefix:
            return False
        if self.address & self.netmask == item.address & self.netmask:
            return True
        else:
            return False
