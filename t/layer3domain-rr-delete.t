$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 1.1.1.1
INFO - Marked IP 1.1.1.1 from layer3domain default as static
INFO - Creating RR @ A 1.1.1.1 in zone a.de
INFO - No zone found for 1.1.1.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli delete rr -n a.de.
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a 1.1.1.1
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a 1.1.1.1 -R
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a 1.1.1.1 view default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a 1.1.1.1 layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a 1.1.1.1 view default layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a view default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default
$ ndcli delete rr -n a.de. a view default layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ A 1.1.1.1 from zone a.de
INFO - Freeing IP 1.1.1.1 from layer3domain default

$ ndcli create rr x.a.de. a 1.1.1.2
INFO - Marked IP 1.1.1.2 from layer3domain default as static
INFO - Creating RR x A 1.1.1.2 in zone a.de
INFO - No zone found for 2.1.1.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli modify zone a.de delete rr -n x
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a 1.1.1.2
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a 1.1.1.2 -R
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a 1.1.1.2 view default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a 1.1.1.2 view default layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a view default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
$ ndcli modify zone a.de delete rr -n x a view default layer3domain default
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR x A 1.1.1.2 from zone a.de
INFO - Freeing IP 1.1.1.2 from layer3domain default
