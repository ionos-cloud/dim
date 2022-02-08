# verify a pool's subnets are listed ordered by priority
$ ndcli create pool some-pool
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify pool some-pool add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli list pool some-pool
INFO - Total free IPs: 254
prio subnet      gateway free total
   1 10.0.0.0/24         254   256

$ ndcli modify pool some-pool add subnet 10.0.9.0/24
INFO - Created subnet 10.0.9.0/24 in layer3domain default
WARNING - Creating zone 9.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify pool some-pool add subnet 10.0.5.0/24
INFO - Created subnet 10.0.5.0/24 in layer3domain default
WARNING - Creating zone 5.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list pool some-pool
INFO - Total free IPs: 762
prio subnet      gateway free total
   1 10.0.0.0/24          254   256
   2 10.0.9.0/24          254   256
   3 10.0.5.0/24          254   256

$ ndcli modify pool some-pool add subnet 10.0.10.0/24
INFO - Created subnet 10.0.10.0/24 in layer3domain default
WARNING - Creating zone 10.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list pool some-pool
INFO - Total free IPs: 1016
prio subnet      gateway free total
   1 10.0.0.0/24          254   256
   2 10.0.9.0/24          254   256
   3 10.0.5.0/24          254   256
   4 10.0.10.0/24         254   256

$ ndcli modify pool some-pool subnet 10.0.10.0/24 set prio 1

$ ndcli list pool some-pool
INFO - Total free IPs: 1016
prio subnet       gateway free total
   1 10.0.10.0/24          254   256
   2 10.0.0.0/24           254   256
   3 10.0.9.0/24           254   256
   4 10.0.5.0/24           254   256
