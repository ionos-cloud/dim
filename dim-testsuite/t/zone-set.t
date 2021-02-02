$ ndcli create zone test.com
WARNING - Creating zone test.com without profile
WARNING - Primary NS for this Domain is now localhost.

# With a single view

$ ndcli modify zone test.com set primary ns.test.com. mail dnsadmin@test.com
$ ndcli modify zone test.com set ttl 123
$ ndcli list zone test.com
record zone     ttl type value
@      test.com 123 SOA  ns.test.com. dnsadmin.test.com. 2013021103 14400 3600 605000 86400
$ ndcli modify zone test.com set refresh 1000 attrs aname:avalue
ERROR - SOA values and attributes cannot be set at the same time
$ ndcli modify zone test.com set attrs aname:avalue
$ ndcli show zone test.com
aname:avalue
created:2012-12-19 14:05:09
created_by:admin
modified:2012-12-19 14:05:09
modified_by:admin
name:test.com
views:1

# With multiple views

$ ndcli modify zone test.com create view another
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone test.com set view default attrs aaa:bbb
ERROR - Views cannot have attributes
$ ndcli modify zone test.com set primary ns.test.com.
ERROR - A view must be selected from: another default
$ ndcli modify zone test.com set view another primary another-ns.test.com.
$ ndcli modify zone test.com set view another attrs aaa:bbb
ERROR - Views cannot have attributes
$ ndcli list zone test.com view another
record zone     ttl   type value
@      test.com 86400 SOA  another-ns.test.com. hostmaster.test.com. 2012121902 14400 3600 605000 86400

$ ndcli modify zone test.com delete view another
$ ndcli delete zone test.com
