$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr www.a.de. a 1.0.0.1 -q
$ ndcli create rr www.a.de. cname web -q
ERROR - www.a.de. CNAME web cannot be created because other RRs with the same name or target exist
$ ndcli create rr w6.a.de. aaaa 2001:db8::1 -q
$ ndcli create rr w6.a.de. cname web -q
ERROR - w6.a.de. CNAME web cannot be created because other RRs with the same name or target exist
$ ndcli create rr a.de. cname other.domain.
ERROR - It is not allowed to create a CNAME for a zone
$ ndcli create rr web.a.de. ttl 600 cname www -q
$ ndcli create rr web.a.de. cname w6 -q
ERROR - web.a.de. CNAME w6 cannot be created because other RRs with the same name or target exist
$ ndcli list zone a.de
record zone ttl   type  value
@      a.de 86400 SOA   localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
w6     a.de       AAAA  2001:db8::1
web    a.de 600   CNAME www
www    a.de       A     1.0.0.1
$ ndcli delete zone a.de --cleanup
INFO - Deleting RR w6 AAAA 2001:db8::1 from zone a.de
INFO - Freeing IP 2001:db8::1 from layer3domain default
INFO - Deleting RR web 600 CNAME www from zone a.de
INFO - Deleting RR www A 1.0.0.1 from zone a.de
INFO - Freeing IP 1.0.0.1 from layer3domain default
