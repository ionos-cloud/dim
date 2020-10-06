$ ndcli create zone-profile profile primary ns.a.com.
$ ndcli modify zone-profile profile create rr @ ns ns.a.com.
INFO - Creating RR @ NS ns.a.com. in zone profile profile
WARNING - ns.a.com. does not exist.

$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr subzone.a.com. ns other-ns.a.com.
INFO - Creating RR subzone NS other-ns.a.com. in zone a.com
WARNING - other-ns.a.com. does not exist.
$ ndcli modify zone a.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli create zone subzone.a.com profile profile
INFO - Creating zone subzone.a.com with profile profile
INFO - Creating views default, internal for zone subzone.a.com
INFO - Moving RR subzone NS other-ns.a.com. in zone subzone.a.com view default from zone a.com view default
INFO - Creating RR subzone NS other-ns.a.com. in zone a.com view default
WARNING - other-ns.a.com. does not exist.
WARNING - The name subzone.a.com. already existed, creating round robin record
INFO - Creating RR subzone NS ns.a.com. in zone a.com view default
WARNING - ns.a.com. does not exist.
INFO - Creating RR subzone NS ns.a.com. in zone a.com view internal
WARNING - ns.a.com. does not exist.

$ ndcli list zone subzone.a.com view default
record zone          ttl   type value
@      subzone.a.com 86400 SOA  ns.a.com. hostmaster.profile. 2016072202 14400 3600 605000 86400
@      subzone.a.com       NS   other-ns.a.com.
@      subzone.a.com       NS   ns.a.com.

$ ndcli list zone a.com view default
record  zone  ttl   type value
@       a.com 86400 SOA  localhost. hostmaster.a.com. 2016072205 14400 3600 605000 86400
subzone a.com       NS   other-ns.a.com.
subzone a.com       NS   ns.a.com.

$ ndcli modify zone subzone.a.com delete view internal -c
INFO - Deleting RR @ NS ns.a.com. from zone subzone.a.com view internal
INFO - Deleting RR subzone NS ns.a.com. from zone a.com view internal

$ ndcli modify zone subzone.a.com create view internal profile profile
INFO - Creating RR subzone NS ns.a.com. in zone a.com view internal
WARNING - ns.a.com. does not exist.

# Creating the view again without cleaning up the records from parent
$ ndcli modify zone subzone.a.com rename view internal to other
$ ndcli modify zone subzone.a.com delete view other -c
INFO - Deleting RR @ NS ns.a.com. from zone subzone.a.com view other
WARNING - Parent zone a.com has no view named other, cannot clean up NS Records
$ ndcli modify zone subzone.a.com create view internal profile profile
INFO - subzone.a.com. NS ns.a.com. already exists

$ ndcli modify zone subzone.a.com delete view default -c
INFO - Deleting RR @ NS other-ns.a.com. from zone subzone.a.com view default
INFO - Deleting RR @ NS ns.a.com. from zone subzone.a.com view default
INFO - Deleting RR subzone NS other-ns.a.com. from zone a.com view default
INFO - Deleting RR subzone NS ns.a.com. from zone a.com view default

$ ndcli delete zone subzone.a.com -c
INFO - Deleting RR @ NS ns.a.com. from zone subzone.a.com
INFO - Deleting RR subzone NS ns.a.com. from zone a.com view internal
