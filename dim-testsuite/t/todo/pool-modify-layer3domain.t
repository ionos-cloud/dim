# initialize layer3domains basic setup
$ ndcli create zone-group a
$ ndcli create zone-group b
$ ndcli create output a plugin bind
$ ndcli create output b plugin bind
$ ndcli modify output a add zone-group a
$ ndcli modify output b add zone-group b
$ ndcli create zone t
WARNING - Creating zone t without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create layer3domain a type a
$ ndcli create layer3domain b type b
$ ndcli create container 10.0.0.0/8 layer3domain a
INFO - Creating container 10.0.0.0/8 in layer3domain a
$ ndcli create container 10.0.0.0/8 layer3domain b
INFO - Creating container 10.0.0.0/8 in layer3domain b

$ ndcli create pool a layer3domain a
$ ndcli modify pool a add subnet 10.0.5.0/28
INFO - Created subnet 10.0.5.0/28 in layer3domain a
WARNING - Creating zone 5.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone-group a add zone 5.0.10.in-addr.arpa view a
$ ndcli create rr a.t. a 10.0.5.1
INFO - Marked IP 10.0.5.1 from layer3domain a as static
INFO - Creating RR a A 10.0.5.1 in zone t
INFO - Creating RR 1 PTR a.t. in zone 5.0.10.in-addr.arpa

$ ndcli create pool b layer3domain a
$ ndcli modify pool b add subnet 10.0.5.64/28
INFO - Created subnet 10.0.5.0/28 in layer3domain a
$ ndcli create rr a.t. a 10.0.5.65
INFO - Marked IP 10.0.5.65 from layer3domain a as static
INFO - Creating RR b A 10.0.5.65 in zone t
INFO - Creating RR 65 PTR b.t. in zone 5.0.10.in-addr.arpa

$ ndcli modify pool a set layer3domain b
INFO - Changing subnet 10.0.5.0/28 to new parent 10.0.0.0/8 in layer3domain b
INFO - Creating view b in zone 5.0.10.in-addr.arpa without profile
INFO - Changing child 10.0.5.0 of subnet 10.0.5.0/28 to layer3domain b
INFO - Changing child 10.0.5.1 of subnet 10.0.5.0/28 to layer3domain b
INFO - Deleting RR 1 PTR a.t. from zone 5.0.10.in-addr.arpa view a
INFO - Changing child 10.0.5.15 of subnet 10.0.5.0/28 to layer3domain b
WARNING - Deleting view a from zone 5.0.10.in-addr.arpa failed

$ ndcli modify pool b set layer3domain b
INFO - Changing subnet 10.0.5.64/28 to new parent 10.0.0.0/8 in layer3domain b
INFO - Changing child 10.0.5.64 of subnet 10.0.5.64/28 to layer3domain b
INFO - Changing child 10.0.5.65 of subnet 10.0.5.64/28 to layer3domain b
INFO - Deleting RR 65 PTR b.t. from zone 5.0.10.in-addr.arpa view a
INFO - Changing child 10.0.5.79 of subnet 10.0.5.64/28 to layer3domain b
INFO - Deleting view a from zone 5.0.10.in-addr.arpa


$ ndcli modify pool a remove subnet 10.0.5.0/28 -f -c -q
$ ndcli delete pool a
$ ndcli modify pool b remove subnet 10.0.5.64/28 -f -c -q
$ ndcli delete pool b

$ndcli delete zone t -f -c -q

$ ndcli delete output a
$ ndcli delete output b

$ ndcli delete zone-group a
$ ndcli delete zone-group b
