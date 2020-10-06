$ ndcli create zone-profile c.de
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone a.de
ERROR - Zone a.de already exists
$ ndcli create zone c.de
ERROR - Zone profile c.de already exists
