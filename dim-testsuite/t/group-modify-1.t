$ ndcli create user-group global-dns-admins

# user admin has admin flag in db (set user Admin)

$ ndcli login -u user1 -p testkey
$ ndcli login -u user2 -p testkey
$ ndcli login -u admin -p p

$ ndcli modify user-group global-dns-admins add user user1
$ ndcli modify user-group global-dns-admins add user user2

$ ndcli list user-group global-dns-admins users
username
user1
user2

$ ndcli delete user-group global-dns-admins

# I don't know a way of deleteing and/or disabling users.
