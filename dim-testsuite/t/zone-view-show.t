$ ndcli create zone a.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone a.domain without profile
$ ndcli create rr a.domain. ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone a.domain
WARNING - ins01.internal.test. does not exist.
$ ndcli create rr www.a.domain. a 192.168.78.2
INFO - Marked IP 192.168.78.2 from layer3domain default as static
INFO - Creating RR www A 192.168.78.2 in zone a.domain
INFO - No zone found for 2.78.168.192.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.domain. ttl 1200 mx 10 mail.other.domain.
INFO - Creating RR @ 1200 MX 10 mail.other.domain. in zone a.domain
WARNING - mail.other.domain. does not exist.
$ ndcli modify zone a.domain create view public primary ns.a.domain. mail dnsadmin@company.com
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create rr a.domain. ns ns.some.net. view default
WARNING - The name a.domain. already existed, creating round robin record
INFO - Creating RR @ NS ns.some.net. in zone a.domain view default
WARNING - ns.some.net. does not exist.
$ ndcli create rr www.a.domain. a 2.112.3.7 view public
INFO - Marked IP 2.112.3.7 from layer3domain default as static
INFO - Creating RR www A 2.112.3.7 in zone a.domain view public
INFO - No zone found for 7.3.112.2.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli show zone a.domain
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
name:a.domain
views:2
$ ndcli show zone a.domain view public
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
name:a.domain
view:public
$ ndcli modify zone a.domain delete view public --cleanup
INFO - Deleting RR www A 2.112.3.7 from zone a.domain view public
INFO - Freeing IP 2.112.3.7 from layer3domain default
$ ndcli delete zone a.domain --cleanup
INFO - Deleting RR @ NS ins01.internal.test. from zone a.domain
INFO - Deleting RR @ 1200 MX 10 mail.other.domain. from zone a.domain
INFO - Deleting RR @ NS ns.some.net. from zone a.domain
INFO - Deleting RR www A 192.168.78.2 from zone a.domain
INFO - Freeing IP 192.168.78.2 from layer3domain default
