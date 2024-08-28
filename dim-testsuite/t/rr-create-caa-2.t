$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr a.de. CAA 2 issue "ca.example.net"
ERROR - CAA Issuer critical only allows values 0, 1, 128
$ ndcli create rr a.de. CAA 0 issuer "ca.example.net"
ERROR - only CAA property tags "issue", "issuewild", "iodef" are allowed

$ ndcli create rr a.de. CAA 0 issue "ca.example.net"
INFO - Creating RR @ CAA 0 issue "ca.example.net" in zone a.de
$ ndcli create rr a.de. CAA 0 issue "Ca.example.net"
INFO - a.de. CAA 0 issue "ca.example.net" already exists

$ ndcli delete rr a.de. CAA 0 issue "ca.example.net"
INFO - Deleting RR @ CAA 0 issue "ca.example.net" from zone a.de
