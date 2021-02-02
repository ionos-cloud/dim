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
$ ndcli create layer3domain two type vrf rd 15143:1

$ ndcli create rr a.de. a 10.0.0.1 layer3domain two --allow-overlap -n
INFO - Dryrun mode, no data will be modified
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Zone 0.0.10.in-addr.arpa has no view named two.
WARNING - No reverse zone view found. Only creating forward entry.
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de. layer3domain two --allow-overlap -n
INFO - Dryrun mode, no data will be modified
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Zone 0.0.10.in-addr.arpa has no view named two.
INFO - Creating RR @ A 10.0.0.1 in zone a.de
WARNING - No reverse zone view found. Only creating forward entry.
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de. view default layer3domain two --allow-overlap
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Zone 0.0.10.in-addr.arpa has no view named two.
INFO - Creating RR @ A 10.0.0.1 in zone a.de
WARNING - No reverse zone view found. Only creating forward entry.

$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create pool p2 layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile

# the view parameter is ignored and the correct reverse zone view is used
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de. view default layer3domain two --allow-overlap
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa view two
INFO - a.de. A 10.0.0.1 already exists
