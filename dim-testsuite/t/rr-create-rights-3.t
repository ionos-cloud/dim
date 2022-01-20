# make sure the user exists
# as user dnsadmin
$ ndcli login -u dnsadmin -p p

# as user admin
$ ndcli create user-group dns-admins
$ ndcli modify user-group dns-admins add user dnsadmin
$ ndcli create output out plugin pdns-db db-uri "uri"
$ ndcli create zone-group internal

# as user dnsadmin
$ ndcli delete output out -u dnsadmin
ERROR - Permission denied (can_dns_admin)
$ ndcli create output out plugin pdns-db db-uri "uri" -u dnsadmin
ERROR - Permission denied (can_dns_admin)
$ ndcli modify output out add zone-group internal -u dnsadmin
ERROR - Permission denied (can_dns_admin)

# as user admin
$ ndcli modify user-group dns-admins grant dns_admin
# as user dnsadmin
$ ndcli delete output out -u dnsadmin
$ ndcli create output out plugin pdns-db db-uri "uri" -u dnsadmin
$ ndcli modify output out add zone-group internal -u dnsadmin
