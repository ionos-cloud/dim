$ ndcli create container ::/60
INFO - Creating container ::/60 in layer3domain default
$ ndcli create pool p
$ ndcli modify pool p add subnet ::/64
INFO - Created subnet ::/64 in layer3domain default
WARNING - Creating zone 0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli list pool p
INFO - Total free IPs: 18446744073709551615
prio subnet gateway                 free                total
   1 ::/64          18446744073709551615 18446744073709551616
$ ndcli list pools p
INFO - Result for list pools p
name vlan subnets layer3domain
p         ::/64   default
$ ndcli modify pool p set attrs 'foo:bar'
$ ndcli list pools -a 'name,subnets,foo'
name subnets foo
p    ::/64   bar
