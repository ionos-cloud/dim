# RP - Responsible Person - rfc1183
# mailbox name and a dns name of a txt record for further information
#
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

$ ndcli create rr foo.a.de. txt "useless information"
INFO - Creating RR foo TXT "useless information" in zone a.de

$ ndcli create rr domainsurfer.a.de. a 10.1.64.102
INFO - Marked IP 10.1.64.102 from layer3domain default as static
INFO - Creating RR domainsurfer A 10.1.64.102 in zone a.de
INFO - Creating RR 102 PTR domainsurfer.a.de. in zone 64.1.10.in-addr.arpa

$ ndcli create rr domainsurfer.a.de. rp john.doe@example.com some-txt-rec.some.domain.
WARNING - TXT Record some-txt-rec.some.domain. not found
INFO - Creating RR domainsurfer RP john\.doe.example.com. some-txt-rec.some.domain. in zone a.de

$ ndcli create rr itodsi-dns.a.de. txt "ITODSI DNS on call system - call -8929 for for assistance."
INFO - Creating RR itodsi-dns TXT "ITODSI DNS on call system - call -8929 for for assistance." in zone a.de

$ ndcli create rr a.de. rp dnsadmin@example.com dim.system.
WARNING - TXT Record dim.system. not found
INFO - Creating RR @ RP dnsadmin.example.com. dim.system. in zone a.de

$ ndcli create rr domainsurfer.a.de. rp john.doe@example.com itodsi-dns.a.de.
WARNING - The name domainsurfer.a.de. already existed, creating round robin record
INFO - Creating RR domainsurfer RP john\.doe.example.com. itodsi-dns.a.de. in zone a.de

$ ndcli delete rr domainsurfer.a.de. rp john.doe@example.com some-txt-rec.some.domain.
INFO - Deleting RR domainsurfer RP john\.doe.example.com. some-txt-rec.some.domain. from zone a.de

$ ndcli list zone a.de view default
record       zone ttl   type value
@            a.de 86400 SOA  localhost. hostmaster.a.de. 2012102603 14400 3600 605000 86400
@            a.de       RP   dnsadmin.example.com. dim.system.
domainsurfer a.de       A    10.1.64.102
domainsurfer a.de       RP   john\.doe.example.com. itodsi-dns.a.de.
foo          a.de       TXT  "useless information"
itodsi-dns   a.de       TXT  "ITODSI DNS on call system - call -8929 for for assistance."

$ ndcli delete zone a.de -q --cleanup

$ ndcli delete zone 64.1.10.in-addr.arpa -q --cleanup
$ ndcli modify pool apool remove subnet 10.1.64.0/25
$ ndcli delete pool apool
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
