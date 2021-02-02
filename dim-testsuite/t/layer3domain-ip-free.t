# deleting A/AAAA rrs also deletes references to it
$ ndcli create pool p
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
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

$ ndcli create zone b.de
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr b.b.de. cname a.de.
INFO - Creating RR b CNAME a.de. in zone b.de

$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create pool p2 layer3domain two
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli create rr a.de. a 10.0.0.1 layer3domain two
INFO - Marked IP 10.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa view two

$ ndcli modify pool p free ip 10.0.0.1
INFO - Deleting RR 1 PTR a.de. from zone 0.0.10.in-addr.arpa view default
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Freeing IP 10.0.0.1 from layer3domain default

$ ndcli delete rr a.de. a 10.0.0.1
ERROR - a.de. is referenced by other records

$ ndcli delete rr a.de. a 10.0.0.1 -R
INFO - Deleting RR 1 PTR a.de. from zone 0.0.10.in-addr.arpa view two
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Deleting RR b CNAME a.de. from zone b.de
INFO - Freeing IP 10.0.0.1 from layer3domain two
