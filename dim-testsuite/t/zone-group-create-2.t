# Introducing zone-group rename

$ ndcli create zone-group public

$ ndcli create zone a.ms
WARNING - Creating zone a.ms without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone-group public add zone a.ms

$ ndcli list zone-group public
zone view
a.ms default

$ ndcli delete zone a.ms

$ ndcli list zone-group public
zone view

$ ndcli rename zone-group public to empty

$ ndcli delete zone-group empty

