$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool p
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p mark ip 10.0.0.128
created:2017-08-02 11:34:19
ip:10.0.0.128
layer3domain:default
mask:255.255.255.0
modified:2017-08-02 11:34:19
modified_by:admin
pool:p
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24
$ ndcli modify pool p mark delegation 10.0.0.128/31
ERROR - 10.0.0.128/31 from layer3domain default has children

$ ndcli create layer3domain one type vrf rd 0:2
$ ndcli create pool p2
ERROR - A layer3domain is needed
$ ndcli create pool p2 layer3domain one
$ ndcli create container 10.0.0.0/8 layer3domain one
INFO - Creating container 10.0.0.0/8 in layer3domain one
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain one
WARNING - 10.0.0.0/24 in layer3domain one overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view one in zone 0.0.10.in-addr.arpa without profile
$ ndcli modify pool p2 mark delegation 10.0.0.128/31
created:2017-08-02 11:34:19
ip:10.0.0.128/31
layer3domain:one
mask:255.255.255.0
modified:2017-08-02 11:34:19
modified_by:admin
pool:p2
reverse_zone:0.0.10.in-addr.arpa
status:Delegation
subnet:10.0.0.0/24
