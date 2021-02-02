# From a very productive conversation with andrei:
# - if the target of NS/MX/SRV is not known to dim (because the zone is not managed with this dim instance, or it has not yet been created) a warning is printed. Thats it.
# - if the target can be found, it must not be a cname (If a cname and something else is found, then the create cname needs serious fixes). An Error is printed, if it is.
# - the resultset of the search for the target name must contain an A or AAAA Record.

$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de mail hostmaster@a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

# Try to create a MX pointing to a name outside of dim -> give warning
$ ndcli create rr a.de. mx 10 mx.outside.zone.
INFO - Creating RR @ MX 10 mx.outside.zone. in zone a.de
WARNING - mx.outside.zone. does not exist.

# Try to create a MX pointing to a CNAME -> must fail
$ ndcli create rr mx.a.de. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR mx A 1.2.3.4 in zone a.de
INFO - Creating RR 4 PTR mx.a.de. in zone 3.2.1.in-addr.arpa
$ ndcli create rr mail.a.de. CNAME mx
INFO - Creating RR mail CNAME mx in zone a.de
$ ndcli create rr a.de. mx 10 mail.a.de.
ERROR - The target of MX records must have A or AAAA resource records

# Try to create a MX pointing only to a TXT -> must fail
# Try to create a MX pointing only to a NS -> must fail
# Try to create a MX pointing only to a MX -> must fail
# Try to create a MX pointing only to a RP -> must fail
# Try to create a MX pointing only to a PTR -> must fail

# Try to create a MX pointing to just an A -> OK
$ ndcli create rr a.de. mx 10 mx.a.de.
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ MX 10 mx.a.de. in zone a.de

# Try to create a MX pointing to just an AAAA -> OK
$ ndcli create rr mx6.a.de. aaaa 2001:db8:400:12::25:2
INFO - Marked IP 2001:db8:400:12::25:2 from layer3domain default as static
INFO - Creating RR mx6 AAAA 2001:db8:400:12::25:2 in zone a.de
INFO - No zone found for 2.0.0.0.5.2.0.0.0.0.0.0.0.0.0.0.2.1.0.0.0.0.4.0.8.b.d.0.1.0.0.2.ip6.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr a.de. mx 10 mx6.a.de.
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ MX 10 mx6.a.de. in zone a.de

# Try to create a MX pointing to an A, A, AAAA, AAAA, TXT, RP -> OK
$ ndcli create rr mx7.a.de. aaaa 2001:db8:400:12::25:100 -q
$ ndcli create rr mx7.a.de. aaaa 2001:db8:400:12::25:200 -q
$ ndcli create rr mx7.a.de. a 1.2.3.10 -q
$ ndcli create rr mx7.a.de. a 1.2.3.11 -q
$ ndcli create rr mx7.a.de. txt "some info" -q
$ ndcli create rr mx7.a.de. rp thomas@mieslinger.de mx7.a.de. -q
$ ndcli create rr a.de. mx 10 mx7.a.de.
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ MX 10 mx7.a.de. in zone a.de

$ ndcli delete zone a.de --cleanup -q
$ ndcli delete zone 3.2.1.in-addr.arpa --cleanup
$ ndcli modify pool apool remove subnet 1.2.3.0/24
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
