$ ndcli create layer3domain l3d-test-1 type vrf rd 0:0

$ ndcli create container 10.0.0.0/8 layer3domain l3d-test-1
INFO - Creating container 10.0.0.0/8 in layer3domain l3d-test-1
$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default

$ ndcli create container 172.16.0.0/12 layer3domain l3d-test-1
INFO - Creating container 172.16.0.0/12 in layer3domain l3d-test-1
$ ndcli create container 172.16.0.0/12 layer3domain default
INFO - Creating container 172.16.0.0/12 in layer3domain default

$ ndcli create pool test-pool-1 layer3domain l3d-test-1
$ ndcli create pool test-pool-default layer3domain default

$ ndcli modify pool test-pool-1 add subnet 10.0.0.0/24 layer3domain:l3d-test-1
INFO - Created subnet 10.0.0.0/24 in layer3domain l3d-test-1
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool test-pool-default add subnet 10.1.0.0/24 layer3domain:default
INFO - Created subnet 10.1.0.0/24 in layer3domain default
WARNING - Creating zone 0.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify pool test-pool-1 add subnet 172.16.0.0/24 layer3domain:l3d-test-1
INFO - Created subnet 172.16.0.0/24 in layer3domain l3d-test-1
WARNING - Creating zone 0.16.172.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool test-pool-default add subnet 172.17.0.0/24 layer3domain:default
INFO - Created subnet 172.17.0.0/24 in layer3domain default
WARNING - Creating zone 0.17.172.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.


$ ndcli list pools
name              vlan subnets
test-pool-1            10.0.0.0/24 172.16.0.0/24
test-pool-default      10.1.0.0/24 172.17.0.0/24

$ ndcli list pool test-pool-1
INFO - Total free IPs: 508
prio subnet      gateway free total
   1 10.0.0.0/24         254   256
   2 172.16.0.0/24          254   256


$ ndcli list pools layer3domain default
name              vlan subnets
test-pool-default      10.1.0.0/24 172.17.0.0/24

$ ndcli list pools layer3domain l3d-test-1
name        vlan subnets
test-pool-1      10.0.0.0/24 172.16.0.0/24

$ ndcli list pools layer3domain l3d-test-1 10.0.0.0/24
INFO - Result for list pools 10.0.0.0/24
name        vlan subnets
test-pool-1      10.0.0.0/24 172.16.0.0/24
$ ndcli list pools layer3domain l3d-test-1 10.1.0.0/24
INFO - Result for list pools 10.1.0.0/24
name vlan subnets

$ ndcli  list pools layer3domain default "*default*"
INFO - Result for list pools *default*
name              vlan subnets
test-pool-default      10.1.0.0/24 172.17.0.0/24
$ ndcli  list pools layer3domain l3d-test-1 "*default*"
INFO - Result for list pools *default*
name vlan subnets
$ ndcli list pools layer3domain l3d-test-1 "*1*"
INFO - Result for list pools *1*
name        vlan subnets
test-pool-1      10.0.0.0/24 172.16.0.0/24