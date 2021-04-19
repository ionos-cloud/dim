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

# if -H then do not output the INFO
$ ndcli list pool some-pool -H
1	10.0.0.0/24		254	256

$ ndcli modify pool some-pool remove subnet 10.0.0.0/24
INFO - Deleting zone 0.0.10.in-addr.arpa
$ ndcli delete pool some-pool
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
