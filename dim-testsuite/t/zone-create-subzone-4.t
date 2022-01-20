# make sure the users exist
# as user u
$ ndcli login -u u -p p
# as user u2
$ ndcli login -u u2 -p p
# as user admin
$ ndcli create user-group g
$ ndcli modify user-group g add user u
$ ndcli create user-group g2
$ ndcli modify user-group g2 add user u2

$ ndcli create zone a.de owning-user-group g
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone a.de create view second
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone a.de view default
$ ndcli create zone-group zg2
$ ndcli modify zone-group zg2 add zone a.de view second
$ ndcli list zone-group zg
zone view
a.de default
$ ndcli list zone-group zg2
zone view
a.de second
$ ndcli modify user-group g grant create_rr a.de view default
$ ndcli modify user-group g grant delete_rr a.de view default
$ ndcli modify user-group g2 grant create_rr a.de view second
$ ndcli list user-group g rights
action    object
create_rr a.de view default
delete_rr a.de view default
$ ndcli list user-group g2 rights
action    object
create_rr a.de view second

$ ndcli create zone sub.a.de
WARNING - Creating zone sub.a.de without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default, second for zone sub.a.de
$ ndcli list zone-group zg
zone     view
a.de     default
sub.a.de default
$ ndcli list zone-group zg2
zone     view
a.de     second
sub.a.de second
$ ndcli list user-group g rights
action    object
create_rr a.de view default
create_rr sub.a.de view default
delete_rr a.de view default
delete_rr sub.a.de view default
$ ndcli list user-group g2 rights
action    object
create_rr a.de view second
create_rr sub.a.de view second

$ ndcli modify zone sub.a.de delete view second

$ ndcli delete zone sub.a.de

$ ndcli create zone sub.a.de --no-inherit
WARNING - Creating zone sub.a.de without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default, second for zone sub.a.de

$ ndcli list zone-group zg
zone     view
a.de     default
$ ndcli list zone-group zg2
zone     view
a.de     second
$ ndcli list user-group g rights
action    object
create_rr a.de view default
delete_rr a.de view default
$ ndcli list user-group g2 rights
action    object
create_rr a.de view second
$ ndcli show zone sub.a.de
created:2017-06-08 14:16:34
created_by:admin
modified:2017-06-08 14:16:34
modified_by:admin
name:sub.a.de
views:2
