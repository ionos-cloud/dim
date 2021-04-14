# list ips vlan
$ ndcli create container 212.227.0.0/16
INFO - Creating container 212.227.0.0/16 in layer3domain default
$ ndcli create container 217.0.0.0/8
INFO - Creating container 217.0.0.0/8 in layer3domain default
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default

$ ndcli create pool xxl1_rfc1918 vlan 35
$ ndcli modify pool xxl1_rfc1918 add subnet 10.120.31.0/24 gw 10.120.31.1
INFO - Created subnet 10.120.31.0/24 in layer3domain default
WARNING - Creating zone 31.120.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli list ips 35
INFO - Result for list ips 35
WARNING - More results available
ip          status    ptr_target comment
10.120.31.0 Reserved
10.120.31.1 Available
10.120.31.2 Available
10.120.31.3 Available
10.120.31.4 Available
10.120.31.5 Available
10.120.31.6 Available
10.120.31.7 Available
10.120.31.8 Available
10.120.31.9 Available

$ ndcli create pool xxl1_public vlan 35
$ ndcli modify pool xxl1_public add subnet 217.72.199.0/24 gw 217.72.199.1
INFO - Created subnet 217.72.199.0/24 in layer3domain default
WARNING - Creating zone 199.72.217.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list ips 35
ERROR - Multiple pools with vlan 35 exist: xxl1_public xxl1_rfc1918

$ ndcli modify pool xxl1_public remove subnet 217.72.199.0/24
INFO - Deleting zone 199.72.217.in-addr.arpa
$ ndcli delete pool xxl1_public

$ ndcli modify pool xxl1_rfc1918 remove subnet 10.120.31.0/24
INFO - Deleting zone 31.120.10.in-addr.arpa
$ ndcli delete pool xxl1_rfc1918

$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
$ ndcli delete container 212.227.0.0/16
INFO - Deleting container 212.227.0.0/16 from layer3domain default
$ ndcli delete container 217.0.0.0/8
INFO - Deleting container 217.0.0.0/8 from layer3domain default
