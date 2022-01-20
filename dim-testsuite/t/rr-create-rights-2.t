# make sure the users exists
# as user user
$ ndcli login -u user -p p

# as user admin
$ ndcli create user-group dns-users
$ ndcli modify user-group dns-users add user user

$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool pool
$ ndcli modify pool pool add subnet 1.2.3.0/24
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify user-group dns-users grant allocate pool

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-profile profile
$ ndcli create rr a.de. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR @ A 1.2.3.4 in zone a.de
INFO - Creating RR 4 PTR a.de. in zone 3.2.1.in-addr.arpa

# as user user
# Fails, because it also tries to delete the forward rr
$ ndcli delete rr 1.2.3.4 ptr a.de. -u user
ERROR - Permission denied (can_delete_rr zone a.de)
# Fails, because it also tries to create the forward rr
$ ndcli create rr 1.2.3.5 ptr a.de. -u user
ERROR - Permission denied (can_create_rr zone a.de)

# Must fail
$ ndcli delete rr a.de. a -u user
ERROR - Permission denied (can_delete_rr zone a.de)

# as user admin
$ ndcli modify user-group dns-users grant create_rr a.de
$ ndcli modify user-group dns-users grant delete_rr a.de
# as user user
$ ndcli delete rr a.de. a -u user
INFO - Deleting RR @ A 1.2.3.4 from zone a.de
INFO - Deleting RR 4 PTR a.de. from zone 3.2.1.in-addr.arpa
INFO - Freeing IP 1.2.3.4 from layer3domain default
$ ndcli create rr 1.2.3.5 ptr a.de. -u user
INFO - Marked IP 1.2.3.5 from layer3domain default as static
INFO - Creating RR 5 PTR a.de. in zone 3.2.1.in-addr.arpa
INFO - Creating RR @ A 1.2.3.5 in zone a.de

# Must fail
$ ndcli delete zone 3.2.1.in-addr.arpa -u user
ERROR - Permission denied (can_delete_reverse_zones)
$ ndcli create zone 4.2.1.in-addr.arpa -u user
ERROR - Permission denied (can_create_reverse_zones)


# as user admin
$ ndcli modify user-group dns-users grant network_admin
# as user user
$ ndcli list user user rights -u user
group     object right
all_users
dns-users pool   allocate
dns-users a.de   create_rr
dns-users a.de   delete_rr
dns-users all    network_admin
$ ndcli delete zone 3.2.1.in-addr.arpa --cleanup -u user
INFO - Deleting RR @ A 1.2.3.5 from zone a.de
INFO - Deleting RR 5 PTR a.de. from zone 3.2.1.in-addr.arpa
INFO - Freeing IP 1.2.3.5 from layer3domain default
$ ndcli create zone 4.2.1.in-addr.arpa -u user
WARNING - Creating zone 4.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

# Must fail
$ ndcli delete zone a.de -u user
ERROR - Permission denied (can_manage_zone a.de)
$ ndcli delete zone-profile profile -u user
ERROR - Permission denied (can_dns_admin)
$ ndcli create zone a2.de -u user
ERROR - Permission denied (can_create_forward_zones)
$ ndcli create zone-profile profile2 -u user
ERROR - Permission denied (can_dns_admin)

# as user admin
$ ndcli modify user-group dns-users grant dns_admin
# as user user
$ ndcli delete zone a.de --cleanup -u user
$ ndcli delete zone-profile profile -u user
$ ndcli create zone a.de -u user
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-profile profile -u user
