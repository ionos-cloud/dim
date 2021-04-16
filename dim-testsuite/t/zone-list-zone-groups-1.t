$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone a.de create view public
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create zone b.de
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone-group internal
$ ndcli modify zone-group internal add zone a.de view default

$ ndcli create zone-group public
$ ndcli modify zone-group public add zone a.de view public

$ ndcli create output pdns plugin pdns-db db-uri "uri" comment "comment"
$ ndcli modify output pdns add zone-group internal

$ ndcli list zones *.de
INFO - Result for list zones *.de
name views zone_groups
a.de 2     2
b.de 1     0

$ ndcli show zone a.de
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
name:a.de
views:2
zone_groups:2

$ ndcli list zone a.de zone-groups
zone-group view
internal   default
public     public

$ ndcli list zone-group internal outputs
name plugin  comment
pdns pdns-db comment
