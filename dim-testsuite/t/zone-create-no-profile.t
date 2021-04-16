$ ndcli create zone some.domain "comment: I think I know how to do this"
WARNING - Creating zone some.domain without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli dump zone some.domain
some.domain.	86400	IN	SOA	localhost. hostmaster.some.domain. 2012121901 14400 3600 605000 86400
$ ndcli modify zone some.domain set primary ins01.internal.test.
$ ndcli modify zone some.domain set mail dnsadmin@company.com
$ ndcli dump zone some.domain
some.domain.	86400	IN	SOA	ins01.internal.test. dnsadmin.company.com. 2012121903 14400 3600 605000 86400
$ ndcli show zone some.domain
comment: I think I know how to do this
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
name:some.domain
views:1
$ ndcli delete zone some.domain --cleanup
