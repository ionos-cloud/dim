# I hope this does not conflict with other
# use cases I made
#
# An Administrator should be able to see if a zone or a
# view is used in any zone-groups
#
# Also I haven't found an example for viewing a zone views modification time
# 

$ ndcli create zone fuh.de
WARNING - Creating zone fuh.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone-group internal

$ ndcli modify zone-group internal add zone fuh.de

$ ndcli show zone fuh.de
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
views:1
zone_groups:1
name:fuh.de

$ ndcli modify zone fuh.de create view pub
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli create zone-group public

$ ndcli modify zone-group public add zone fuh.de view pub

$ ndcli show zone fuh.de
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
views:2
name:fuh.de
zone_groups:2

$ ndcli show zone fuh.de view pub
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
zone_groups:1
name:fuh.de
view:pub

$ ndcli modify zone fuh.de rename view default to int

$ ndcli list zone fuh.de zone-groups
zone-group view
internal   int
public     pub

$ ndcli list zone fuh.de view int zone-groups
zone-group view
internal   int

$ ndcli delete zone-group internal
$ ndcli delete zone-group public

$ ndcli modify zone fuh.de delete view pub -q --cleanup
$ ndcli delete zone fuh.de

