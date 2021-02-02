$ ndcli show rr a.de.
ERROR - Zone for a.de. not found

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli show rr a.de.
ERROR - No records found.

$ ndcli create rr a.de. mx 10 mx.a.de. -c "some comment"
INFO - Creating RR @ MX 10 mx.a.de. comment some comment in zone a.de
WARNING - mx.a.de. does not exist.

$ ndcli create rr a.de. txt "some txt" -c "some other comment"
INFO - Creating RR @ TXT "some txt" comment some other comment in zone a.de

$ ndcli show rr a.de.
ERROR - a.de. is ambiguous

$ ndcli show rr a.de. mx
created:2012-11-14 11:03:02
created_by:user
modified:2012-11-14 11:03:02
modified_by:user
comment:some comment
rr:@ MX 10 mx.a.de.
zone:a.de

#Usage: ndcli show rr NAME mx [PREFERENCE EXCHANGE] [view VIEW]
$ ndcli show rr a.de. mx 10 no.no.
ERROR - No records found.
