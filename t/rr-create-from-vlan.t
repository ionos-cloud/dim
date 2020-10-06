$ ndcli create pool test2 vlan 2
$ ndcli create pool test3 vlan 3
$ ndcli create pool anotherpool vlan 3
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli modify pool test2 add subnet 1.2.3.0/24 -q
$ ndcli create zone test.com -q
$ ndcli create rr a.test.com. from 2 -q
created:2013-01-23 14:52:48
ip:1.2.3.1
layer3domain:default
mask:255.255.255.0
modified:2013-01-23 14:52:48
modified_by:admin
pool:test2
ptr_target:a.test.com.
reverse_zone:3.2.1.in-addr.arpa
status:Static
subnet:1.2.3.0/24
$ ndcli create rr b.test.com. from 3 -q
ERROR - Multiple pools with vlan 3 exist: anotherpool test3
$ ndcli create rr a.test.com. from 4 -q
ERROR - No pools with vlan 4 exist
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
