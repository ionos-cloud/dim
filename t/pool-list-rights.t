$ ndcli create pool some-pool
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify pool some-pool add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list pool some-pool rights
action object group

$ ndcli modify user-group all_users grant allocate some-pool
$ ndcli create user-group testgroup
$ ndcli modify user-group testgroup grant allocate some-pool

$ ndcli list pool some-pool rights
action   object    group
allocate some-pool all_users
allocate some-pool testgroup

$ ndcli modify pool some-pool remove subnet 10.0.0.0/24
INFO - Deleting zone 0.0.10.in-addr.arpa
$ ndcli delete pool some-pool
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
