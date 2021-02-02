$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create user-group testgroup
$ ndcli show zone a.de
created:2016-04-22 15:29:03
created_by:admin
modified:2016-04-22 15:29:03
modified_by:admin
name:a.de
views:1
$ ndcli modify zone a.de owning-user-group testgroup
$ ndcli show zone a.de
created:2016-04-22 15:29:03
created_by:admin
modified:2016-04-22 15:29:03
modified_by:admin
name:a.de
owner:testgroup
views:1

$ ndcli create user-group testgroup2
$ ndcli create zone b.de owning-user-group testgroup2
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli show zone b.de
created:2016-04-22 15:29:03
created_by:admin
modified:2016-04-22 15:29:03
modified_by:admin
name:b.de
owner:testgroup2
views:1
$ ndcli delete user-group testgroup2
$ ndcli show zone b.de
created:2016-04-22 15:29:03
created_by:admin
modified:2016-04-22 15:29:03
modified_by:admin
name:b.de
views:1

$ ndcli delete zone a.de
$ ndcli delete zone b.de
