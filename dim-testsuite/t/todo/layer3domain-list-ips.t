$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool p vlan 10
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list ips 10.0.0.0/24
INFO - Result for list ips 10.0.0.0/24
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Reserved
10.0.0.1 Available
10.0.0.2 Available
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available
$ ndcli list ips p
INFO - Result for list ips p
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Reserved
10.0.0.1 Available
10.0.0.2 Available
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available
$ ndcli list ips 10
INFO - Result for list ips 10
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Reserved
10.0.0.1 Available
10.0.0.2 Available
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available

$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli create pool p2 vlan 2 layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli modify pool p2 mark ip 10.0.0.2
created:2017-12-20 15:00:32.803026
ip:10.0.0.2
layer3domain:two
mask:255.255.255.0
modified:2017-12-20 15:00:32.803039
modified_by:admin
pool:p2
reverse_zone:0.0.10.in-addr.arpa
status:Static
subnet:10.0.0.0/24

$ ndcli list ips p
INFO - Result for list ips p
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Reserved
10.0.0.1 Available
10.0.0.2 Available
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available

$ ndcli list ips 2
INFO - Result for list ips 2
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Reserved
10.0.0.1 Available
10.0.0.2 Static
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available

$ ndcli list ips 10.0.0.0/24
INFO - Result for list ips 10.0.0.0/24
WARNING - More results available
ip       status    ptr_target comment layer3domain
10.0.0.0 Reserved                     default
10.0.0.0 Reserved                     two
10.0.0.1 Available                    default
10.0.0.1 Available                    two
10.0.0.2 Available                    default
10.0.0.2 Static                       two
10.0.0.3 Available                    default
10.0.0.3 Available                    two
10.0.0.4 Available                    default
10.0.0.4 Available                    two

$ ndcli list ips 10.0.0.0/24 -a ip,status,pool,layer3domain
INFO - Result for list ips 10.0.0.0/24
WARNING - More results available
ip       status    pool layer3domain
10.0.0.0 Reserved  p    default
10.0.0.0 Reserved  p2   two
10.0.0.1 Available p    default
10.0.0.1 Available p2   two
10.0.0.2 Available p    default
10.0.0.2 Static    p2   two
10.0.0.3 Available p    default
10.0.0.3 Available p2   two
10.0.0.4 Available p    default
10.0.0.4 Available p2   two

$ ndcli list ips 10.0.0.0/24 -a status,pool
INFO - Result for list ips 10.0.0.0/24
WARNING - More results available
status    pool
Reserved  p
Reserved  p2
Available p
Available p2
Available p
Static    p2
Available p
Available p2
Available p
Available p2

$ ndcli list ips 10.0.0.0/24 layer3domain default
INFO - Result for list ips 10.0.0.0/24
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Reserved
10.0.0.1 Available
10.0.0.2 Available
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available

$ ndcli modify pool p2 remove subnet 10.0.0.0/24 -f -c q
$ ndcli delete pool p2 -q
$ ndcli delete container 10.0.0.0/8 layer3domain two -q
$ ndcli delete layer3domain two -q
$ ndcli modify pool p remove subnet 10.0.0.0/24 -f -c -q
$ ndcli delete pool p -q
$ ndcli delete container 10.0.0.0/8 -q
