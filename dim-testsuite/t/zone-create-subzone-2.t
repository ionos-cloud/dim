$ ndcli create zone some.domain
WARNING - Creating zone some.domain without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr subzone.some.domain. cname web
INFO - Creating RR subzone CNAME web in zone some.domain
WARNING - web.some.domain. does not exist.

$ ndcli modify zone some.domain create view us
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli create rr my.subzone.some.domain. a 1.2.3.4 view default
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR my.subzone A 1.2.3.4 in zone some.domain view default
INFO - No zone found for 4.3.2.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr this.subzone.some.domain. a 2.3.4.5 view us
INFO - Marked IP 2.3.4.5 from layer3domain default as static
INFO - Creating RR this.subzone A 2.3.4.5 in zone some.domain view us
INFO - No zone found for 5.4.3.2.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr subzone.some.domain. cname web2 view us
INFO - Creating RR subzone CNAME web2 in zone some.domain view us
WARNING - web2.some.domain. does not exist.

$ ndcli create rr c.this.subzone.some.domain. cname web3 view us
INFO - Creating RR c.this.subzone CNAME web3 in zone some.domain view us
WARNING - web3.some.domain. does not exist.

$ ndcli create zone subzone.some.domain
WARNING - Creating zone subzone.some.domain without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default, us for zone subzone.some.domain
WARNING - Rejected to move RR subzone CNAME web in zone subzone.some.domain view default, deleted RR from zone some.domain view default
INFO - Moving RR my.subzone A 1.2.3.4 in zone subzone.some.domain view default from zone some.domain view default
INFO - Moving RR this.subzone A 2.3.4.5 in zone subzone.some.domain view us from zone some.domain view us
WARNING - Rejected to move RR subzone CNAME web2 in zone subzone.some.domain view us, deleted RR from zone some.domain view us
INFO - Moving RR c.this.subzone CNAME web3 in zone subzone.some.domain view us from zone some.domain view us

$ ndcli list zone some.domain views
name
default
us
$ ndcli list zone subzone.some.domain views
name
default
us

$ ndcli list zone subzone.some.domain view us
record zone                ttl   type  value
@      subzone.some.domain 86400 SOA   localhost. hostmaster.subzone.some.domain. 2012112801 14400 3600 605000 86400
c.this subzone.some.domain       CNAME web3.some.domain.
this   subzone.some.domain       A     2.3.4.5

$ ndcli list zone subzone.some.domain view default
record zone                ttl   type  value
@      subzone.some.domain 86400 SOA   localhost. hostmaster.subzone.some.domain. 2012112801 14400 3600 605000 86400
my     subzone.some.domain       A     1.2.3.4

$ ndcli modify zone some.domain delete view us
$ ndcli modify zone subzone.some.domain delete view us --cleanup
INFO - Deleting RR c.this CNAME web3.some.domain. from zone subzone.some.domain view us
INFO - Deleting RR this A 2.3.4.5 from zone subzone.some.domain view us
INFO - Freeing IP 2.3.4.5 from layer3domain default
WARNING - Parent zone some.domain has no view named us, cannot clean up NS Records
$ ndcli delete zone subzone.some.domain --cleanup
INFO - Deleting RR my A 1.2.3.4 from zone subzone.some.domain
INFO - Freeing IP 1.2.3.4 from layer3domain default
$ ndcli delete zone some.domain
