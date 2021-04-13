$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool p
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa

$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create pool p2 layer3domain two
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli create rr a.de. a 10.0.0.1 layer3domain two --allow-overlap
INFO - Marked IP 10.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa view two

$ ndcli delete rr a.de. a 10.0.0.1 layer3domain default
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Deleting RR 1 PTR a.de. from zone 0.0.10.in-addr.arpa view default
INFO - Freeing IP 10.0.0.1 from layer3domain default
$ ndcli modify pool p remove subnet 10.0.0.0/24
INFO - Deleting view default from zone 0.0.10.in-addr.arpa
$ ndcli delete pool p

$ ndcli history zone a.de view default
timestamp                  user  tool   originating_ip objclass  name             action
2019-01-15 11:06:07.798042 admin native 127.0.0.1      rr        a.de. A 10.0.0.1 deleted in layer3domain default
2019-01-15 10:41:42.540765 admin native 127.0.0.1      zone-view default          set_attr serial=2019011503
2019-01-15 11:06:07.733048 admin native 127.0.0.1      rr        a.de. A 10.0.0.1 created in layer3domain two
2019-01-15 10:41:42.476578 admin native 127.0.0.1      zone-view default          set_attr serial=2019011502
2019-01-15 11:06:07.592353 admin native 127.0.0.1      rr        a.de. A 10.0.0.1 created in layer3domain default
2019-01-15 11:06:07.591473 admin native 127.0.0.1      zone-view default          set_attr serial=2019011502
2019-01-15 10:41:42.447539 admin native 127.0.0.1      zone-view default          created

$ ndcli history zone a.de
timestamp                  user  tool   originating_ip objclass  name             action
2019-01-15 11:06:07.798042 admin native 127.0.0.1      rr        a.de. A 10.0.0.1 deleted in view default layer3domain default
2019-01-15 10:41:42.540765 admin native 127.0.0.1      zone-view default          set_attr serial=2019011503
2019-01-15 11:06:07.733048 admin native 127.0.0.1      rr        a.de. A 10.0.0.1 created in view default layer3domain two
2019-01-15 10:41:42.476578 admin native 127.0.0.1      zone-view default          set_attr serial=2019011502
2019-01-15 11:06:07.592353 admin native 127.0.0.1      rr        a.de. A 10.0.0.1 created in view default layer3domain default
2019-01-15 11:06:07.591473 admin native 127.0.0.1      zone-view default          set_attr serial=2019011502
2019-01-15 10:41:42.447539 admin native 127.0.0.1      zone-view default          created
2019-01-15 10:41:42.446520 admin native 127.0.0.1      zone      a.de             created

$ ndcli history rr a.de.
timestamp                  user  tool   originating_ip objclass name             action
2019-01-15 11:06:07.798042 admin native 127.0.0.1      rr       a.de. A 10.0.0.1 deleted in zone a.de view default layer3domain default
2019-01-15 11:06:07.733048 admin native 127.0.0.1      rr       a.de. A 10.0.0.1 created in zone a.de view default layer3domain two
2019-01-15 11:06:07.592353 admin native 127.0.0.1      rr       a.de. A 10.0.0.1 created in zone a.de view default layer3domain default

$ ndcli history ipblock 10.0.0.0
timestamp                  user  tool   originating_ip objclass name     action
2019-01-15 10:41:42.547314 admin native 127.0.0.1      ipblock  10.0.0.0 deleted in layer3domain default
2019-01-15 11:06:07.689777 admin native 127.0.0.1      ipblock  10.0.0.0 created in layer3domain two
2019-01-15 10:41:42.463656 admin native 127.0.0.1      ipblock  10.0.0.0 created in layer3domain default

$ ndcli history zone 0.0.10.in-addr.arpa
timestamp                  user  tool   originating_ip objclass  name                             action
2019-01-15 11:06:07.854190 admin native 127.0.0.1      zone-view default                          deleted
2019-01-15 11:06:07.789392 admin native 127.0.0.1      rr        1.0.0.10.in-addr.arpa. PTR a.de. deleted in view default layer3domain default
2019-01-15 11:06:07.788002 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011503
2019-01-15 11:06:07.748152 admin native 127.0.0.1      rr        1.0.0.10.in-addr.arpa. PTR a.de. created in view two layer3domain two
2019-01-15 11:06:07.747264 admin native 127.0.0.1      zone-view two                              set_attr serial=2019011502
2019-01-15 11:06:07.684096 admin native 127.0.0.1      zone-view two                              created
2019-01-15 11:06:07.605762 admin native 127.0.0.1      rr        1.0.0.10.in-addr.arpa. PTR a.de. created in view default layer3domain default
2019-01-15 11:06:07.604746 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011502
2019-01-15 11:06:07.530713 admin native 127.0.0.1      zone-view default                          created
2019-01-15 11:06:07.529646 admin native 127.0.0.1      zone      0.0.10.in-addr.arpa              created

$ ndcli history ipblock 10.0.0.0/24
timestamp                  user  tool   originating_ip objclass name        action
2019-01-15 11:06:07.828124 admin native 127.0.0.1      ipblock  10.0.0.0/24 deleted in layer3domain default
2019-01-15 11:06:07.671812 admin native 127.0.0.1      ipblock  10.0.0.0/24 set_attr pool=p2 in layer3domain two
2019-01-15 11:06:07.659774 admin native 127.0.0.1      ipblock  10.0.0.0/24 created in layer3domain two
2019-01-15 11:06:07.522828 admin native 127.0.0.1      ipblock  10.0.0.0/24 set_attr pool=p in layer3domain default
2019-01-15 11:06:07.509940 admin native 127.0.0.1      ipblock  10.0.0.0/24 created in layer3domain default

$ ndcli history pool p
timestamp                  user  tool   originating_ip objclass name action
2019-01-15 11:06:07.870168 admin native 127.0.0.1      ippool   p    deleted in layer3domain default
2019-01-15 11:06:07.851938 admin native 127.0.0.1      ippool   p    delete subnet 10.0.0.0/24
2019-01-15 11:06:07.582558 admin native 127.0.0.1      ippool   p    create static 10.0.0.1
2019-01-15 11:06:07.551013 admin native 127.0.0.1      ippool   p    create subnet 10.0.0.0/24
2019-01-15 11:06:07.519612 admin native 127.0.0.1      ippool   p    set_attr version=4
2019-01-15 11:06:07.497340 admin native 127.0.0.1      ippool   p    created in layer3domain default

$ ndcli history -L 100
timestamp                  user  tool   originating_ip objclass  name                             action
2019-01-15 11:25:59.382511 admin native 127.0.0.1      ippool    p                                deleted in layer3domain default
2019-01-15 11:25:59.365543 admin native 127.0.0.1      zone-view default                          deleted in zone 0.0.10.in-addr.arpa
2019-01-15 11:25:59.363454 admin native 127.0.0.1      ippool    p                                delete subnet 10.0.0.0/24
2019-01-15 11:25:59.349102 admin native 127.0.0.1      ipblock   10.0.0.255                       deleted in layer3domain default
2019-01-15 11:25:59.343782 admin native 127.0.0.1      ipblock   10.0.0.0                         deleted in layer3domain default
2019-01-15 11:25:59.339031 admin native 127.0.0.1      ipblock   10.0.0.0/24                      deleted in layer3domain default
2019-01-15 11:25:59.315528 admin native 127.0.0.1      ipblock   10.0.0.1                         deleted in layer3domain default
2019-01-15 11:25:59.310364 admin native 127.0.0.1      rr        1.0.0.10.in-addr.arpa. PTR a.de. deleted in zone 0.0.10.in-addr.arpa view default layer3domain default
2019-01-15 11:25:59.309736 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011503 in zone 0.0.10.in-addr.arpa
2019-01-15 11:25:59.303081 admin native 127.0.0.1      rr        a.de. A 10.0.0.1                 deleted in zone a.de view default layer3domain default
2019-01-15 11:25:59.301693 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011504 in zone a.de
2019-01-15 11:25:59.232051 admin native 127.0.0.1      rr        1.0.0.10.in-addr.arpa. PTR a.de. created in zone 0.0.10.in-addr.arpa view two layer3domain two
2019-01-15 11:25:59.231118 admin native 127.0.0.1      zone-view two                              set_attr serial=2019011502 in zone 0.0.10.in-addr.arpa
2019-01-15 11:25:59.217948 admin native 127.0.0.1      rr        a.de. A 10.0.0.1                 created in zone a.de view default layer3domain two
2019-01-15 11:25:59.216840 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011503 in zone a.de
2019-01-15 11:25:59.206766 admin native 127.0.0.1      ippool    p2                               create static 10.0.0.1
2019-01-15 11:25:59.202059 admin native 127.0.0.1      ipblock   10.0.0.1                         created in layer3domain two
2019-01-15 11:25:59.187306 admin native 127.0.0.1      ippool    p2                               create subnet 10.0.0.0/24
2019-01-15 11:25:59.180576 admin native 127.0.0.1      ipblock   10.0.0.255                       created in layer3domain two
2019-01-15 11:25:59.170066 admin native 127.0.0.1      ipblock   10.0.0.0                         created in layer3domain two
2019-01-15 11:25:59.164470 admin native 127.0.0.1      zone-view two                              created in zone 0.0.10.in-addr.arpa
2019-01-15 11:25:59.152544 admin native 127.0.0.1      ipblock   10.0.0.0/24                      set_attr pool=p2 in layer3domain two
2019-01-15 11:25:59.149681 admin native 127.0.0.1      ippool    p2                               set_attr version=4
2019-01-15 11:25:59.140734 admin native 127.0.0.1      ipblock   10.0.0.0/24                      created in layer3domain two
2019-01-15 11:25:59.119303 admin native 127.0.0.1      ipblock   10.0.0.0/8                       created in layer3domain two
2019-01-15 11:25:59.106602 admin native 127.0.0.1      ippool    p2                               created in layer3domain two
2019-01-15 11:25:59.084081 admin native 127.0.0.1      rr        1.0.0.10.in-addr.arpa. PTR a.de. created in zone 0.0.10.in-addr.arpa view default layer3domain default
2019-01-15 11:25:59.083120 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011502 in zone 0.0.10.in-addr.arpa
2019-01-15 11:25:59.070368 admin native 127.0.0.1      rr        a.de. A 10.0.0.1                 created in zone a.de view default layer3domain default
2019-01-15 11:25:59.069431 admin native 127.0.0.1      zone-view default                          set_attr serial=2019011502 in zone a.de
2019-01-15 11:25:59.059338 admin native 127.0.0.1      ippool    p                                create static 10.0.0.1
2019-01-15 11:25:59.055164 admin native 127.0.0.1      ipblock   10.0.0.1                         created in layer3domain default
2019-01-15 11:25:59.037695 admin native 127.0.0.1      zone-view default                          created in zone a.de
2019-01-15 11:25:59.036518 admin native 127.0.0.1      zone      a.de                             created
2019-01-15 11:25:59.026920 admin native 127.0.0.1      ippool    p                                create subnet 10.0.0.0/24
2019-01-15 11:25:59.021219 admin native 127.0.0.1      ipblock   10.0.0.255                       created in layer3domain default
2019-01-15 11:25:59.013011 admin native 127.0.0.1      ipblock   10.0.0.0                         created in layer3domain default
2019-01-15 11:25:59.006646 admin native 127.0.0.1      zone-view default                          created in zone 0.0.10.in-addr.arpa
2019-01-15 11:25:59.005731 admin native 127.0.0.1      zone      0.0.10.in-addr.arpa              created
2019-01-15 11:25:58.999857 admin native 127.0.0.1      ipblock   10.0.0.0/24                      set_attr pool=p in layer3domain default
2019-01-15 11:25:58.996950 admin native 127.0.0.1      ippool    p                                set_attr version=4
2019-01-15 11:25:58.987556 admin native 127.0.0.1      ipblock   10.0.0.0/24                      created in layer3domain default
2019-01-15 11:25:58.974224 admin native 127.0.0.1      ippool    p                                created in layer3domain default
2019-01-15 11:25:58.958105 admin native 127.0.0.1      ipblock   10.0.0.0/8                       created in layer3domain default
2019-01-15 11:25:58.871515 local native                group     all_users                        added user admin
2019-01-15 11:25:58.866830 local native                group     all_users                        created
