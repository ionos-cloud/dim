# users with usertype Admin can modify user-groups
# admin user is Admin by default

# make sure the users exist
# as user user1
$ ndcli login -u user1 -p p
# as user user2
$ ndcli login -u user2 -p p

# as user admin
$ ndcli create user-group global-dns-admins
$ ndcli modify user-group global-dns-admins add user user1
$ ndcli modify user-group global-dns-admins add user user2

$ ndcli list user-group global-dns-admins users
username
user1
user2-test

$ ndcli delete user-group global-dns-admins

# I don't know a way of deleteing and/or disabling users.
