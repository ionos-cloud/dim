$ ndcli list user-groups -u user1 -p testkey
name
all_users
$ ndcli list user-groups -u user2 -p testkey
name
all_users
$ ndcli login -u admin -p p
$ ndcli create user-group tg1
$ ndcli modify user-group tg1 add user user1

$ ndcli list users
name  groups
admin all_users
user1 all_users tg1
user2 all_users

