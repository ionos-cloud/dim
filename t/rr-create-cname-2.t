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

$ ndcli create rr txt.a.de. txt "some txt" -q
$ ndcli create rr txt.a.de. cname some.c.name.
ERROR - txt.a.de. CNAME some.c.name. cannot be created because other RRs with the same name or target exist

$ ndcli delete rr txt.a.de. -q
$ ndcli create rr txt.a.de. cname some.c.name. -q
$ ndcli create rr txt.a.de. txt "some txt" -q
ERROR - txt.a.de. TXT "some txt" cannot be created because a CNAME with the same name exists
$ ndcli delete rr txt.a.de. -q

$ ndcli create rr txt.a.de. txt "some txt" -q
$ ndcli create rr rp.a.de. rp john@doe.de txt.a.de. -q
$ ndcli create rr rp.a.de. cname some.c.name.
ERROR - rp.a.de. CNAME some.c.name. cannot be created because other RRs with the same name or target exist

$ ndcli delete rr rp.a.de. -q
$ ndcli create rr rp.a.de. cname some.c.name. -q
$ ndcli create rr rp.a.de. rp john@doe.de txt.a.de. -q
ERROR - rp.a.de. RP john.doe.de. txt.a.de. cannot be created because a CNAME with the same name exists
$ ndcli delete rr rp.a.de. -q
$ ndcli delete rr txt.a.de. -q

# and so on and so on for NS/MX/PTR whatever

$ ndcli create rr web.a.de. cname some.c.name.
ERROR - web.a.de. CNAME some.c.name. cannot be created because other RRs with the same name or target exist

$ ndcli create rr web.a.de. txt "some txt"
ERROR - web.a.de. TXT "some txt" cannot be created because a CNAME with the same name exists

$ ndcli delete zone a.de --cleanup
INFO - Deleting RR www A 1.0.0.1 from zone a.de
INFO - Freeing IP 2001:db8::1 from layer3domain default
INFO - Deleting RR w6 AAAA 2001:db8::1 from zone a.de
INFO - Deleting RR web 600 CNAME www from zone a.de
INFO - Freeing IP 1.0.0.1 from layer3domain default
