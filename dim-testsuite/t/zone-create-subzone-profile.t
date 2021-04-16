$ ndcli create zone some.domain
WARNING - Creating zone some.domain without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr my.subzone.some.domain. A 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR my.subzone A 1.2.3.4 in zone some.domain
INFO - No zone found for 4.3.2.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr subzone.some.domain. cname web
INFO - Creating RR subzone CNAME web in zone some.domain
WARNING - web.some.domain. does not exist.

$ ndcli create zone-profile internal

$ ndcli modify zone-profile internal create rr @ CNAME web2
ERROR - It is not allowed to create a CNAME for a zone

$ ndcli modify zone-profile internal create rr @ mx 10 mintern00.schlund.de.
INFO - Creating RR @ MX 10 mintern00.schlund.de. in zone profile internal
WARNING - mintern00.schlund.de. does not exist.

$ ndcli create zone subzone.some.domain profile internal
INFO - Creating zone subzone.some.domain with profile internal
INFO - Creating views default for zone subzone.some.domain
INFO - Moving RR my.subzone A 1.2.3.4 in zone subzone.some.domain from zone some.domain
WARNING - Rejected to move RR subzone CNAME web in zone subzone.some.domain, deleted RR from zone some.domain

# Yes, with this operation subzone.some.domain. cname web got deleted.

$ ndcli list zone subzone.some.domain
record zone                ttl   type  value
@      subzone.some.domain 86400 SOA   localhost. hostmaster.internal. 2012120301 14400 3600 605000 86400
@      subzone.some.domain       MX    10 mintern00.schlund.de.
my     subzone.some.domain       A     1.2.3.4

$ ndcli delete zone subzone.some.domain --cleanup -q
$ ndcli delete zone some.domain -q
