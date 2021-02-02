# rfc 6698
# 'TLSA Certificate Usages' 'TLSA Selectors' 'TLSA Matching Types' Certificate/Hash
#
# 'TLSA Certificate Usages' 0-255
# 'TLSA Selectors' 0-255
# 'TLSA Matching Types' 0-255
# Certificate/Hash String up to 64k

$ ndcli create rr _25._tcp.a.de. tlsa 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
INFO - No zone found for _25._tcp.a.de.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr _25._tcp.a.de. tlsa 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
INFO - Creating RR _25._tcp TLSA 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

# help printed instead
# $ ndcli create rr _25._tcp.a.de. tlsa 4 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - TLSA Records have exactly 4 fields

# help printed instead
# $ ndcli create rr _25._tcp.a.de. tlsa 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - TLSA Records have exactly 4 fields

# issue a warning if user supplies values not defined in rfc 6698
$ ndcli create rr _25._tcp.a.de. tlsa 4 2 3 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
WARNING - certificate_usage value 4 is unassigned
WARNING - matching_type value 3 is unassigned
WARNING - selector value 2 is unassigned
WARNING - The name _25._tcp.a.de. already existed, creating round robin record
INFO - Creating RR _25._tcp TLSA 4 2 3 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

# fails because the '-' starts an optional argument
# $ ndcli create rr _25._tcp.a.de. tlsa -1 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - Invalid value for TLSA Certificate Usages supplied, must be 0-255

$ ndcli create rr _25._tcp.a.de. tlsa 256 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid certificate_usage: 256

# fails because the '-' starts an optional argument
# $ ndcli create rr _25._tcp.a.de. tlsa 3 -1 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - Invalid value for TLSA Selectors supplied, must be 0-255

$ ndcli create rr _25._tcp.a.de. tlsa 3 256 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid selector: 256

# fails because the '-' starts an optional argument
# $ ndcli create rr _25._tcp.a.de. tlsa 3 0 -1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - Invalid value for TLSA Matching Types supplied, must be 0-255

$ ndcli create rr _25._tcp.a.de. tlsa 3 0 256 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid matching_type: 256

# Allow usage of abbreveations as defined in rfc 7218
# TLSA Certificate Usages Registry
# +-------+----------+--------------------------------+-------------+
# | Value | Acronym  | Short Description              | Reference   |
# +-------+----------+--------------------------------+-------------+
# |   0   | PKIX-TA  | CA constraint                  | [RFC6698]   |
# |   1   | PKIX-EE  | Service certificate constraint | [RFC6698]   |
# |   2   | DANE-TA  | Trust anchor assertion         | [RFC6698]   |
# |   3   | DANE-EE  | Domain-issued certificate      | [RFC6698]   |
# | 4-254 |          | Unassigned                     |             |
# |  255  | PrivCert | Reserved for Private Use       | [RFC6698]   |
# +-------+----------+--------------------------------+-------------+
#
# TLSA Selectors
# +-------+---------+--------------------------+-------------+
# | Value | Acronym | Short Description        | Reference   |
# +-------+---------+--------------------------+-------------+
# |   0   | Cert    | Full certificate         | [RFC6698]   |
# |   1   | SPKI    | SubjectPublicKeyInfo     | [RFC6698]   |
# | 2-254 |         | Unassigned               |             |
# |  255  | PrivSel | Reserved for Private Use | [RFC6698]   |
# +-------+---------+--------------------------+-------------+
#
# TLSA Matching Types
# +-------+-----------+--------------------------+-------------+
# | Value | Acronym   | Short Description        | Reference   |
# +-------+-----------+--------------------------+-------------+
# |   0   | Full      | No hash used             | [RFC6698]   |
# |   1   | SHA2-256  | 256 bit hash by SHA2     | [RFC6234]   |
# |   2   | SHA2-512  | 512 bit hash by SHA2     | [RFC6234]   |
# | 3-254 |           | Unassigned               |             |
# |  255  | PrivMatch | Reserved for Private Use | [RFC6698]   |
# +-------+-----------+--------------------------+-------------+
#
# Acronyms are case insensitive
$ ndcli create rr _26._tcp.a.de. tlsa DANE-EE 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
INFO - Creating RR _26._tcp TLSA 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

$ ndcli create rr _27._tcp.a.de. tlsa DaNe-eE 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
INFO - Creating RR _27._tcp TLSA 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

$ ndcli create rr _28._tcp.a.de. tlsa DANE-EE cert sha2-256 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
INFO - Creating RR _28._tcp TLSA 3 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

$ ndcli delete zone a.de -q -c