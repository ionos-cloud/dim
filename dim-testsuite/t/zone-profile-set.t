$ ndcli create zone-profile internal

$ ndcli modify zone-profile internal set primary ns.test.com. mail dnsadmin@test.com
$ ndcli list zone-profile internal
record ttl   type value
@      86400 SOA  ns.test.com. dnsadmin.test.com. 2012121902 14400 3600 605000 86400
$ ndcli modify zone-profile internal set refresh 1000 attrs aname:avalue
ERROR - SOA values and attributes cannot be set at the same time
$ ndcli modify zone-profile internal set attrs aname:avalue
$ ndcli show zone-profile internal
aname:avalue
created:2012-12-19 14:05:09
created_by:admin
modified:2012-12-19 14:05:09
modified_by:admin
name:internal
