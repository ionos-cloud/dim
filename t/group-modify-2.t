$ ndcli create user-group dns-master-admins
# grant members of GROUP full access to all dns zones
$ ndcli modify user-group dns-master-admins grant dns_admin
$ ndcli delete user-group dns-master-admins
