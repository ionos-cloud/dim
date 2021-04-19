$ ndcli create zone-profile public-rev-dns primary rns.example.com. mail dnsadmin@example.com
$ ndcli modify zone-profile public-rev-dns create rr @ ns rns.example.com.
INFO - Creating RR @ NS rns.example.com. in zone profile public-rev-dns
WARNING - rns.example.com. does not exist.
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli modify container 1.0.0.0/8 set attrs reverse_dns_profile:public-rev-dns
$ ndcli create pool p
$ ndcli modify pool p add subnet 1.0.0.0/23
INFO - Created subnet 1.0.0.0/23 in layer3domain default
INFO - Creating zone 0.0.1.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 1.0.1.in-addr.arpa with profile public-rev-dns

$ ndcli create rr 2.0.0.1.in-addr.arpa. txt weird
INFO - Creating RR 2 TXT "weird" in zone 0.0.1.in-addr.arpa

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 1.0.0.1
INFO - Marked IP 1.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 1.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.1.in-addr.arpa
$ ndcli create rr a.de. a 1.0.0.128
INFO - Marked IP 1.0.0.128 from layer3domain default as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 1.0.0.128 in zone a.de
INFO - Creating RR 128 PTR a.de. in zone 0.0.1.in-addr.arpa

$ ndcli create zone b.de
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr b.b.de. cname a.de.
INFO - Creating RR b CNAME a.de. in zone b.de

$ ndcli modify pool p remove subnet 1.0.0.0/23
ERROR - Subnet 1.0.0.0/23 from layer3domain default still contains objects
# No ip is freed, no rr deleted
$ ndcli modify pool p remove subnet 1.0.0.0/23 -f -n
INFO - Dryrun mode, no data will be modified
$ ndcli modify pool p remove subnet 1.0.0.0/23 -f -c
INFO - Deleting RR @ A 1.0.0.1 from zone a.de
INFO - Deleting RR @ A 1.0.0.128 from zone a.de
INFO - Deleting RR b CNAME a.de. from zone b.de
INFO - Deleting RR 1 PTR a.de. from zone 0.0.1.in-addr.arpa
INFO - Deleting RR 128 PTR a.de. from zone 0.0.1.in-addr.arpa
INFO - Freeing IP 1.0.0.1 from layer3domain default
INFO - Freeing IP 1.0.0.128 from layer3domain default
INFO - Deleting RR @ NS rns.example.com. from zone 0.0.1.in-addr.arpa
WARNING - Zone 0.0.1.in-addr.arpa was not deleted: Zone not empty.
INFO - Deleting RR @ NS rns.example.com. from zone 1.0.1.in-addr.arpa
INFO - Deleting zone 1.0.1.in-addr.arpa

$ ndcli list zone 0.0.1.in-addr.arpa
record zone               ttl   type value
@      0.0.1.in-addr.arpa 86400 SOA  rns.example.com. dnsadmin.example.com. 2014041607 14400 3600 605000 86400
2      0.0.1.in-addr.arpa       TXT  "weird"
