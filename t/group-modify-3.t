$ ndcli create user-group dns-master-admins
$ ndcli create user-group dns-m
$ ndcli create user-group dns-s
$ ndcli create user-group dns-d

$ ndcli create zone w.de
WARNING - Creating zone w.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone s.de
WARNING - Creating zone s.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone s.de create view public
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone s.de create view customer-internal
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone s.de rename view default to internal

$ ndcli modify user-group dns-m grant create_rr w.de
$ ndcli modify user-group dns-m grant delete_rr s.de view internal

$ ndcli modify user-group dns-s grant create_rr s.de view public internal

$ ndcli modify user-group dns-d grant create_rr s.de
ERROR - A view must be selected from: customer-internal internal public

$ ndcli list user-group dns-s rights
action   object
create_rr s.de view internal
create_rr s.de view public

$ ndcli list user-group dns-m rights
action   object
create_rr w.de
delete_rr s.de view internal

$ ndcli modify user-group dns-s revoke create_rr s.de view internal

$ ndcli list user-group dns-s rights
action   object
create_rr s.de view public

# No error to be consistent with ip rights
$ ndcli modify user-group dns-s grant create_rr s.de view public

$ ndcli modify user-group dns-s grant create_rr s.de view fuh
ERROR - View 'fuh' does not exist in zone s.de

$ ndcli modify user-group dns-s grant create_rr se.de
ERROR - Zone 'se.de' does not exist

$ ndcli modify zone s.de delete view internal
$ ndcli list user-group dns-m rights
action   object
create_rr w.de

$ ndcli delete zone w.de
$ ndcli modify zone s.de delete view public
$ ndcli delete zone s.de

$ ndcli delete user-group dns-master-admins
$ ndcli delete user-group dns-m
$ ndcli delete user-group dns-s
$ ndcli delete user-group dns-d
