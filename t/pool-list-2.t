$ ndcli create container ::/60
INFO - Creating container ::/60 in layer3domain default
$ ndcli create pool p
$ ndcli modify pool p add subnet ::/64
INFO - Created subnet ::/64 in layer3domain default
WARNING - Creating zone 0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli list pool p
prio subnet gateway                 free                total
   1 ::/64          18446744073709551615 18446744073709551616
INFO - Total free IPs: 18446744073709551615
$ ndcli list pools p
name vlan subnets
p         ::/64
INFO - Result for list pools p

