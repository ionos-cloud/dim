$ ndcli login -u user -p p
$ ndcli login -u admin -p p
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


$ ndcli login -u user -p p
# Fails, because it also tries to delete the forward rr
$ ndcli delete rr 1.2.3.4 ptr a.de.
ERROR - Permission denied (can_delete_rr zone a.de)
# Fails, because it also tries to create the forward rr
$ ndcli create rr 1.2.3.5 ptr a.de.
ERROR - Permission denied (can_create_rr zone a.de)

# Must fail
$ ndcli delete rr a.de. a
ERROR - Permission denied (can_delete_rr zone a.de)


$ ndcli login -u admin -p p
$ ndcli modify user-group dns-users grant create_rr a.de
$ ndcli modify user-group dns-users grant delete_rr a.de
$ ndcli login -u user -p p
$ ndcli delete rr a.de. a
INFO - Deleting RR @ A 1.2.3.4 from zone a.de
INFO - Deleting RR 4 PTR a.de. from zone 3.2.1.in-addr.arpa
INFO - Freeing IP 1.2.3.4 from layer3domain default
$ ndcli create rr 1.2.3.5 ptr a.de.
INFO - Marked IP 1.2.3.5 from layer3domain default as static
INFO - Creating RR 5 PTR a.de. in zone 3.2.1.in-addr.arpa
INFO - Creating RR @ A 1.2.3.5 in zone a.de

# Must fail
$ ndcli delete zone 3.2.1.in-addr.arpa
ERROR - Permission denied (can_delete_reverse_zones)
$ ndcli create zone 4.2.1.in-addr.arpa
ERROR - Permission denied (can_create_reverse_zones)


$ ndcli login -u admin -p p
$ ndcli modify user-group dns-users grant network_admin
$ ndcli login -u user -p p
$ ndcli list user user rights
group     object right
all_users
dns-users pool   allocate
dns-users a.de   delete_rr
dns-users a.de   create_rr
dns-users all    network_admin
$ ndcli delete zone 3.2.1.in-addr.arpa --cleanup
INFO - Deleting RR 5 PTR a.de. from zone 3.2.1.in-addr.arpa
INFO - Deleting RR @ A 1.2.3.5 from zone a.de
INFO - Freeing IP 1.2.3.5 from layer3domain default
$ ndcli create zone 4.2.1.in-addr.arpa
WARNING - Creating zone 4.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

# Must fail
$ ndcli delete zone a.de
ERROR - Permission denied (can_manage_zone a.de)
$ ndcli delete zone-profile profile
ERROR - Permission denied (can_dns_admin)
$ ndcli create zone a2.de
ERROR - Permission denied (can_create_forward_zones)
$ ndcli create zone-profile profile2
ERROR - Permission denied (can_dns_admin)


$ ndcli login -u admin -p p
$ ndcli modify user-group dns-users grant dns_admin
$ ndcli login -u user -p p
$ ndcli delete zone a.de --cleanup
$ ndcli delete zone-profile profile
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-profile profile
