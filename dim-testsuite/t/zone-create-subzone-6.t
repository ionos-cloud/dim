$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone b.a.com
WARNING - Creating zone b.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone b.a.com
$ ndcli modify zone b.a.com create view v
WARNING - You created a view without specifing a profile, your view is totally empty.
WARNING - Parent zone a.com has no view named v, automatic NS record management impossible
$ ndcli modify zone b.a.com delete view v
WARNING - Parent zone a.com has no view named v, cannot clean up NS Records
