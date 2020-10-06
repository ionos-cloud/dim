$ ndcli create zone some.domain primary ins01.internal.test. mail dnsadmin@1und1.de
WARNING - Creating zone some.domain without profile
$ ndcli modify zone some.domain create view us primary us-ns.internal.test. mail dnsadmin@company.com
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create zone subzone.some.domain primary subzone-ns.internal.test. mail subzoneadmin@company.com
WARNING - Creating zone subzone.some.domain without profile
INFO - Creating views default, us for zone subzone.some.domain
$ ndcli list zone subzone.some.domain views
name
default
us
$ ndcli list zone subzone.some.domain view us
record zone                ttl   type value
@      subzone.some.domain 86400 SOA  subzone-ns.internal.test. subzoneadmin.company.com. 2012121201 14400 3600 605000 86400
$ ndcli list zone subzone.some.domain view default
record zone                ttl   type value
@      subzone.some.domain 86400 SOA  subzone-ns.internal.test. subzoneadmin.company.com. 2012120301 14400 3600 605000 86400
$ ndcli modify zone some.domain delete view us
$ ndcli modify zone subzone.some.domain delete view us --cleanup
WARNING - Parent zone some.domain has no view named us, cannot clean up NS Records
$ ndcli delete zone subzone.some.domain --cleanup
$ ndcli delete zone some.domain
