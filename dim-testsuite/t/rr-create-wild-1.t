$ ndcli create zone pfuh.de
WARNING - Creating zone pfuh.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create container 74.209.0.0/16
INFO - Creating container 74.209.0.0/16 in layer3domain default
$ ndcli create pool test-pfuh
$ ndcli modify pool test-pfuh add subnet 74.209.12.64/27
INFO - Created subnet 74.209.12.64/27 in layer3domain default
WARNING - Creating zone 12.209.74.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr prod.pfuh.de. a 74.209.12.67
INFO - Marked IP 74.209.12.67 from layer3domain default as static
INFO - Creating RR prod A 74.209.12.67 in zone pfuh.de
INFO - Creating RR 67 PTR prod.pfuh.de. in zone 12.209.74.in-addr.arpa
$ ndcli create rr *.prod.pfuh.de. a 74.209.12.67
ERROR - Use --only-forward to create a wildcard record
$ ndcli create rr *.prod.pfuh.de. a 74.209.12.67 --only-forward 
INFO - Creating RR *.prod A 74.209.12.67 in zone pfuh.de
$ ndcli delete rr prod.pfuh.de.
INFO - Deleting RR prod A 74.209.12.67 from zone pfuh.de
INFO - Deleting RR 67 PTR prod.pfuh.de. from zone 12.209.74.in-addr.arpa
$ ndcli delete rr *.prod.pfuh.de.
INFO - Deleting RR *.prod A 74.209.12.67 from zone pfuh.de
INFO - Freeing IP 74.209.12.67 from layer3domain default
$ ndcli modify pool test-pfuh remove subnet 74.209.12.64/27
INFO - Deleting zone 12.209.74.in-addr.arpa
$ ndcli delete pool test-pfuh
$ ndcli delete zone pfuh.de
$ ndcli delete container 74.209.0.0/16
INFO - Deleting container 74.209.0.0/16 from layer3domain default

