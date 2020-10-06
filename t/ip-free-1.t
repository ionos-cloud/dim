$ ndcli login -u user -p p
$ ndcli login -u admin -p p
$ ndcli create user-group g
$ ndcli modify user-group g grant network_admin
$ ndcli modify user-group g add user user

$ ndcli create pool p
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli modify pool p add subnet 1.1.1.0/24
INFO - Created subnet 1.1.1.0/24 in layer3domain default
WARNING - Creating zone 1.1.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr a.de. a 1.1.1.1
INFO - Marked IP 1.1.1.1 from layer3domain default as static
INFO - Creating RR @ A 1.1.1.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 1.1.1.in-addr.arpa

$ ndcli create zone b.de
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify user-group g grant create_rr b.de

$ ndcli modify user-group g grant delete_rr b.de

$ ndcli login -u user -p p
$ ndcli create rr a.b.de. a 1.1.1.1 --overwrite-ptr
INFO - Creating RR a A 1.1.1.1 in zone b.de
WARNING - Deleting RR 1 PTR a.de. from zone 1.1.1.in-addr.arpa
INFO - Creating RR 1 PTR a.b.de. in zone 1.1.1.in-addr.arpa

$ ndcli modify pool p free ip 1.1.1.1
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Deleting RR a A 1.1.1.1 from zone b.de
INFO - Deleting RR 1 PTR a.b.de. from zone 1.1.1.in-addr.arpa
INFO - Freeing IP 1.1.1.1 from layer3domain default

$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
