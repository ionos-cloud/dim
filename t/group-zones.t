$ ndcli create user-group g
$ ndcli create zone a.com owning-user-group g
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli list user-group g zones
name
a.com
$ ndcli delete user-group g
$ ndcli delete zone a.com
$ ndcli list user-group g zones
name
