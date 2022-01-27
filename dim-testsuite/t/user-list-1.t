# make sure the user exists
# as user user1
$ ndcli login -u user1 -p p

# as user admin
$ ndcli create user-group dns-group-1

$ ndcli create user-group ipam-group-1

$ ndcli create user-group some-group-1

$ ndcli modify user-group dns-group-1 add user user1
$ ndcli modify user-group ipam-group-1 add user user1
$ ndcli modify user-group some-group-1 add user user1

$ ndcli create pool pool1
$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify user-group dns-group-1 grant create_rr example.com
$ ndcli modify user-group ipam-group-1 grant allocate pool1

$ ndcli list user user1
group        object right
all_users
dns-group-1  example.com create_rr
ipam-group-1 pool1  allocate
some-group-1

$ ndcli list user user1 groups
group
all_users
dns-group-1
ipam-group-1
some-group-1

$ ndcli delete zone example.com
$ ndcli delete pool pool1
$ ndcli delete user-group dns-group-1
$ ndcli delete user-group ipam-group-1
$ ndcli delete user-group some-group-1
