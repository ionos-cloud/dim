$ ndcli create layer3domain two type vrf rd 2:2
$ ndcli modify layer3domain two set comment c
$ ndcli modify layer3domain two set rd 22:22
$ ndcli delete layer3domain two
$ ndcli history layer3domain two
timestamp                  user  tool   originating_ip objclass     name action
2019-01-14 14:13:00.712967 admin native 127.0.0.1      layer3domain two  deleted
2019-01-14 14:13:00.699017 admin native 127.0.0.1      layer3domain two  set_attr rd=22:22
2019-01-14 14:13:00.687664 admin native 127.0.0.1      layer3domain two  set_attr comment=c
2019-01-14 14:13:00.678273 admin native 127.0.0.1      layer3domain two  created
2019-01-14 14:13:00.676887 admin native 127.0.0.1      layer3domain two  set_attr rd=2:2

$ ndcli create layer3domain a type a
$ ndcli create layer3domain b type b
$ ndcli create container 10.0.0.0/8 layer3domain a
INFO - Creating container 10.0.0.0/8 in layer3domain a
$ ndcli create container 10.0.0.0/8 layer3domain b
INFO - Creating container 10.0.0.0/8 in layer3domain b
$ ndcli history ipblock 10.0.0.0/8
timestamp                  user  tool   originating_ip objclass name       action
2022-02-03 12:53:08.686055 admin native 127.0.0.1      ipblock  10.0.0.0/8 created in layer3domain b
2022-02-03 12:53:08.546129 admin native 127.0.0.1      ipblock  10.0.0.0/8 created in layer3domain a
$ ndcli history ipblock 10.0.0.0/8 layer3domain a
timestamp                  user  tool   originating_ip objclass name       action
2022-02-03 12:53:08.546129 admin native 127.0.0.1      ipblock  10.0.0.0/8 created in layer3domain a
