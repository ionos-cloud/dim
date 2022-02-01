# initialize layer3domains basic setup
$ ndcli create zone-group test
$ ndcli create output test plugin bind
$ ndcli modify output test add zone-group test
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
$ ndcli modify pool a add subnet 10.0.5.0/24
INFO - Created subnet 10.0.5.0/24 in layer3domain a
WARNING - Creating zone 5.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool a add subnet 10.23.0.0/28
INFO - Created subnet 10.23.0.0/28 in layer3domain a
WARNING - Creating zone 0.23.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
# TODO replace with PTR
$ ndcli create rr a.t. A 10.0.5.5 layer3domain a
INFO - Marked IP 10.0.5.5 from layer3domain a as static
INFO - Creating RR a A 10.0.5.5 in zone t
INFO - Creating RR 5 PTR a.t. in zone 5.0.10.in-addr.arpa
$ ndcli modify pool a mark delegation 10.0.5.64/30
created:2022-01-21 13:12:21.858537
ip:10.0.5.64/30
layer3domain:a
mask:255.255.255.0
modified:2022-01-21 13:12:21.858562
modified_by:admin
pool:a
reverse_zone:5.0.10.in-addr.arpa
status:Delegation
subnet:10.0.5.0/24
# TODO replace with PTR
$ ndcli create rr b.t. A 10.0.5.66 layer3domain a
INFO - Marked IP 10.0.5.66 from layer3domain a as static
INFO - Creating RR b A 10.0.5.66 in zone t
INFO - Creating RR 66 PTR b.t. in zone 5.0.10.in-addr.arpa
# create a collision target in layer3domain b
$ ndcli create container 10.0.5.0/24 layer3domain b
INFO - Creating container 10.0.5.0/24 in layer3domain b
$ ndcli modify pool a set layer3domain b
ERROR - subnet 10.0.5.0/24 can't be moved, 1 existing containers, subnets or static entries are in the way

# remove overlapping container and create partial overlap
$ ndcli delete container 10.0.5.0/24 layer3domain b
INFO - Deleting container 10.0.5.0/24 from layer3domain b
$ ndcli create pool fail layer3domain b
$ ndcli modify pool fail add subnet 10.0.4.0/22 --allow-overlap
INFO - Created subnet 10.0.4.0/22 in layer3domain b
WARNING - 10.0.4.0/22 in layer3domain b overlaps with 10.0.5.0/24 in layer3domain a
WARNING - Creating zone 4.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating view b in zone 5.0.10.in-addr.arpa without profile
WARNING - Creating zone 6.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 7.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool a set layer3domain b
ERROR - subnet 10.0.5.0/24 can't be moved, 3 existing containers, subnets or static entries are in the way

## cleanup everything and make final move happen
$ ndcli modify pool fail remove subnet 10.0.4.0/22
INFO - Deleting zone 4.0.10.in-addr.arpa
INFO - Deleting view b from zone 5.0.10.in-addr.arpa
INFO - Deleting zone 6.0.10.in-addr.arpa
INFO - Deleting zone 7.0.10.in-addr.arpa
$ ndcli delete pool fail

# check state before final move
$ ndcli list pool a delegations
INFO - Total free IPs: 3
delegation   free total
10.0.5.64/30    3     4
$ ndcli list zone 5.0.10.in-addr.arpa views
name
a
$ ndcli show ip 10.0.5.66 layer3domain a
created:2022-02-01 09:14:46
delegation:10.0.5.64/30
ip:10.0.5.66
layer3domain:a
mask:255.255.255.0
modified:2022-02-01 09:14:46
modified_by:admin
pool:a
ptr_target:b.t.
reverse_zone:5.0.10.in-addr.arpa
status:Static
subnet:10.0.5.0/24

$ ndcli modify pool a set layer3domain b
INFO - Changing subnet 10.0.5.0/24 to new parent 10.0.0.0/8 in layer3domain b
INFO - Creating view b in zone 5.0.10.in-addr.arpa without profile
INFO - Changing child 10.0.5.0 of subnet 10.0.5.0/24 to layer3domain b
INFO - Changing child 10.0.5.5 of subnet 10.0.5.0/24 to layer3domain b
INFO - Deleting RR 5 PTR a.t. from zone 5.0.10.in-addr.arpa view a
INFO - Creating RR 5 PTR a.t. comment None in zone 5.0.10.in-addr.arpa view b
INFO - Changing child 10.0.5.64/30 of subnet 10.0.5.0/24 to layer3domain b
INFO - Changing child 10.0.5.255 of subnet 10.0.5.0/24 to layer3domain b
INFO - Changing child 10.0.5.66 of subnet 10.0.5.0/24 to layer3domain b
INFO - Deleting RR 66 PTR b.t. from zone 5.0.10.in-addr.arpa view a
INFO - Creating RR 66 PTR b.t. comment None in zone 5.0.10.in-addr.arpa view b
INFO - Deleting view a from zone 5.0.10.in-addr.arpa
INFO - Changing subnet 10.23.0.0/28 to new parent 10.0.0.0/8 in layer3domain b
INFO - Creating view b in zone 0.23.10.in-addr.arpa without profile
INFO - Changing child 10.23.0.0 of subnet 10.23.0.0/28 to layer3domain b
INFO - Changing child 10.23.0.15 of subnet 10.23.0.0/28 to layer3domain b
INFO - Deleting view a from zone 0.23.10.in-addr.arpa

# check state after the move
$ ndcli list pool a delegations
INFO - Total free IPs: 3
delegation   free total
10.0.5.64/30    3     4
$ ndcli list zone 5.0.10.in-addr.arpa views
name
b
$ ndcli show ip 10.0.5.66 layer3domain a
ip:10.0.5.66
status:Available
$ ndcli show ip 10.0.5.66 layer3domain b
created:2022-02-01 09:14:46
delegation:10.0.5.64/30
ip:10.0.5.66
layer3domain:b
mask:255.255.255.0
modified:2022-02-01 09:14:46
modified_by:admin
pool:a
ptr_target:b.t.
reverse_zone:5.0.10.in-addr.arpa
status:Static
subnet:10.0.5.0/24
$ ndcli history pool a
timestamp                  user  tool   originating_ip objclass name action
2022-02-01 09:17:52.468475 admin native 127.0.0.1      ippool   a    set_attr layer3domain=b
2022-02-01 09:17:50.944328 admin native 127.0.0.1      ippool   a    create static 10.0.5.66
2022-02-01 09:17:50.823374 admin native 127.0.0.1      ippool   a    create delegation 10.0.5.64/30
2022-02-01 09:17:50.642992 admin native 127.0.0.1      ippool   a    create static 10.0.5.5
2022-02-01 09:17:50.529698 admin native 127.0.0.1      ippool   a    create subnet 10.23.0.0/28
2022-02-01 09:17:50.387248 admin native 127.0.0.1      ippool   a    create subnet 10.0.5.0/24
2022-02-01 09:17:50.356266 admin native 127.0.0.1      ippool   a    set_attr version=4
2022-02-01 09:17:50.234505 admin native 127.0.0.1      ippool   a    created in layer3domain a
$ ndcli history ipblock 10.0.5.66
timestamp                  user  tool   originating_ip objclass name      action
2022-02-01 09:17:52.530755 admin native 127.0.0.1      ipblock  10.0.5.66 set_attr layer3domain=b in layer3domain b
2022-02-01 09:17:50.939473 admin native 127.0.0.1      ipblock  10.0.5.66 created in layer3domain a
$ ndcli history ipblock 10.0.5.5
timestamp                  user  tool   originating_ip objclass name     action
2022-02-01 09:17:52.503848 admin native 127.0.0.1      ipblock  10.0.5.5 set_attr layer3domain=b in layer3domain b
2022-02-01 09:17:50.638336 admin native 127.0.0.1      ipblock  10.0.5.5 created in layer3domain a
$ ndcli history ipblock 10.0.5.64/30
timestamp                  user  tool   originating_ip objclass name         action
2022-02-01 09:17:52.529946 admin native 127.0.0.1      ipblock  10.0.5.64/30 set_attr layer3domain=b in layer3domain b
2022-02-01 09:17:50.817764 admin native 127.0.0.1      ipblock  10.0.5.64/30 created in layer3domain a
$ ndcli list zone 5.0.10.in-addr.arpa
record zone                ttl   type value
     @ 5.0.10.in-addr.arpa 86400 SOA  localhost. hostmaster.5.0.10.in-addr.arpa. 2022020103 14400 3600 605000 86400
     5 5.0.10.in-addr.arpa       PTR  a.t.
    66 5.0.10.in-addr.arpa       PTR  b.t.
$ ndcli history ipblock 10.0.5.0/24
timestamp                  user  tool   originating_ip objclass name        action
2022-02-01 09:25:47.801393 admin native 127.0.0.1      ipblock  10.0.5.0/24 set_attr layer3domain=b in layer3domain b
2022-02-01 09:25:47.787609 admin native 127.0.0.1      ipblock  10.0.5.0/24 set_attr layer3domain=a in layer3domain a
2022-02-01 09:25:47.729919 admin native 127.0.0.1      ipblock  10.0.5.0/24 set_attr layer3domain=b in layer3domain b
2022-02-01 09:25:46.550123 admin native 127.0.0.1      ipblock  10.0.5.0/24 deleted in layer3domain b
2022-02-01 09:25:46.324948 admin native 127.0.0.1      ipblock  10.0.5.0/24 created in layer3domain b
2022-02-01 09:25:45.611436 admin native 127.0.0.1      ipblock  10.0.5.0/24 set_attr pool=a in layer3domain a
2022-02-01 09:25:45.596906 admin native 127.0.0.1      ipblock  10.0.5.0/24 created in layer3domain a
