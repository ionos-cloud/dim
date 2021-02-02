$ ndcli login -u user -p p
$ ndcli login -u admin -p p
$ ndcli create user-group g
$ ndcli create user-group g2

$ ndcli modify user-group g grant zone_create
$ ndcli modify user-group g2 grant zone_create
$ ndcli modify user-group g add user user

$ ndcli modify user-group g2 add user user
ERROR - An user can be granted the zone_create right from a single user-group
$ ndcli modify user-group g2 revoke zone_create
$ ndcli modify user-group g2 add user user

$ ndcli modify user-group g2 grant zone_create
ERROR - An user can be granted the zone_create right from a single user-group

$ ndcli login -u user -p p
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list user-group g rights
action      object
zone_admin  a.de
zone_create all

$ ndcli login -u admin -p p
$ ndcli modify user-group g grant zone_admin a.de
$ ndcli modify user-group g2 grant zone_admin a.de
$ ndcli list user-group g2 rights
action     object
zone_admin a.de
