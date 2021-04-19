$ ndcli create zone-profile internal "comment:Profile for all internal Zones"
$ ndcli modify zone-profile internal set primary ins01.internal.test.
$ ndcli modify zone-profile internal set mail dnsadmin@company.com
$ ndcli modify zone-profile internal create rr @ NS ins01.internal.test. -q
$ ndcli modify zone-profile internal create rr @ NS ins02.internal.test. -q
$ ndcli modify zone-profile internal create rr @ MX 10 mintern00.example.com. -q
$ ndcli modify zone-profile internal create rr @ MX 10 mintern01.example.com. -q
$ ndcli create zone project.test profile internal "comment:For the mail project"
INFO - Creating zone project.test with profile internal
$ ndcli dump zone project.test
project.test.	86400	IN	SOA	ins01.internal.test. dnsadmin.company.com. 2012112701 14400 3600 605000 86400
project.test.	86400	IN	NS	ins01.internal.test.
project.test.	86400	IN	NS	ins02.internal.test.
project.test.	86400	IN	MX	10 mintern00.example.com.
project.test.	86400	IN	MX	10 mintern01.example.com.
$ ndcli list zone project.test
record zone         ttl   type value
@      project.test 86400 SOA  ins01.internal.test. dnsadmin.company.com. 2012102601 14400 3600 605000 86400
@      project.test       NS   ins01.internal.test.
@      project.test       NS   ins02.internal.test.
@      project.test       MX   10 mintern00.example.com.
@      project.test       MX   10 mintern01.example.com.
$ ndcli show zone project.test
comment:For the mail project
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
name:project.test
views:1
$ ndcli delete zone-profile internal
$ ndcli delete zone project.test
ERROR - Zone not empty.
$ ndcli delete zone project.test --cleanup
INFO - Deleting RR @ NS ins01.internal.test. from zone project.test
INFO - Deleting RR @ NS ins02.internal.test. from zone project.test
INFO - Deleting RR @ MX 10 mintern00.example.com. from zone project.test
INFO - Deleting RR @ MX 10 mintern01.example.com. from zone project.test
