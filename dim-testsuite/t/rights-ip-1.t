# Create a user with network_admin rights and a regular user
$ ndcli login -u user -p p
$ ndcli login -u network -p p
$ ndcli login -u admin -p p
$ ndcli create user-group networkgroup
$ ndcli modify user-group networkgroup grant network_admin
$ ndcli modify user-group networkgroup add user network

# network_admin user
$ ndcli login -u network -p p
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

# Regular user
$ ndcli login -u user -p p
$ ndcli create pool testpool2
ERROR - Permission denied (can_network_admin)
$ ndcli list pool testpool
INFO - Total free IPs: 254
prio subnet      gateway free total
   1 12.0.0.0/24          254   256
$ ndcli create user-group testgroup2
ERROR - Permission denied (can_create_groups)
$ ndcli modify user-group testgroup add user user
ERROR - Permission denied (can_edit_group testgroup)
$ ndcli modify user-group testgroup remove user user
ERROR - Permission denied (can_edit_group testgroup)
$ ndcli modify user-group testgroup grant allocate testpool
ERROR - Permission denied (can_network_admin)

# Test deleting groups while they still have members
$ ndcli login -u network -p p
$ ndcli create user-group testgroup2
$ ndcli modify user-group testgroup2 add user user
$ ndcli list user user groups
group
all_users
testgroup
testgroup2
$ ndcli delete user-group testgroup2
$ ndcli list user user groups
group
all_users
testgroup

# network_admin users cannot grant network_admin rights
$ ndcli modify user-group testgroup grant network_admin
ERROR - Permission denied (can_grant_access testgroup network_admin)
# network_admin users cannot change network_admin groups
$ ndcli modify user-group networkgroup add user user
ERROR - Permission denied (can_edit_group networkgroup)
# network_admin users can rename and delete normal groups
$ ndcli rename user-group testgroup to testgroup1
$ ndcli delete user-group testgroup1
$ ndcli delete container 12.0.0.0/8
INFO - Deleting container 12.0.0.0/8 from layer3domain default
