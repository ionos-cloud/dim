$ ndcli create zone 209.74.in-addr.arpa
WARNING - Creating zone 209.74.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone 56.209.74.in-addr.arpa
WARNING - Creating zone 56.209.74.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone 56.209.74.in-addr.arpa

$ ndcli modify zone 209.74.in-addr.arpa create rr 56 ns ns.my.domain.
INFO - Creating RR 56 NS ns.my.domain. in zone 209.74.in-addr.arpa
WARNING - ns.my.domain. does not exist.

$ ndcli create rr 56.209.74.in-addr.arpa. ns ns.my.domain.
INFO - Creating RR @ NS ns.my.domain. in zone 56.209.74.in-addr.arpa
WARNING - ns.my.domain. does not exist.

$ ndcli list rrs *.209.74.in-addr.arpa
INFO - Result for list rrs *.209.74.in-addr.arpa
record zone                   view    ttl   type value
56     209.74.in-addr.arpa    default       NS   ns.my.domain.
@      56.209.74.in-addr.arpa default 86400 SOA  localhost. hostmaster.56.209.74.in-addr.arpa. 2013092402 14400 3600 605000 86400
@      56.209.74.in-addr.arpa default       NS   ns.my.domain.

$ ndcli modify zone 209.74.in-addr.arpa delete rr 56
INFO - Deleting RR 56 NS ns.my.domain. from zone 209.74.in-addr.arpa

$ ndcli list rrs *.209.74.in-addr.arpa
INFO - Result for list rrs *.209.74.in-addr.arpa
record zone                   view    ttl   type value
@      56.209.74.in-addr.arpa default 86400 SOA  localhost. hostmaster.56.209.74.in-addr.arpa. 2013092402 14400 3600 605000 86400
@      56.209.74.in-addr.arpa default       NS   ns.my.domain.

$ ndcli delete zone 56.209.74.in-addr.arpa -c -q
$ ndcli delete zone 209.74.in-addr.arpa -c -q

