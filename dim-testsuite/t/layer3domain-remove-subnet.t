$ ndcli create layer3domain one type vrf rd 0:2

$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool p layer3domain default
$ ndcli modify pool p add subnet 10.0.0.0/23
INFO - Created subnet 10.0.0.0/23 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 1.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create container 10.0.0.0/8 layer3domain one
INFO - Creating container 10.0.0.0/8 in layer3domain one
$ ndcli create pool p2 layer3domain one
$ ndcli modify pool p2 add subnet 10.0.0.0/23 --allow-overlap
INFO - Created subnet 10.0.0.0/23 in layer3domain one
WARNING - 10.0.0.0/23 in layer3domain one overlaps with 10.0.0.0/23 in layer3domain default
INFO - Creating view one in zone 0.0.10.in-addr.arpa without profile
INFO - Creating view one in zone 1.0.10.in-addr.arpa without profile

$ ndcli create rr 2.0.0.10.in-addr.arpa. txt weird view default
INFO - Creating RR 2 TXT "weird" in zone 0.0.10.in-addr.arpa view default

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1 layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa view default
$ ndcli create rr a.de. a 10.0.0.128 layer3domain default
INFO - Marked IP 10.0.0.128 from layer3domain default as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.128 in zone a.de
INFO - Creating RR 128 PTR a.de. in zone 0.0.10.in-addr.arpa view default
$ ndcli create rr a.de. a 10.0.0.128 layer3domain one
INFO - Marked IP 10.0.0.128 from layer3domain one as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.128 in zone a.de
INFO - Creating RR 128 PTR a.de. in zone 0.0.10.in-addr.arpa view one


$ ndcli create zone b.de
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr b.b.de. cname a.de.
INFO - Creating RR b CNAME a.de. in zone b.de

$ ndcli modify pool p remove subnet 10.0.0.0/23
ERROR - Subnet 10.0.0.0/23 from layer3domain default still contains objects
$ ndcli modify pool p remove subnet 10.0.0.0/23 -f -c
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Deleting RR @ A 10.0.0.128 from zone a.de
INFO - Deleting RR 1 PTR a.de. from zone 0.0.10.in-addr.arpa view default
INFO - Deleting RR 128 PTR a.de. from zone 0.0.10.in-addr.arpa view default
INFO - Freeing IP 10.0.0.1 from layer3domain default
INFO - Freeing IP 10.0.0.128 from layer3domain default
WARNING - Zone 0.0.10.in-addr.arpa view default was not deleted: The view default of the zone 0.0.10.in-addr.arpa is not empty.
INFO - Deleting view default from zone 1.0.10.in-addr.arpa

$ ndcli delete rr b.b.de.
INFO - Deleting RR b CNAME a.de. from zone b.de

$ ndcli list zone 0.0.10.in-addr.arpa view default
record zone               ttl   type value
@      0.0.10.in-addr.arpa 86400 SOA  localhost. hostmaster.0.0.10.in-addr.arpa. 2017080706 14400 3600 605000 86400
2      0.0.10.in-addr.arpa       TXT  "weird"

$ ndcli list zone 0.0.10.in-addr.arpa view one
record zone               ttl   type value
@      0.0.10.in-addr.arpa 86400 SOA  localhost. hostmaster.0.0.10.in-addr.arpa. 2017080706 14400 3600 605000 86400
   128 0.0.10.in-addr.arpa       PTR  a.de.

$ ndcli modify pool p2 remove subnet 10.0.0.0/23 -f -c
INFO - Deleting RR @ A 10.0.0.128 from zone a.de
INFO - Deleting RR 128 PTR a.de. from zone 0.0.10.in-addr.arpa view one
INFO - Freeing IP 10.0.0.128 from layer3domain one
INFO - Deleting view one from zone 0.0.10.in-addr.arpa
INFO - Deleting zone 1.0.10.in-addr.arpa
$ ndcli list zone 0.0.10.in-addr.arpa views
name
default

$ ndcli delete rr 2.0.0.10.in-addr.arpa. TXT view default
INFO - Deleting RR 2 TXT "weird" from zone 0.0.10.in-addr.arpa
$ ndcli modify pool p add subnet 10.0.0.0/23
INFO - Created subnet 10.0.0.0/23 in layer3domain default
WARNING - Creating zone 1.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p remove subnet 10.0.0.0/23
INFO - Deleting zone 0.0.10.in-addr.arpa
INFO - Deleting zone 1.0.10.in-addr.arpa
