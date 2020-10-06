$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool p
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa

$ ndcli create layer3domain two type vrf rd 15143:1
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create pool p2 layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli create rr two.a.de. a 10.0.0.1 layer3domain two --allow-overlap
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Creating RR two A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR two.a.de. in zone 0.0.10.in-addr.arpa view two

$ ndcli show ipblock 10.0.0.1
ERROR - A layer3domain is needed
$ ndcli show ipblock 10.0.0.1 layer3domain default
created:2017-10-19 15:58:49
ip:10.0.0.1
layer3domain:default
mask:255.255.255.0
modified:2017-10-19 15:58:49
modified_by:admin
pool:p
ptr_target:a.de.
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24
$ ndcli show ipblock 10.0.0.1 layer3domain two
created:2017-10-19 15:58:49
ip:10.0.0.1
layer3domain:two
mask:255.255.255.0
modified:2017-10-19 15:58:49
modified_by:admin
pool:p2
ptr_target:two.a.de.
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24
