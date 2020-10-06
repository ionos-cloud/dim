$ ndcli login -u dnsadmin -p p
$ ndcli login -u admin -p p
$ ndcli create user-group dns-admins
$ ndcli modify user-group dns-admins add user dnsadmin
$ ndcli create output out plugin pdns-db db-uri "uri"
$ ndcli create zone-group internal

$ ndcli login -u dnsadmin -p p
$ ndcli delete output out
ERROR - Permission denied (can_dns_admin)
$ ndcli create output out plugin pdns-db db-uri "uri"
ERROR - Permission denied (can_dns_admin)
$ ndcli modify output out add zone-group internal
ERROR - Permission denied (can_dns_admin)

$ ndcli login -u admin -p p
$ ndcli modify user-group dns-admins grant dns_admin
$ ndcli login -u dnsadmin -p p
$ ndcli delete output out
$ ndcli create output out plugin pdns-db db-uri "uri"
$ ndcli modify output out add zone-group internal
