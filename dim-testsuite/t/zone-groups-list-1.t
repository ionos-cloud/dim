
$ ndcli create zone-group internal
$ ndcli create zone-group public

$ ndcli modify zone-group internal set comment "Zone group for all internal zones except DataCenter local Zones"

$ ndcli list zone-groups
name     comment
internal Zone group for all internal zones except DataCenter local Zones
public

$ ndcli delete zone-group internal
$ ndcli delete zone-group public

