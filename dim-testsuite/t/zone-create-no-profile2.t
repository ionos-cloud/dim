$ ndcli create zone some.domain primary ins01.internal.test. mail dnsadmin@company.com "comment: I think I know how to do this"
WARNING - Creating zone some.domain without profile
$ ndcli dump zone some.domain
some.domain.	86400	IN	SOA	ins01.internal.test. dnsadmin.company.com. 2012112701 14400 3600 605000 86400
$ ndcli show zone some.domain
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
views:1
name:some.domain
comment: I think I know how to do this
$ ndcli delete zone some.domain
