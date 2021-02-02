$ ndcli create pool pool1
$ ndcli create user-group testgroup1
$ ndcli show pool pool1
created:2016-04-27 18:49:50
layer3domain:default
modified:2016-04-27 18:49:50
modified_by:admin
name:pool1
$ ndcli modify pool pool1 owning-user-group testgroup1
$ ndcli show pool pool1
created:2016-04-27 18:49:50
layer3domain:default
modified:2016-04-27 18:49:50
modified_by:admin
name:pool1
owner:testgroup1
$ ndcli create user-group testgroup2
$ ndcli create pool pool2 owning-user-group testgroup2
$ ndcli show pool pool2
created:2016-04-27 18:49:50
layer3domain:default
modified:2016-04-27 18:49:50
modified_by:admin
name:pool2
owner:testgroup2
$ ndcli delete user-group testgroup2
$ ndcli show pool pool2
created:2016-04-27 18:49:50
layer3domain:default
modified:2016-04-27 18:49:50
modified_by:admin
name:pool2
$ ndcli delete pool pool1
$ ndcli delete pool pool2
