$ ndcli create zone some.domain
WARNING - Creating zone some.domain without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr ns.subzone.some.domain. cname ns.subzone.some.domain.
INFO - Creating RR ns.subzone CNAME ns.subzone.some.domain. in zone some.domain
WARNING - ns.subzone.some.domain. does not exist.
$ ndcli create zone-profile profile
$ ndcli modify zone-profile profile create rr ns cname other.some.domain
INFO - Creating RR ns CNAME other.some.domain in zone profile profile
WARNING - other.some.domain.profile. does not exist.
$ ndcli create zone subzone.some.domain profile profile
INFO - Creating zone subzone.some.domain with profile profile
INFO - Creating views default for zone subzone.some.domain
INFO - Moving RR ns.subzone CNAME ns.subzone.some.domain. in zone subzone.some.domain from zone some.domain
$ ndcli list zone subzone.some.domain
record zone                ttl   type  value
@      subzone.some.domain 86400 SOA   localhost. hostmaster.profile. 2012121901 14400 3600 605000 86400
ns     subzone.some.domain       CNAME ns.subzone.some.domain.
