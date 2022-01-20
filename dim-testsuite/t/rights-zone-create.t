# make sure the users exist
# as user user
$ ndcli login -u user -p p

# as user admin
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

# as user user
$ ndcli create zone a.de -u user
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list user-group g rights -u user
action      object
zone_admin  a.de
zone_create all

# as user admin
$ ndcli modify user-group g grant zone_admin a.de
$ ndcli modify user-group g2 grant zone_admin a.de
$ ndcli list user-group g2 rights
action     object
zone_admin a.de
