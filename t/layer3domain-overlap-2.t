# IP overlapping between subnets and ips
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create layer3domain two type vrf rd 0:2

$ ndcli create rr a.de. a 10.0.0.1 layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.de. a 10.0.0.1 layer3domain two
ERROR - 10.0.0.1 in layer3domain two would overlap with 10.0.0.1 in layer3domain default
$ ndcli modify zone a.de create rr a.de. a 10.0.0.1 layer3domain two
ERROR - 10.0.0.1 in layer3domain two would overlap with 10.0.0.1 in layer3domain default
$ ndcli modify zone a.de create rr a.de. a 10.0.0.1 layer3domain two --allow-overlap
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.1 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
$ ndcli delete rr a.de. a 10.0.0.1 layer3domain two
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Freeing IP 10.0.0.1 from layer3domain two

$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create pool p2 layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.1 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

# Overlap checks are not performed when using an ip from a pool implicitly
$ ndcli create rr a.de. a 10.0.0.1 layer3domain two
INFO - Marked IP 10.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa
$ ndcli delete rr a.de. a 10.0.0.1 layer3domain two
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Deleting RR 1 PTR a.de. from zone 0.0.10.in-addr.arpa
INFO - Freeing IP 10.0.0.1 from layer3domain two
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de.
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de

$ ndcli delete pool p2 -f
$ ndcli delete rr a.de. a 10.0.0.1 layer3domain two
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Deleting RR 1 PTR a.de. from zone 0.0.10.in-addr.arpa
INFO - Freeing IP 10.0.0.1 from layer3domain two
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de.
ERROR - 10.0.0.1 in layer3domain two would overlap with 10.0.0.1 in layer3domain default
$ ndcli create rr 1.0.0.10.in-addr.arpa. ptr a.de. --allow-overlap
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.1 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de

$ ndcli create rr a.de. a 1.0.0.1 layer3domain two
INFO - Marked IP 1.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 1.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr 1.0.0.1.in-addr.arpa. ptr a.de. layer3domain default
ERROR - IP Space 1.0.0.1 not whitelisted for duplicate use
