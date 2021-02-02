# network_admin can delete_rr in any zone and can delete reverse zones
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.a.com. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR a A 1.2.3.4 in zone a.com
INFO - Creating RR 4 PTR a.a.com. in zone 3.2.1.in-addr.arpa

$ ndcli login -u netadmin -p p
$ ndcli login -u admin -p p
$ ndcli create user-group network-admins
$ ndcli modify user-group network-admins add user netadmin
$ ndcli modify user-group network-admins grant network_admin
$ ndcli login -u netadmin -p p

$ ndcli modify pool apool remove subnet 1.2.3.0/24 --cleanup --force
INFO - Deleting RR a A 1.2.3.4 from zone a.com
INFO - Deleting RR 4 PTR a.a.com. from zone 3.2.1.in-addr.arpa
INFO - Freeing IP 1.2.3.4 from layer3domain default
INFO - Deleting zone 3.2.1.in-addr.arpa
$ ndcli list zone a.com
record zone  ttl   type value
@      a.com 86400 SOA  localhost. hostmaster.a.com. 2015072303 14400 3600 605000 86400
$ ndcli list zone 3.2.1.in-addr.arpa
ERROR - Zone 3.2.1.in-addr.arpa does not exist
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
