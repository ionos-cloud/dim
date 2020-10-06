$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1 layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.de. a 10.0.0.1 layer3domain two --allow-overlap
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.1 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli delete rr a.de. a 10.0.0.1
ERROR - A layer3domain is needed
$ ndcli delete rr a.de. a 10.0.0.1 layer3domain two
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Freeing IP 10.0.0.1 from layer3domain two
$ ndcli delete rr a.de. a 10.0.0.1
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Freeing IP 10.0.0.1 from layer3domain default
