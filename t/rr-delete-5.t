# Trying to delete a rr that does not exist issues an error.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone a.de create rr a.de a 1.2.3.4
WARNING - The left hand side of this record contains '.'. This will probably not do what you expect it to do.
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR a.de A 1.2.3.4 in zone a.de
$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2013041902 14400 3600 605000 86400
a.de   a.de       A    1.2.3.4
$ ndcli delete rr a.de. a 1.2.3.4
ERROR - a.de. A 1.2.3.4 does not exist
$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2013041902 14400 3600 605000 86400
a.de   a.de       A    1.2.3.4
