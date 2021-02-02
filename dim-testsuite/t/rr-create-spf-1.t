# DNS character-strings must be filtered to contain only printable US-ASCII
# characters.
# a-zA-Z0-9,.-;:_#+*~!"$%&/()=?\^<>|{[]}'`@ or
# simpler characters from (decimal) 32 to 126.

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool apool vlan 300

$ ndcli modify pool apool add subnet 10.1.64.0/25 gw 10.1.64.127
INFO - Created subnet 10.1.64.0/25 in layer3domain default
WARNING - Creating zone 64.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

# SPF Records are just like TXT records. Why they have been invented...
# see rfc4408
# a strings maximum length is 255 char
# rfc4408 (section 3.1.3), rfc1035
# strings are automatically chopped (with warning)

$ ndcli create rr a.de. spf "v=spf1 ip4:82.165.0.0/16 ~all"
INFO - Creating RR @ SPF "v=spf1 ip4:82.165.0.0/16 ~all" in zone a.de

$ ndcli modify zone a.de create view public -q

$ ndcli create rr a.de. spf "v=spf1 ip4:82.165.0.0/16 ip4:195.20.224.0/19 ip4:212.227.0.0/16 ip4:87.106.0.0/16 ip4:217.160.0.0/16 ip4:213.165.64.0/19 ip4:217.72.192.0/20 ip4:74.208.0.0/17 ip4:74.208.128.0/18 ip4:66.236.18.66 ip4:67.88.206.40 ip4:67.88.206.48 ~all" view public
INFO - Creating RR @ SPF "v=spf1 ip4:82.165.0.0/16 ip4:195.20.224.0/19 ip4:212.227.0.0/16 ip4:87.106.0.0/16 ip4:217.160.0.0/16 ip4:213.165.64.0/19 ip4:217.72.192.0/20 ip4:74.208.0.0/17 ip4:74.208.128.0/18 ip4:66.236.18.66 ip4:67.88.206.40 ip4:67.88.206.48 ~all" in zone a.de view public

$ ndcli list zone a.de view default
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2013010402 14400 3600 605000 86400
@      a.de       SPF  "v=spf1 ip4:82.165.0.0/16 ~all"

$ ndcli list zone a.de view public
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2013010402 14400 3600 605000 86400
@      a.de       SPF  "v=spf1 ip4:82.165.0.0/16 ip4:195.20.224.0/19 ip4:212.227.0.0/16 ip4:87.106.0.0/16 ip4:217.160.0.0/16 ip4:213.165.64.0/19 ip4:217.72.192.0/20 ip4:74.208.0.0/17 ip4:74.208.128.0/18 ip4:66.236.18.66 ip4:67.88.206.40 ip4:67.88.206.48 ~all"

$ ndcli delete rr a.de. spf view default
INFO - Deleting RR @ SPF "v=spf1 ip4:82.165.0.0/16 ~all" from zone a.de view default

$ ndcli modify zone a.de delete view default -q --cleanup
$ ndcli delete zone a.de -q --cleanup

$ ndcli delete zone 64.1.10.in-addr.arpa -q --cleanup
$ ndcli modify pool apool remove subnet 10.1.64.0/25
$ ndcli delete pool apool
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
