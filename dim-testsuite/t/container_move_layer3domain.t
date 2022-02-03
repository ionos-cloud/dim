$ ndcli create layer3domain a type test
$ ndcli create layer3domain b type test
$ ndcli create container 10.0.0.0/8 layer3domain a
INFO - Creating container 10.0.0.0/8 in layer3domain a
$ ndcli create container 10.0.0.0/8 layer3domain b
INFO - Creating container 10.0.0.0/8 in layer3domain b
$ ndcli create container 10.0.4.0/22 layer3domain a
INFO - Creating container 10.0.4.0/22 in layer3domain a
$ ndcli create container 10.0.6.0/24 layer3domain a
INFO - Creating container 10.0.6.0/24 in layer3domain a
$ ndcli create pool a layer3domain a
$ ndcli create pool b layer3domain b
$ ndcli modify pool a add subnet 10.0.5.0/24
INFO - Created subnet 10.0.5.0/24 in layer3domain a
WARNING - Creating zone 5.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool b add subnet 10.0.5.0/24 --allow-overlap
INFO - Created subnet 10.0.5.0/24 in layer3domain b
WARNING - 10.0.5.0/24 in layer3domain b overlaps with 10.0.5.0/24 in layer3domain a
INFO - Creating view b in zone 5.0.10.in-addr.arpa without profile
$ ndcli create rr test.t. A 10.0.4.1 layer3domain a
INFO - Marked IP 10.0.4.1 from layer3domain a as static
INFO - No zone found for test.t.
INFO - No zone found for 1.4.0.10.in-addr.arpa.
WARNING - No record was created because no forward or reverse zone found.
$ ndcli create rr test.t. A 10.0.5.1 layer3domain a
INFO - Marked IP 10.0.5.1 from layer3domain a as static
INFO - No zone found for test.t.
INFO - Creating RR 1 PTR test.t. in zone 5.0.10.in-addr.arpa view a
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create container 10.0.4.0/22 layer3domain b
INFO - Creating container 10.0.4.0/22 in layer3domain b
$ ndcli modify container 10.0.4.0/22 layer3domain a move to b
ERROR - container 10.0.4.0/22 already exists in layer3domain b
$ ndcli delete container 10.0.4.0/22 layer3domain b
INFO - Deleting container 10.0.4.0/22 from layer3domain b
$ ndcli list containers layer3domain all
layer3domain: default

layer3domain: a
10.0.0.0/8 (Container)
  10.0.0.0/22 (Available)
  10.0.4.0/22 (Container)
    10.0.4.1 (Static)
    10.0.4.2/31 (Available)
    10.0.4.4/30 (Available)
    10.0.4.8/29 (Available)
    10.0.4.16/28 (Available)
    10.0.4.32/27 (Available)
    10.0.4.64/26 (Available)
    10.0.4.128/25 (Available)
    10.0.5.0/24 (Subnet) pool:a
    10.0.6.0/24 (Container)
      10.0.6.0/24 (Available)
    10.0.7.0/24 (Available)
  10.0.8.0/21 (Available)
  10.0.16.0/20 (Available)
  10.0.32.0/19 (Available)
  10.0.64.0/18 (Available)
  10.0.128.0/17 (Available)
  10.1.0.0/16 (Available)
  10.2.0.0/15 (Available)
  10.4.0.0/14 (Available)
  10.8.0.0/13 (Available)
  10.16.0.0/12 (Available)
  10.32.0.0/11 (Available)
  10.64.0.0/10 (Available)
  10.128.0.0/9 (Available)

layer3domain: b
10.0.0.0/8 (Container)
  10.0.0.0/22 (Available)
  10.0.4.0/24 (Available)
  10.0.5.0/24 (Subnet) pool:b
  10.0.6.0/23 (Available)
  10.0.8.0/21 (Available)
  10.0.16.0/20 (Available)
  10.0.32.0/19 (Available)
  10.0.64.0/18 (Available)
  10.0.128.0/17 (Available)
  10.1.0.0/16 (Available)
  10.2.0.0/15 (Available)
  10.4.0.0/14 (Available)
  10.8.0.0/13 (Available)
  10.16.0.0/12 (Available)
  10.32.0.0/11 (Available)
  10.64.0.0/10 (Available)
  10.128.0.0/9 (Available)
$ ndcli modify container 10.0.4.0/22 layer3domain a move to b
INFO - moving pool 10.0.6.0/24 from parent 10.0.4.0/22 to parent 10.0.0.0/8
INFO - moving pool 10.0.5.0/24 from parent 10.0.4.0/22 to parent 10.0.0.0/8
INFO - moving static ip 10.0.4.1 to layer3domain b
$ ndcli list containers layer3domain all
layer3domain: default

layer3domain: a
10.0.0.0/8 (Container)
  10.0.0.0/22 (Available)
  10.0.4.0/24 (Available)
  10.0.5.0/24 (Subnet) pool:a
  10.0.6.0/24 (Container)
    10.0.6.0/24 (Available)
  10.0.7.0/24 (Available)
  10.0.8.0/21 (Available)
  10.0.16.0/20 (Available)
  10.0.32.0/19 (Available)
  10.0.64.0/18 (Available)
  10.0.128.0/17 (Available)
  10.1.0.0/16 (Available)
  10.2.0.0/15 (Available)
  10.4.0.0/14 (Available)
  10.8.0.0/13 (Available)
  10.16.0.0/12 (Available)
  10.32.0.0/11 (Available)
  10.64.0.0/10 (Available)
  10.128.0.0/9 (Available)

layer3domain: b
10.0.0.0/8 (Container)
  10.0.0.0/22 (Available)
  10.0.4.0/22 (Container)
    10.0.4.1 (Static)
    10.0.4.2/31 (Available)
    10.0.4.4/30 (Available)
    10.0.4.8/29 (Available)
    10.0.4.16/28 (Available)
    10.0.4.32/27 (Available)
    10.0.4.64/26 (Available)
    10.0.4.128/25 (Available)
    10.0.5.0/24 (Subnet) pool:b
    10.0.6.0/23 (Available)
  10.0.8.0/21 (Available)
  10.0.16.0/20 (Available)
  10.0.32.0/19 (Available)
  10.0.64.0/18 (Available)
  10.0.128.0/17 (Available)
  10.1.0.0/16 (Available)
  10.2.0.0/15 (Available)
  10.4.0.0/14 (Available)
  10.8.0.0/13 (Available)
  10.16.0.0/12 (Available)
  10.32.0.0/11 (Available)
  10.64.0.0/10 (Available)
  10.128.0.0/9 (Available)
$ ndcli history ipblock 10.0.4.0/22
timestamp                  user  tool   originating_ip objclass name        action
2022-02-02 13:50:50.289111 admin native 127.0.0.1      ipblock  10.0.4.0/22 set_attr layer3domain=b in layer3domain b
2022-02-02 13:50:50.033176 admin native 127.0.0.1      ipblock  10.0.4.0/22 deleted in layer3domain b
2022-02-02 13:50:49.791900 admin native 127.0.0.1      ipblock  10.0.4.0/22 created in layer3domain b
2022-02-02 13:50:48.725891 admin native 127.0.0.1      ipblock  10.0.4.0/22 created in layer3domain a
$ ndcli history ipblock 10.0.4.1
timestamp                  user  tool   originating_ip objclass name     action
2022-01-18 12:24:18.682816 admin native 127.0.0.1      ipblock  10.0.4.1 set_attr layer3domain=b in layer3domain b
2022-01-18 12:24:18.210161 admin native 127.0.0.1      ipblock  10.0.4.1 created in layer3domain a
