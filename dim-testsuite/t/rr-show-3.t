# Now RRs with a comment

$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone a.de create view de
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli create rr a.a.de. a 1.2.3.4 view de -c "a comment"
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR a A 1.2.3.4 comment a comment in zone a.de view de
INFO - Creating RR 4 PTR a.a.de. comment a comment in zone 3.2.1.in-addr.arpa

$ ndcli show rr a.a.de.
ERROR - A view must be selected from: de default

$ ndcli show rr a.a.de. view de
created:2012-11-14 11:03:02
created_by:user
modified:2012-11-14 11:03:02
modified_by:user
comment:a comment
zone:a.de
view:de
rr:a A 1.2.3.4

$ ndcli modify zone a.de delete view default
$ ndcli delete zone a.de -q --cleanup
$ ndcli delete zone 3.2.1.in-addr.arpa
$ ndcli modify pool apool remove subnet 1.2.3.0/24
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
