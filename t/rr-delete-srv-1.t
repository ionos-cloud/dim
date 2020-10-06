$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. txt test
INFO - Creating RR @ TXT "test" in zone a.de
$ ndcli create rr a.de. a 1.1.1.1
INFO - Marked IP 1.1.1.1 from layer3domain default as static
INFO - Creating RR @ A 1.1.1.1 in zone a.de
INFO - No zone found for 1.1.1.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de.
INFO - Creating RR _ldap._tcp SRV 10 10 389 a.de. in zone a.de

# deleting the A record would leave SRV orphan
$ ndcli delete rr a.de. a
ERROR - a.de. is referenced by other records

# create a second target so deleting one won't orphan SRV
$ ndcli create rr a.de. ns ns.a.de.
INFO - Creating RR @ NS ns.a.de. in zone a.de
WARNING - ns.a.de. does not exist.
$ ndcli delete rr a.de. a -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr a.de. ns -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ NS ns.a.de. from zone a.de

$ ndcli delete rr a.de. a
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
# the NS is the only target left
$ ndcli delete rr a.de. ns
ERROR - a.de. is referenced by other records

$ ndcli create rr a.de. a 1.1.1.1
INFO - Marked IP 1.1.1.1 from layer3domain default as static
INFO - Creating RR @ A 1.1.1.1 in zone a.de
INFO - No zone found for 1.1.1.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
# ok to delete NS, A still left
$ ndcli delete rr a.de. ns
INFO - Deleting RR @ NS ns.a.de. from zone a.de
