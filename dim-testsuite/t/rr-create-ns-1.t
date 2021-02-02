$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de mail hostmaster@a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.a.de. a 1.2.3.4 -q
$ ndcli create rr ns.a.de. cname a -q
$ ndcli create rr web.a.de. cname ns -q
$ ndcli create rr a.de. ns ns -q
ERROR - The target of NS records must have A or AAAA resource records
$ ndcli create rr a.de. ns a -q
$ ndcli create rr a.de. ns ns.example.com.
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ NS ns.example.com. in zone a.de
WARNING - ns.example.com. does not exist.
$ ndcli list zone a.de
record zone ttl   type  value
@      a.de 86400 SOA   localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
a      a.de       A     1.2.3.4
ns     a.de       CNAME a
web    a.de       CNAME ns
@      a.de       NS    a
@      a.de       NS    ns.example.com.
$ ndcli delete rr a.a.de. -R
INFO - Deleting RR 4 PTR a.a.de. from zone 3.2.1.in-addr.arpa
INFO - Deleting RR web CNAME ns from zone a.de
INFO - Deleting RR @ NS a from zone a.de
INFO - Deleting RR a A 1.2.3.4 from zone a.de
INFO - Deleting RR ns CNAME a from zone a.de
INFO - Freeing IP 1.2.3.4 from layer3domain default
$ ndcli list zone 3.2.1.in-addr.arpa
record zone               ttl   type value
@      3.2.1.in-addr.arpa 86400 SOA  localhost. hostmaster.3.2.1.in-addr.arpa. 2012111402 14400 3600 605000 86400
$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
@      a.de       NS   ns.example.com.
$ ndcli delete zone a.de --cleanup
INFO - Deleting RR @ NS ns.example.com. from zone a.de
$ ndcli delete zone 3.2.1.in-addr.arpa
$ ndcli modify pool apool remove subnet 1.2.3.0/24
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
