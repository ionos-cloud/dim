# removing the last subnet in a l3d smaller than /24 deletes the reverse zone (or view)
$ ndcli create layer3domain two type vrf rd 0:2

$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool p layer3domain default
$ ndcli modify pool p add subnet 10.0.0.0/25
INFO - Created subnet 10.0.0.0/25 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create pool p2 layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.128/25 --allow-overlap
INFO - Created subnet 10.0.0.128/25 in layer3domain two
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile

$ ndcli modify pool p remove subnet 10.0.0.0/25
INFO - Deleting view default from zone 0.0.10.in-addr.arpa
$ ndcli modify pool p2 remove subnet 10.0.0.128/25
INFO - Deleting zone 0.0.10.in-addr.arpa
