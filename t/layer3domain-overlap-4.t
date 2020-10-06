# Cannot create A records when another layer3domain has subnets
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create layer3domain two type vrf rd 0:2

$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create pool p2 layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr a.de. a 10.0.0.1 layer3domain default
ERROR - 10.0.0.1 in layer3domain default would overlap with 10.0.0.0/24 in layer3domain two
$ ndcli create rr a.de. a 10.0.0.1 layer3domain default --allow-overlap -n
INFO - Dryrun mode, no data will be modified
WARNING - 10.0.0.1 in layer3domain default overlaps with 10.0.0.0/24 in layer3domain two
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Zone 0.0.10.in-addr.arpa has no view named default.
WARNING - No reverse zone view found. Only creating forward entry.
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de. layer3domain default --allow-overlap
WARNING - 10.0.0.1 in layer3domain default overlaps with 10.0.0.0/24 in layer3domain two
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Zone 0.0.10.in-addr.arpa has no view named default.
INFO - Creating RR @ A 10.0.0.1 in zone a.de
WARNING - No reverse zone view found. Only creating forward entry.
