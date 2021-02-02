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
