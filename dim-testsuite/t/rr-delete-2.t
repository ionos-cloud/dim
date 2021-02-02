# ndcli delete rr <name> <typ> [<value>] [[[-R|--recursive]|-f|--force] [--keep-ip-reservation]|[-n]]
# test -R -n
$ ndcli create container 2001:db8::/32 source:rfc3849
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli create container 10.0.0.0/8 source:rfc1918
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool tp1_v6 vlan 12
$ ndcli modify pool tp1_v6 add subnet 2001:db8:be:ef::/64 gw 2001:db8:be:ef::1 --no-default-reserve
INFO - Created subnet 2001:db8:be:ef::/64 in layer3domain default
WARNING - Creating zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool tp1_v6 get delegation 112 "comment:Networking Equipment"
comment:Networking Equipment
created:2012-11-15 14:31:35
gateway:2001:db8:be:ef::1
ip:2001:db8:be:ef::/112
layer3domain:default
modified:2012-11-15 14:31:35
modified_by:user
pool:tp1_v6
prefixlength:64
reverse_zone:f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
status:Delegation
subnet:2001:db8:be:ef::/64
$ ndcli create pool tp1 vlan 12
$ ndcli modify pool tp1 add subnet 10.1.2.0/24 gw 10.1.2.1
INFO - Created subnet 10.1.2.0/24 in layer3domain default
WARNING - Creating zone 2.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.1.2.2 -q
$ ndcli create rr a.de. aaaa 2001:db8:be:ef::1:1 -q
$ ndcli list zone a.de
record zone ttl   type  value
@      a.de 86400 SOA   localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
@      a.de       A     10.1.2.2
@      a.de       AAAA  2001:db8:be:ef::1:1

$ ndcli delete rr a.de. -n
INFO - Dryrun mode, no data will be modified
ERROR - a.de. is ambiguous
$ ndcli delete rr a.de.
ERROR - a.de. is ambiguous

$ ndcli create rr www.a.de. cname a.de. -q
$ ndcli create rr web.a.de. cname www.a.de. -q

$ ndcli delete rr a.de. a 10.1.2.2 -q
$ ndcli delete rr a.de. aaaa 2001:db8:be:ef::1:1 -q
ERROR - a.de. is referenced by other records

$ ndcli delete rr a.de. aaaa 2001:db8:be:ef::1:1 -f -n
INFO - Dryrun mode, no data will be modified
WARNING - a.de. is referenced by other records
INFO - Deleting RR 1.0.0.0.1.0.0.0.0.0.0.0.0.0.0.0 PTR a.de. from zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ AAAA 2001:db8:be:ef::1:1 from zone a.de
INFO - Freeing IP 2001:db8:be:ef::1:1 from layer3domain default

$ ndcli delete rr a.de. aaaa 2001:db8:be:ef::1:1 -f -n --keep-ip-reservation
INFO - Dryrun mode, no data will be modified
WARNING - a.de. is referenced by other records
INFO - Deleting RR 1.0.0.0.1.0.0.0.0.0.0.0.0.0.0.0 PTR a.de. from zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ AAAA 2001:db8:be:ef::1:1 from zone a.de

$ ndcli delete rr a.de aaaa 2001:db8:be:ef::1:1 -f -R
ERROR - --force and --recursive can not be combined

$ ndcli delete rr a.de. aaaa 2001:db8:be:ef::1:1 -R
INFO - Deleting RR web CNAME www.a.de. from zone a.de
INFO - Deleting RR 1.0.0.0.1.0.0.0.0.0.0.0.0.0.0.0 PTR a.de. from zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ AAAA 2001:db8:be:ef::1:1 from zone a.de
INFO - Deleting RR www CNAME a.de. from zone a.de
INFO - Freeing IP 2001:db8:be:ef::1:1 from layer3domain default

$ ndcli modify pool tp1_v6 remove delegation 2001:db8:be:ef::/112
$ ndcli modify pool tp1_v6 remove subnet 2001:db8:be:ef::/64
INFO - Deleting zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli delete pool tp1_v6
$ ndcli modify pool tp1 remove subnet 10.1.2.0/24
INFO - Deleting zone 2.1.10.in-addr.arpa
$ ndcli delete pool tp1
$ ndcli delete zone a.de
$ ndcli delete container 2001:db8::/32
INFO - Deleting container 2001:db8::/32 from layer3domain default
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
