# make sure the users exist
# as user user
$ ndcli login -u user -p p
# as user dns_admin
$ ndcli login -u dns_admin -p p

# as user admin
$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create pool p

$ ndcli create user-group dns_admins
$ ndcli modify user-group dns_admins add user dns_admin
$ ndcli modify user-group dns_admins grant dns_admin
$ ndcli modify user-group dns_admins grant allocate p
$ ndcli modify user-group dns_admins revoke allocate p

$ ndcli create user-group users
$ ndcli modify user-group users add user user
$ ndcli modify user-group users grant create_rr . view default
$ ndcli modify user-group users revoke create_rr . view default
$ ndcli modify user-group users grant zone_admin .
$ ndcli modify user-group users revoke zone_admin .
$ ndcli modify user-group users grant zone_create
$ ndcli modify user-group users revoke zone_create
$ ndcli modify user-group users remove user user

$ ndcli history user-groups -L 20
timestamp                  user  tool   originating_ip objclass name       action
2019-01-14 19:30:39.755766 admin native 127.0.0.1      group    users      removed user user
2019-01-14 19:30:39.745484 admin native 127.0.0.1      group    users      revoked zone_create
2019-01-14 19:30:39.736007 admin native 127.0.0.1      group    users      granted zone_create
2019-01-14 19:30:39.720587 admin native 127.0.0.1      group    users      revoked zone_admin on .
2019-01-14 19:30:39.708807 admin native 127.0.0.1      group    users      granted zone_admin on .
2019-01-14 19:30:39.695448 admin native 127.0.0.1      group    users      revoked create_rr on zone . view default
2019-01-14 19:30:39.682007 admin native 127.0.0.1      group    users      granted create_rr on zone . view default
2019-01-14 19:30:39.667007 admin native 127.0.0.1      group    users      added user user
2019-01-14 19:30:39.654835 admin native 127.0.0.1      group    users      created
2019-01-14 19:30:39.645430 admin native 127.0.0.1      group    dns_admins revoked allocate on p
2019-01-14 19:30:39.633285 admin native 127.0.0.1      group    dns_admins granted allocate on p
2019-01-14 19:30:39.618233 admin native 127.0.0.1      group    dns_admins granted dns_admin
2019-01-14 19:30:39.607751 admin native 127.0.0.1      group    dns_admins added user dns_admin
2019-01-14 19:30:39.596107 admin native 127.0.0.1      group    dns_admins created
2019-01-14 19:30:39.576687 local native                group    all_users  added user dns_admin
2019-01-14 19:30:39.562926 local native                group    all_users  added user user
2019-01-14 19:30:39.448489 local native                group    all_users  added user admin
2019-01-14 19:30:39.442989 local native                group    all_users  created

$ ndcli history user-group dns_admins
timestamp                  user  tool   originating_ip objclass name       action
2019-01-14 19:30:39.645430 admin native 127.0.0.1      group    dns_admins revoked allocate on p
2019-01-14 19:30:39.633285 admin native 127.0.0.1      group    dns_admins granted allocate on p
2019-01-14 19:30:39.618233 admin native 127.0.0.1      group    dns_admins granted dns_admin
2019-01-14 19:30:39.607751 admin native 127.0.0.1      group    dns_admins added user dns_admin
2019-01-14 19:30:39.596107 admin native 127.0.0.1      group    dns_admins created


$ ndcli history user-group users
timestamp                  user  tool   originating_ip objclass name  action
2019-01-14 19:30:39.755766 admin native 127.0.0.1      group    users removed user user
2019-01-14 19:30:39.745484 admin native 127.0.0.1      group    users revoked zone_create
2019-01-14 19:30:39.736007 admin native 127.0.0.1      group    users granted zone_create
2019-01-14 19:30:39.720587 admin native 127.0.0.1      group    users revoked zone_admin on .
2019-01-14 19:30:39.708807 admin native 127.0.0.1      group    users granted zone_admin on .
2019-01-14 19:30:39.695448 admin native 127.0.0.1      group    users revoked create_rr on zone . view default
2019-01-14 19:30:39.682007 admin native 127.0.0.1      group    users granted create_rr on zone . view default
2019-01-14 19:30:39.667007 admin native 127.0.0.1      group    users added user user
2019-01-14 19:30:39.654835 admin native 127.0.0.1      group    users created


$ ndcli history user admin -L 20
timestamp                  user  tool   originating_ip objclass  name       action
2019-01-14 19:30:39.755766 admin native 127.0.0.1      group     users      removed user user
2019-01-14 19:30:39.745484 admin native 127.0.0.1      group     users      revoked zone_create
2019-01-14 19:30:39.736007 admin native 127.0.0.1      group     users      granted zone_create
2019-01-14 19:30:39.720587 admin native 127.0.0.1      group     users      revoked zone_admin on .
2019-01-14 19:30:39.708807 admin native 127.0.0.1      group     users      granted zone_admin on .
2019-01-14 19:30:39.695448 admin native 127.0.0.1      group     users      revoked create_rr on zone . view default
2019-01-14 19:30:39.682007 admin native 127.0.0.1      group     users      granted create_rr on zone . view default
2019-01-14 19:30:39.667007 admin native 127.0.0.1      group     users      added user user
2019-01-14 19:30:39.654835 admin native 127.0.0.1      group     users      created
2019-01-14 19:30:39.645430 admin native 127.0.0.1      group     dns_admins revoked allocate on p
2019-01-14 19:30:39.633285 admin native 127.0.0.1      group     dns_admins granted allocate on p
2019-01-14 19:30:39.618233 admin native 127.0.0.1      group     dns_admins granted dns_admin
2019-01-14 19:30:39.607751 admin native 127.0.0.1      group     dns_admins added user dns_admin
2019-01-14 19:30:39.596107 admin native 127.0.0.1      group     dns_admins created
2019-01-14 19:30:39.553039 admin native 127.0.0.1      ippool    p          created in layer3domain default
2019-01-15 11:29:26.665938 admin native 127.0.0.1      zone-view default    created in zone .
2019-01-14 19:30:39.537868 admin native 127.0.0.1      zone      .          created


$ ndcli history zone .
timestamp                  user  tool   originating_ip objclass  name    action
2019-01-14 19:30:39.720587 admin native 127.0.0.1      group     users   revoked zone_admin on .
2019-01-14 19:30:39.708807 admin native 127.0.0.1      group     users   granted zone_admin on .
2019-01-14 19:30:39.695448 admin native 127.0.0.1      group     users   revoked create_rr on zone . view default
2019-01-14 19:30:39.682007 admin native 127.0.0.1      group     users   granted create_rr on zone . view default
2019-01-14 19:30:39.538916 admin native 127.0.0.1      zone-view default created
2019-01-14 19:30:39.537868 admin native 127.0.0.1      zone      .       created
