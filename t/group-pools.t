$ ndcli create user-group g
$ ndcli create pool p owning-user-group g
$ ndcli list user-group g pools
name
p
$ ndcli delete user-group g
$ ndcli delete pool p
$ ndcli list user-group g pools
ERROR - Group 'g' does not exist
