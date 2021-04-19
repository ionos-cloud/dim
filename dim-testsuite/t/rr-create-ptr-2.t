$ ndcli create container 10.0.0.0/8 source:rfc1918
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool tp vlan 12
$ ndcli modify pool tp add subnet 10.1.2.0/24 gw 10.1.2.1
INFO - Created subnet 10.1.2.0/24 in layer3domain default
WARNING - Creating zone 2.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr 10.1.2.25 ptr phuh.com.
INFO - Marked IP 10.1.2.25 from layer3domain default as static
INFO - Creating RR 25 PTR phuh.com. in zone 2.1.10.in-addr.arpa
INFO - No zone found for phuh.com.
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli delete rr 10.1.2.25 ptr phuh.com.
INFO - Deleting RR 25 PTR phuh.com. from zone 2.1.10.in-addr.arpa
INFO - Freeing IP 10.1.2.25 from layer3domain default
$ ndcli modify pool tp remove subnet 10.1.2.0/24
INFO - Deleting zone 2.1.10.in-addr.arpa
$ ndcli delete pool tp
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
