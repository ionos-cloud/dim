$ ndcli create container 10.0.0.0/8 -q
$ ndcli create pool p -q
$ ndcli modify pool p add subnet 10.120.144.0/20 -q
$ ndcli show ip 10.120.145.0
ip:10.120.145.0
mask:255.255.240.0
pool:p
reverse_zone:145.120.10.in-addr.arpa
status:Available
subnet:10.120.144.0/20
$ ndcli modify pool p remove subnet 10\.120\.144\.0/20 -q
$ ndcli delete pool p -q
$ ndcli delete container 10.0.0.0/8 -q
