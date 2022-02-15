# make sure the users exist
# as user dnsadmin
$ ndcli login -u dnsadmin -p p
# as user networkadmin
$ ndcli login -u networkadmin -p p
# as user receiver
$ ndcli login -u receiver -p p

# as user admin
$ ndcli create user-group dns-admins
$ ndcli modify user-group dns-admins grant dns_admin
$ ndcli modify user-group dns-admins add user dnsadmin
$ ndcli create user-group network-admins
$ ndcli modify user-group network-admins grant network_admin
$ ndcli modify user-group network-admins add user networkadmin
$ ndcli create user-group receiver
$ ndcli modify user-group receiver add user receiver
$ ndcli create user-group blocker

$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

# allocat permission
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool a
$ ndcli modify pool a add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

# set correct permissions
$ ndcli -u networkadmin modify user-group receiver grant allocate a
$ ndcli -u dnsadmin modify user-group receiver grant create_rr example.com

# ensure networking and dns permissions are still blocked
$ ndcli -u networkadmin modify user-group blocker grant create_rr example.com
ERROR - Permission denied (can_dns_admin)
$ ndcli -u dnsadmin modify user-group receiver grant allocate a
ERROR - Permission denied (can_network_admin)
