$ ndcli list containers 10.0.0.0/8
ERROR - No containers matching '10.0.0.0/8' exist in layer3domain default

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create container 10.0.0.0/8
ERROR - 10.0.0.0/8 already exists in layer3domain default with status Container

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli list containers 10.0.0.1
ERROR - 10.0.0.1 from layer3domain default is not a Container

$ ndcli create rr a.de. a 10.0.0.0
INFO - Marked IP 10.0.0.0 from layer3domain default as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.0 in zone a.de
INFO - No zone found for 0.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create pool p
$ ndcli modify pool p add subnet 10.0.0.1
ERROR - '10.0.0.1' from layer3domain default cannot be added to a pool because it is a Static

$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - 10.0.0.0 from layer3domain default is already allocated with status Static
$ ndcli modify pool p add subnet 10.0.0.0/24
ERROR - The subnet '10.0.0.0/24' from layer3domain 'default' is already part of the pool 'p'

$ ndcli create pool p2
$ ndcli modify pool p2 add subnet 10.0.0.0/24
ERROR - The subnet '10.0.0.0/24' from layer3domain 'default' cannot be added to the pool 'p2' because it is part of the pool 'p'

$ ndcli modify pool p mark ip 10.0.0.1
ERROR - 10.0.0.1 from layer3domain default is already allocated with status Static

$ ndcli modify pool p mark ip 10.1.0.0
ERROR - '10.1.0.0' from layer3domain 'default' is not part of the pool 'p'

$ ndcli modify pool p get delegation 30
created:2017-10-16 16:51:32.257964
ip:10.0.0.4/30
layer3domain:default
mask:255.255.255.0
modified:2017-10-16 16:51:32.257976
modified_by:admin
pool:p
reverse_zone:0.0.10.in-addr.arpa
status:Delegation
subnet:10.0.0.0/24
$ ndcli modify pool p delegation 10.0.0.1/32 free ip 10.0.0.1
ERROR - 10.0.0.1 from layer3domain default is not a Delegation

$ ndcli modify pool p delegation 10.0.0.4/30 free ip 10.0.0.1
ERROR - 10.0.0.1 from layer3domain default is not part of the delegation 10.0.0.4/30

$ ndcli modify pool p remove subnet 10.0.0.1
ERROR - 10.0.0.1 from layer3domain default is a Static block (expected 'Subnet')
