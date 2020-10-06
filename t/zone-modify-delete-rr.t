# ND-74 When the modify zone delete rr is used
# nothing else but the rr gets deleted

$ ndcli create zone-profile internal
$ ndcli modify zone-profile internal set mail dnsadmin@example.com
$ ndcli modify zone-profile internal set primary ins01.internal.test.
$ ndcli modify zone-profile internal create rr @ ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ ns ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify container 10.0.0.0/8 set attrs reverse_dns_profile:internal

$ ndcli create pool pfuh
$ ndcli modify pool pfuh add subnet 10.129.12.128/25
INFO - Created subnet 10.129.12.128/25 in layer3domain default
INFO - Creating zone 12.129.10.in-addr.arpa with profile internal

$ ndcli create zone fuh.local profile internal
INFO - Creating zone fuh.local with profile internal

$ ndcli create rr bla.fuh.local. a 10.129.12.130
INFO - Marked IP 10.129.12.130 from layer3domain default as static
INFO - Creating RR bla A 10.129.12.130 in zone fuh.local
INFO - Creating RR 130 PTR bla.fuh.local. in zone 12.129.10.in-addr.arpa

$ ndcli modify zone fuh.local delete rr bla
INFO - Deleting RR bla A 10.129.12.130 from zone fuh.local

$ ndcli create rr blubb.fuh.local. a 10.129.12.131
INFO - Marked IP 10.129.12.131 from layer3domain default as static
INFO - Creating RR blubb A 10.129.12.131 in zone fuh.local
INFO - Creating RR 131 PTR blubb.fuh.local. in zone 12.129.10.in-addr.arpa

$ ndcli modify zone 12.129.10.in-addr.arpa delete rr 131
INFO - Deleting RR 131 PTR blubb.fuh.local. from zone 12.129.10.in-addr.arpa

$ ndcli list zone 12.129.10.in-addr.arpa
record zone                   ttl   type value
@      12.129.10.in-addr.arpa 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2013122302 14400 3600 605000 86400
@      12.129.10.in-addr.arpa       NS   ins01.internal.test.
@      12.129.10.in-addr.arpa       NS   ins02.internal.test.
130    12.129.10.in-addr.arpa       PTR  bla.fuh.local.

$ ndcli list zone fuh.local
record zone      ttl   type value
@      fuh.local 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2014021804 14400 3600 605000 86400
@      fuh.local       NS   ins01.internal.test.
@      fuh.local       NS   ins02.internal.test.
blubb  fuh.local       A    10.129.12.131

$ ndcli modify zone fuh.local create view blah profile internal

$ ndcli create rr fasel.fuh.local. a 10.129.12.132 view blah default
INFO - Marked IP 10.129.12.132 from layer3domain default as static
INFO - Creating RR fasel A 10.129.12.132 in zone fuh.local view blah
INFO - Creating RR 132 PTR fasel.fuh.local. in zone 12.129.10.in-addr.arpa
INFO - Creating RR fasel A 10.129.12.132 in zone fuh.local view default
INFO - 132.12.129.10.in-addr.arpa. PTR fasel.fuh.local. already exists

$ ndcli modify zone fuh.local delete rr fasel view default
INFO - Deleting RR fasel A 10.129.12.132 from zone fuh.local view default

$ ndcli list zone fuh.local view blah
record zone      ttl   type value
@      fuh.local 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2014021802 14400 3600 605000 86400
@      fuh.local       NS   ins01.internal.test.
@      fuh.local       NS   ins02.internal.test.
fasel  fuh.local       A    10.129.12.132

$ ndcli modify zone fuh.local delete view blah -c -q

$ ndcli delete zone fuh.local -c -q

$ ndcli modify pool pfuh remove subnet 10.129.12.128/25 -f -c -q

$ ndcli delete pool pfuh

$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default

$ ndcli delete zone-profile internal


