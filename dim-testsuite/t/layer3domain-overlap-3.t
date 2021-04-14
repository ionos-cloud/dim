# Overlap checks should not be performed when using ips from pools
$ ndcli create layer3domain two type vrf rd 15143:1

$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two

$ ndcli create pool p layer3domain default
$ ndcli create pool p2 layer3domain two

$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile

$ ndcli modify pool p get delegation 30
created:2017-10-10 16:17:05.628826
ip:10.0.0.4/30
layer3domain:default
mask:255.255.255.0
modified:2017-10-10 16:17:05.628838
modified_by:admin
pool:p
reverse_zone:0.0.10.in-addr.arpa
status:Delegation
subnet:10.0.0.0/24
$ ndcli modify pool p delegation 10.0.0.4/30 get ip
created:2017-10-10 16:48:37.306923
delegation:10.0.0.4/30
ip:10.0.0.4
layer3domain:default
mask:255.255.255.0
modified:2017-10-10 16:48:37.306938
modified_by:admin
pool:p
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24
$ ndcli modify pool p delegation 10.0.0.4/30 mark ip 10.0.0.5 a:b
a:b
created:2017-10-10 16:48:37.332752
delegation:10.0.0.4/30
ip:10.0.0.5
layer3domain:default
mask:255.255.255.0
modified:2017-10-10 16:48:37.340478
modified_by:admin
pool:p
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24
$ ndcli modify pool p get ip
created:2017-10-10 16:17:05.655110
ip:10.0.0.1
layer3domain:default
mask:255.255.255.0
modified:2017-10-10 16:17:05.655125
modified_by:admin
pool:p
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. from p
INFO - Marked IP 10.0.0.2 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.2 in zone a.de
INFO - Creating RR 2 PTR a.de. in zone 0.0.10.in-addr.arpa view default
created:2017-10-10 16:48:37.413313
ip:10.0.0.2
layer3domain:default
mask:255.255.255.0
modified:2017-10-10 16:48:37.413334
modified_by:admin
pool:p
ptr_target:a.de.
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24
