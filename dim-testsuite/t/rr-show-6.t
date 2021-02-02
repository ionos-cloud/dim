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

$ ndcli create rr a.a.de. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR a A 1.2.3.4 in zone a.de
INFO - Creating RR 4 PTR a.a.de. in zone 3.2.1.in-addr.arpa

$ ndcli show rr 4.3.2.1.in-addr.arpa.
created:2013-01-18 16:52:20
created_by:admin
modified:2013-01-18 16:52:20
modified_by:admin
rr:4 PTR a.a.de.
zone:3.2.1.in-addr.arpa

$ ndcli show rr 4.3.2.1.in-addr.arpa. ptr
created:2013-01-18 16:52:20
created_by:admin
modified:2013-01-18 16:52:20
modified_by:admin
rr:4 PTR a.a.de.
zone:3.2.1.in-addr.arpa

$ ndcli show rr 1.2.3.4 ptr
created:2013-01-18 16:52:20
created_by:admin
modified:2013-01-18 16:52:20
modified_by:admin
rr:4 PTR a.a.de.
zone:3.2.1.in-addr.arpa
