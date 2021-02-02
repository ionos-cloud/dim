$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli list zones
name views zone_groups
.    1     0

$ ndcli delete zone .
$ ndcli list zones
name views zone_groups

$ ndcli list zone .
ERROR - Zone . does not exist

$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr 4.3.2.1.in-addr.arpa. ptr a.de.
ERROR - Cannot create PTR records in root zone.

$ ndcli modify zone . create view public
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone . rename view default to internal
$ ndcli modify zone . delete view public
$ ndcli modify zone . set view internal ttl 1000
$ ndcli modify zone . create rr @ txt test
INFO - Creating RR @ TXT "test" in zone .

$ ndcli modify zone . set attrs key:value
$ ndcli show zone .
created:2013-03-04 17:48:34
created_by:admin
key:value
modified:2013-03-04 17:48:34
modified_by:admin
name:.
views:1
$ ndcli list zone .
record zone ttl  type value
@      .    1000 SOA  localhost. hostmaster.root. 2013032503 14400 3600 605000 86400
@      .         TXT  "test"
$ ndcli list rrs *.
record zone view     ttl  type value
@      .    internal      TXT  "test"
@      .    internal 1000 SOA  localhost. hostmaster.root. 2013040103 14400 3600 605000 86400
INFO - Result for list rrs *.
$ ndcli dump zone .
.	1000	IN	SOA	localhost. hostmaster.root. 2013032503 14400 3600 605000 86400
.	1000	IN	TXT	"test"

$ ndcli create user-group g
$ ndcli modify user-group g grant create_rr .

$ ndcli list user-group g rights
action    object
create_rr .
