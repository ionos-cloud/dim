$ ndcli create container 10.0.0.0/8 source:rfc1918
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool tp vlan 12
$ ndcli modify pool tp add subnet 10.1.2.0/24 gw 10.1.2.1
INFO - Created subnet 10.1.2.0/24 in layer3domain default
WARNING - Creating zone 2.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr mail.one.zone. a 10.1.2.25
INFO - Marked IP 10.1.2.25 from layer3domain default as static
INFO - No zone found for mail.one.zone.
INFO - Creating RR 25 PTR mail.one.zone. in zone 2.1.10.in-addr.arpa
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli delete rr 10.1.2.25 ptr mail.one.zone.
INFO - Deleting RR 25 PTR mail.one.zone. from zone 2.1.10.in-addr.arpa
INFO - Freeing IP 10.1.2.25 from layer3domain default
$ ndcli modify pool tp remove subnet 10.1.2.0/24
INFO - Deleting zone 2.1.10.in-addr.arpa
$ ndcli delete pool tp
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
