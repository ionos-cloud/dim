$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create pool p
$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create pool p2 layer3domain two

$ ndcli create rr a.de. a 10.0.0.1 -n
INFO - Dryrun mode, no data will be modified
ERROR - A layer3domain is needed

# containers in one l3d
$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create rr a.de. a 10.0.0.1 -n
INFO - Dryrun mode, no data will be modified
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create container 10.0.0.0/16 layer3domain default
INFO - Creating container 10.0.0.0/16 in layer3domain default
$ ndcli create rr a.de. a 10.0.0.1 -n
INFO - Dryrun mode, no data will be modified
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

# containers in multiple l3d
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create rr a.de. a 10.0.0.1 -n
INFO - Dryrun mode, no data will be modified
ERROR - A layer3domain is needed

# only 1 subnet
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1 -n
INFO - Dryrun mode, no data will be modified
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa

# multiple subnets
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli create rr a.de. a 10.0.0.1 -n
INFO - Dryrun mode, no data will be modified
ERROR - A layer3domain is needed
