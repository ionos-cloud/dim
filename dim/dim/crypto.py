import base64
import math

import Crypto.PublicKey.RSA
import Crypto.Util.number
from Crypto.Util.number import inverse


_file_privkey_rsa = """Private-key-format: v1.2
Algorithm: %(alg)d (%(algtxt)s)
Modulus: %(n)s
PublicExponent: %(e)s
PrivateExponent: %(d)s
Prime1: %(p)s
Prime2: %(q)s
Exponent1: %(dmp1)s
Exponent2: %(dmq1)s
Coefficient: %(u)s
"""


def _rsa2dnskey(key):
    """Get RSA public key in DNSKEY resource record format (RFC-3110)"""
    octets = b''
    explen = int(math.ceil(math.log(key.e, 2)/8))
    if explen > 255:
        octets = "\x00"
    octets += (Crypto.Util.number.long_to_bytes(explen) +
               Crypto.Util.number.long_to_bytes(key.e) +
               Crypto.Util.number.long_to_bytes(key.n))
    return octets


def generate_RSASHA256_key_pair(bits):
    key = Crypto.PublicKey.RSA.generate(bits)
    pubkey = base64.b64encode(_rsa2dnskey(key))
    RSASHA256 = 8
    keydata = dict(alg=RSASHA256,
                   algtxt='RSASHA256')
    for field in ['n', 'e', 'd', 'p', 'q', 'u']:
        f = getattr(key, field)
        f = Crypto.Util.number.long_to_bytes(f)
        keydata[field] = base64.b64encode(f).decode('utf-8')
    dmp1 = Crypto.Util.number.long_to_bytes(key.d % (key.p - 1))
    keydata['dmp1'] = base64.b64encode(dmp1).decode('utf-8')
    dmq1 = Crypto.Util.number.long_to_bytes(key.d % (key.q - 1))
    keydata['dmq1'] = base64.b64encode(dmq1).decode('utf-8')
    # key.u == inverse(p, q), but rfc3447 needs inverse(q, p)
    u = Crypto.Util.number.long_to_bytes(inverse(key.q, key.p))
    keydata['u'] = base64.b64encode(u).decode('utf-8')
    privkey = _file_privkey_rsa % keydata
    return (pubkey, privkey)
