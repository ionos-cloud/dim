$ ndcli create layer3domain foo type foo
$ ndcli create layer3domain bar type bar
$ ndcli create pool foo layer3domain foo
$ ndcli create pool bar layer3domain bar
$ ndcli create container 192.168.0.0/16 layer3domain foo
INFO - Creating container 192.168.0.0/16 in layer3domain foo
$ ndcli create container 192.168.0.0/16 layer3domain bar
INFO - Creating container 192.168.0.0/16 in layer3domain bar
$ ndcli modify pool foo add subnet 192.168.42.0/24
INFO - Created subnet 192.168.42.0/24 in layer3domain foo
WARNING - Creating zone 42.168.192.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool bar add subnet 192.168.42.0/24 --allow-overlap
INFO - Created subnet 192.168.42.0/24 in layer3domain bar
WARNING - 192.168.42.0/24 in layer3domain bar overlaps with 192.168.42.0/24 in layer3domain foo
INFO - Creating view bar in zone 42.168.192.in-addr.arpa without profile
$ ndcli modify pool foo get ip
created:2021-12-15 08:35:07.369708
ip:192.168.42.1
layer3domain:foo
mask:255.255.255.0
modified:2021-12-15 08:35:07.369724
modified_by:admin
pool:foo
reverse_zone:42.168.192.in-addr.arpa
status:Static
subnet:192.168.42.0/24
$ ndcli modify pool bar get ip
created:2022-02-09 10:40:26.140923
ip:192.168.42.1
layer3domain:bar
mask:255.255.255.0
modified:2022-02-09 10:40:26.140939
modified_by:admin
pool:bar
reverse_zone:42.168.192.in-addr.arpa
status:Static
subnet:192.168.42.0/24
