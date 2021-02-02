$ ndcli create user-group public-zone-admins
$ ndcli list user-groups
name
all_users
public-zone-admins

$ ndcli show user-group public-zone-admins
created:2012-12-28 13:28:25
created_by:user
modified:2012-12-28 13:28:25
modified_by:user
name:public-zone-admins

$ ndcli rename user-group public-zone-admins to main-dns-admins
$ ndcli list user-groups
name
all_users
main-dns-admins

$ ndcli show user-group main-dns-admins
created:2012-12-28 13:28:25
created_by:user
modified:2012-12-28 13:28:26
modified_by:user
name:main-dns-admins

$ ndcli delete user-group main-dns-admins
