$ ndcli create user-group g
$ ndcli create pool p owning-user-group g
$ ndcli list user-group g pools
name
p
$ ndcli modify pool p remove owning-user-group
$ ndcli list user-group g pools
name
$ ndcli modify pool p set owning-user-group g
$ ndcli list user-group g pools
name
p
$ ndcli delete user-group g
$ ndcli delete pool p
$ ndcli list user-group g pools
ERROR - Group 'g' does not exist
