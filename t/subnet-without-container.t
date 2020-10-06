# DIM-203 A subnet must always have a container as a parent
$ ndcli create pool testp
$ ndcli modify pool testp add subnet 10.0.0.0/24
ERROR - Subnet 10.0.0.0/24 has no parent container

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify pool testp add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
