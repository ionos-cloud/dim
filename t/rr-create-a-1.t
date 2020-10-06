$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.a.de. a 1.2.3.4 -q
$ ndcli create rr a.a.de. a 1.2.3.4 -q
$ ndcli create rr a.a.de. a 1.2.3.4
INFO - a.a.de. A 1.2.3.4 already exists
INFO - 4.3.2.1.in-addr.arpa. PTR a.a.de. already exists
$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
a      a.de       A    1.2.3.4
$ ndcli delete rr a.a.de. a 1.2.3.4 -q
$ ndcli list zone 3.2.1.in-addr.arpa
record zone               ttl   type value
@      3.2.1.in-addr.arpa 86400 SOA  localhost. hostmaster.3.2.1.in-addr.arpa. 2012111402 14400 3600 605000 86400
$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
$ ndcli list ips 1.2.3.0/29
ip      status    ptr_target comment
1.2.3.0 Reserved         
1.2.3.1 Available        
1.2.3.2 Available        
1.2.3.3 Available        
1.2.3.4 Available
1.2.3.5 Available
1.2.3.6 Available
1.2.3.7 Available
INFO - Result for list ips 1.2.3.0/29
$ ndcli delete zone a.de
$ ndcli delete zone 3.2.1.in-addr.arpa
$ ndcli modify pool apool remove subnet 1.2.3.0/24
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
