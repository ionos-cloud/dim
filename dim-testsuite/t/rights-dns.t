# make sure the users exist
# as user dnsadmin
$ ndcli login -u dnsadmin -p p
# as user networkadmin
$ ndcli login -u networkadmin -p p

# as user admin
$ ndcli create user-group dns-admins
$ ndcli modify user-group dns-admins grant dns_admin
$ ndcli modify user-group dns-admins add user dnsadmin
$ ndcli create user-group network-admins
$ ndcli modify user-group network-admins grant network_admin
$ ndcli modify user-group network-admins add user networkadmin

$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

# as user networkadmin
$ ndcli modify zone example.com set attrs comment:'test comment' -u networkadmin
ERROR - Permission denied (can_manage_zone example.com)

# as user dnsadmin
$ ndcli modify zone example.com set attrs comment:'test comment' -u dnsadmin

# cleap up
# as user admin
$ ndcli delete zone example.com -q --cleanup
$ ndcli delete user-group dns-admins
$ ndcli delete user-group network-admins
