# IP overlapping between subnets and ips
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create pool p
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create container 192.168.0.0/16 layer3domain two
INFO - Creating container 192.168.0.0/16 in layer3domain two
$ ndcli create pool p2 layer3domain two

$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p2 add subnet 10.0.0.0/24
ERROR - 10.0.0.0/24 in layer3domain two would overlap with 10.0.0.0/24 in layer3domain default
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli modify pool p2 remove subnet 10.0.0.0/24
INFO - Deleting view two from zone 0.0.10.in-addr.arpa

$ ndcli modify pool p2 add subnet 10.0.0.0/25
ERROR - 10.0.0.0/25 in layer3domain two would overlap with 10.0.0.0/24 in layer3domain default
$ ndcli modify pool p2 add subnet 10.0.0.0/25 --allow-overlap
INFO - Created subnet 10.0.0.0/25 in layer3domain two
WARNING - 10.0.0.0/25 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli modify pool p2 remove subnet 10.0.0.0/25
INFO - Deleting view two from zone 0.0.10.in-addr.arpa

$ ndcli modify pool p2 add subnet 10.0.0.0/23
ERROR - 10.0.0.0/23 in layer3domain two would overlap with 10.0.0.0/24 in layer3domain default
$ ndcli modify pool p2 add subnet 10.0.0.0/23 --allow-overlap
INFO - Created subnet 10.0.0.0/23 in layer3domain two
WARNING - 10.0.0.0/23 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
WARNING - Creating zone 1.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p2 remove subnet 10.0.0.0/23
INFO - Deleting view two from zone 0.0.10.in-addr.arpa
INFO - Deleting zone 1.0.10.in-addr.arpa

$ ndcli create rr a.de. a 192.168.0.1 layer3domain default
INFO - Marked IP 192.168.0.1 from layer3domain default as static
INFO - Creating RR @ A 192.168.0.1 in zone a.de
INFO - No zone found for 1.0.168.192.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli modify pool p2 add subnet 192.168.0.0/24
ERROR - 192.168.0.0/24 in layer3domain two would overlap with 192.168.0.1 in layer3domain default
$ ndcli modify pool p2 add subnet 192.168.0.0/24 --allow-overlap
INFO - Created subnet 192.168.0.0/24 in layer3domain two
WARNING - 192.168.0.0/24 in layer3domain two overlaps with 192.168.0.1 in layer3domain default
WARNING - Creating zone 0.168.192.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create container 11.0.0.0/8 layer3domain two
INFO - Creating container 11.0.0.0/8 in layer3domain two
$ ndcli create container 11.0.0.0/8 layer3domain default
INFO - Creating container 11.0.0.0/8 in layer3domain default

$ ndcli create rr a.de. a 11.0.0.1 layer3domain default
INFO - Marked IP 11.0.0.1 from layer3domain default as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 11.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.11.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli modify pool p2 add subnet 11.0.0.0/24
ERROR - IP Space 11.0.0.1 not whitelisted for duplicate use
$ ndcli modify pool p2 add subnet 11.0.0.0/24 --allow-overlap
ERROR - IP Space 11.0.0.1 not whitelisted for duplicate use
$ ndcli delete rr a.de. a 11.0.0.1
INFO - Deleting RR @ A 11.0.0.1 from zone a.de
INFO - Freeing IP 11.0.0.1 from layer3domain default

$ ndcli modify pool p2 add subnet 11.0.0.0/24
INFO - Created subnet 11.0.0.0/24 in layer3domain two
WARNING - Creating zone 0.0.11.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 11.0.0.1 layer3domain default
ERROR - IP Space 11.0.0.1 not whitelisted for duplicate use

$ ndcli create rr a.de. a 10.0.0.1 layer3domain two
ERROR - 10.0.0.1 in layer3domain two would overlap with 10.0.0.0/24 in layer3domain default
$ ndcli create rr a.de. a 10.0.0.1 layer3domain default --allow-overlap
INFO - Marked IP 10.0.0.1 from layer3domain default as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa
