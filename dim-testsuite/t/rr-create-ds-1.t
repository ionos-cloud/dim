$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr subzone.a.de. ds 12345 3 1 123456789ABCDEF67890123456789ABCDEF67890
INFO - Creating RR subzone DS 12345 3 1 123456789ABCDEF67890123456789ABCDEF67890 in zone a.de
$ ndcli delete rr subzone.a.de. ds 12345 3 1 123456789ABCDEF67890123456789ABCDEF67890
INFO - Deleting RR subzone DS 12345 3 1 123456789ABCDEF67890123456789ABCDEF67890 from zone a.de
$ ndcli delete zone a.de
