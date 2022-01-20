# make sure the user exists
# as user user
$ ndcli login -u user -p p

# as user admin
$ ndcli create pool testpool
$ ndcli create container 12.0.0.0/8
INFO - Creating container 12.0.0.0/8 in layer3domain default
$ ndcli modify pool testpool add subnet 12.0.0.0/24
INFO - Created subnet 12.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.12.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create user-group testgroup
$ ndcli modify user-group testgroup add user user
$ ndcli modify user-group testgroup grant allocate testpool

# Test with allocate rights
# as user user
$ ndcli modify pool testpool get ip -u user
created:2013-01-17 15:46:17
ip:12.0.0.1
layer3domain:default
mask:255.255.255.0
modified:2013-01-17 15:46:17
modified_by:user
pool:testpool
reverse_zone:0.0.12.in-addr.arpa
status:Static
subnet:12.0.0.0/24
$ ndcli modify pool testpool ip 12.0.0.1 set attrs key:value -u user
$ ndcli show ip 12.0.0.1 -u user
created:2013-01-17 15:46:17
ip:12.0.0.1
key:value
layer3domain:default
mask:255.255.255.0
modified:2013-01-17 15:46:17
modified_by:user
pool:testpool
reverse_zone:0.0.12.in-addr.arpa
status:Static
subnet:12.0.0.0/24
$ ndcli modify pool testpool ip 12.0.0.1 remove attrs key -u user
$ ndcli show ip 12.0.0.1 -u user
created:2013-01-17 15:46:17
ip:12.0.0.1
layer3domain:default
mask:255.255.255.0
modified:2013-01-17 15:46:17
modified_by:user
pool:testpool
reverse_zone:0.0.12.in-addr.arpa
status:Static
subnet:12.0.0.0/24
$ ndcli modify pool testpool free ip 12.0.0.1 -u user
$ ndcli modify pool testpool get delegation /27 -u user
created:2013-01-17 15:46:17
ip:12.0.0.32/27
layer3domain:default
mask:255.255.255.0
modified:2013-01-17 15:46:17
modified_by:user
pool:testpool
reverse_zone:0.0.12.in-addr.arpa
status:Delegation
subnet:12.0.0.0/24
$ ndcli modify pool testpool remove delegation 12.0.0.32/27 -u user

# Test without allocate rights
# as user admin
$ ndcli modify user-group testgroup revoke allocate testpool -u admin -p p
# as user user
$ ndcli modify pool testpool get ip -u user -p p
ERROR - Permission denied (can_allocate testpool)
# as user admin
$ ndcli modify user-group testgroup grant allocate testpool -u admin -p p
$ ndcli modify user-group testgroup remove user user -u admin -p p
# as user user
$ ndcli modify pool testpool get ip -u user -p p
ERROR - Permission denied (can_allocate testpool)

# Test deleting pools while they have accessrights
# as user admin
$ ndcli modify pool testpool remove subnet 12.0.0.0/24 --force --cleanup
INFO - Deleting zone 0.0.12.in-addr.arpa
$ ndcli list user-group testgroup rights
action   object
allocate testpool
$ ndcli delete pool testpool
$ ndcli list user-group testgroup rights
action object
$ ndcli create pool testpool2
$ ndcli modify user-group testgroup grant allocate testpool2
$ ndcli list user-group testgroup rights
action   object
allocate testpool2
$ ndcli delete container 12.0.0.0/8
INFO - Deleting container 12.0.0.0/8 from layer3domain default
