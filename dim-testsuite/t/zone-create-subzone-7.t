# Test --no-inherit-*
# make sure the user exits
# as user u
$ ndcli login -u u -p p
# as user admin
$ ndcli create user-group g
$ ndcli modify user-group g add user u

$ ndcli create zone a.de owning-user-group g
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone a.de view default
$ ndcli list zone-group zg
zone view
a.de default
$ ndcli modify user-group g grant create_rr a.de view default
$ ndcli list user-group g rights
action    object
create_rr a.de
$ ndcli show zone a.de
created:2017-06-08 14:16:50
created_by:admin
modified:2017-06-08 14:16:50
modified_by:admin
name:a.de
owner:g
views:1
zone_groups:1

$ ndcli create zone sub.a.de --no-inherit-zone-groups
WARNING - Creating zone sub.a.de without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone sub.a.de
$ ndcli list zone-group zg
zone     view
a.de     default
$ ndcli list user-group g rights
action    object
create_rr a.de
create_rr sub.a.de
$ ndcli show zone sub.a.de
created:2017-06-08 14:16:50
created_by:admin
modified:2017-06-08 14:16:50
modified_by:admin
name:sub.a.de
owner:g
views:1

$ ndcli delete zone sub.a.de

$ ndcli create zone sub.a.de --no-inherit-rights
WARNING - Creating zone sub.a.de without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone sub.a.de

$ ndcli list zone-group zg
zone     view
a.de     default
sub.a.de default
$ ndcli list user-group g rights
action    object
create_rr a.de
$ ndcli show zone sub.a.de
created:2017-06-08 14:16:50
created_by:admin
modified:2017-06-08 14:16:50
modified_by:admin
name:sub.a.de
owner:g
views:1
zone_groups:1

$ ndcli delete zone sub.a.de

$ ndcli create zone sub.a.de --no-inherit-owner
WARNING - Creating zone sub.a.de without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone sub.a.de

$ ndcli list zone-group zg
zone     view
a.de     default
sub.a.de default
$ ndcli list user-group g rights
action    object
create_rr a.de
create_rr sub.a.de
$ ndcli show zone sub.a.de
created:2017-06-08 14:16:50
created_by:admin
modified:2017-06-08 14:16:50
modified_by:admin
name:sub.a.de
views:1
zone_groups:1

$ ndcli delete zone sub.a.de

$ ndcli create zone sub.a.de owning-user-group all_users
WARNING - Creating zone sub.a.de without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone sub.a.de

$ ndcli show zone sub.a.de
created:2017-06-08 14:20:59
created_by:admin
modified:2017-06-08 14:20:59
modified_by:admin
name:sub.a.de
owner:all_users
views:1
zone_groups:1

$ ndcli create zone b.de --no-inherit-owner --no-inherit-rights
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Zone b.de does not have a parent zone. Inherit options ignored
