$ ndcli create layer3domain two type vrf rd 15143:1

$ ndcli create container 10.0.0.0/8
ERROR - A layer3domain is needed

$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default

$ ndcli create pool foo
ERROR - A layer3domain is needed

$ ndcli create pool foo layer3domain default

$ ndcli modify pool foo add subnet 10.128.12.0/24
INFO - Created subnet 10.128.12.0/24 in layer3domain default
WARNING - Creating zone 12.128.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create pool fuh layer3domain two

$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two

$ ndcli modify pool fuh add subnet 10.128.12.128/25 --allow-overlap
INFO - Created subnet 10.128.12.128/25 in layer3domain two
WARNING - 10.128.12.128/25 in layer3domain two overlaps with 10.128.12.0/24 in layer3domain default
INFO - Creating view two in zone 12.128.10.in-addr.arpa without profile

$ ndcli create zone some.zone
WARNING - Creating zone some.zone without profile
WARNING - Primary NS for this Domain is now localhost.

# unsafe guess, user could have wanted layer3domian two
$ ndcli create rr one.some.zone. a 10.128.12.2
INFO - Marked IP 10.128.12.2 from layer3domain default as static
INFO - Creating RR one A 10.128.12.2 in zone some.zone
INFO - Creating RR 2 PTR one.some.zone. in zone 12.128.10.in-addr.arpa view default

$ ndcli create rr twoand.some.zone. a 10.129.12.2 layer3domain two
INFO - Marked IP 10.129.12.2 from layer3domain two as static
INFO - Creating RR twoand A 10.129.12.2 in zone some.zone
INFO - No zone found for 2.12.129.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr two.some.zone. a 10.128.12.130
ERROR - A layer3domain is needed

$ ndcli create rr two.some.zone. a 10.128.12.130 layer3domain two
INFO - Marked IP 10.128.12.130 from layer3domain two as static
INFO - Creating RR two A 10.128.12.130 in zone some.zone
INFO - Creating RR 130 PTR two.some.zone. in zone 12.128.10.in-addr.arpa view two

# In general it is a very, very bad idea do mix A records from more than one layer3doamins
# in forward zone. But I do not think I can just ban it.

$ ndcli delete zone some.zone -c -q

$ ndcli modify pool foo remove subnet 10.128.12.0/24 -c -f -q
$ ndcli delete pool foo

$ ndcli modify pool fuh remove subnet 10.128.12.128/25 -c -f -q
$ ndcli delete pool fuh

$ ndcli delete container 10.0.0.0/8 layer3domain default
INFO - Deleting container 10.0.0.0/8 from layer3domain default
$ ndcli delete container 10.0.0.0/8 layer3domain two
INFO - Deleting container 10.0.0.0/8 from layer3domain two

$ ndcli delete layer3domain two

