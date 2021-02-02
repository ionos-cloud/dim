# deleting the last subnet smaller than /24 deletes the reverse zone
$ ndcli create container 192.0.0.0/8
INFO - Creating container 192.0.0.0/8 in layer3domain default
$ ndcli create pool p
$ ndcli modify pool p add subnet 192.0.2.0/25
INFO - Created subnet 192.0.2.0/25 in layer3domain default
WARNING - Creating zone 2.0.192.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p remove subnet 192\.0\.2\.0/25 -c -f
INFO - Deleting zone 2.0.192.in-addr.arpa
