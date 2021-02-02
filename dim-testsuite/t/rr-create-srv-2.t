$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de. -n
INFO - Dryrun mode, no data will be modified
INFO - Creating RR _ldap._tcp SRV 10 10 389 a.de. in zone a.de
WARNING - a.de. does not exist.

$ ndcli create rr a.de. txt test
INFO - Creating RR @ TXT "test" in zone a.de

# fails because targets are present, but there's no A, AAAA or NS
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de.
ERROR - The target of SRV records must have A, AAAA or NS resource records
$ ndcli create rr a.de. a 1.1.1.1
INFO - Marked IP 1.1.1.1 from layer3domain default as static
INFO - Creating RR @ A 1.1.1.1 in zone a.de
INFO - No zone found for 1.1.1.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de.
INFO - Creating RR _ldap._tcp SRV 10 10 389 a.de. in zone a.de

$ ndcli delete rr _ldap._tcp.a.de.
INFO - Deleting RR _ldap._tcp SRV 10 10 389 a.de. from zone a.de
$ ndcli delete rr a.de. a
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default

$ ndcli create rr a.de. ns ns.a.de.
INFO - Creating RR @ NS ns.a.de. in zone a.de
WARNING - ns.a.de. does not exist.
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de.
INFO - Creating RR _ldap._tcp SRV 10 10 389 a.de. in zone a.de
