$ ndcli create layer3domain one type vrf rd 0:2
$ ndcli create container 1.0.0.0/8 layer3domain one
INFO - Creating container 1.0.0.0/8 in layer3domain one
$ ndcli modify container 1.0.0.0/8 layer3domain one set attrs a:b c:d
$ ndcli show container 1.0.0.0/8 layer3domain one
a:b
c:d
created:2017-08-08 11:52:20
ip:1.0.0.0/8
layer3domain:one
modified:2017-08-08 11:52:20
modified_by:admin
status:Container

$ ndcli modify container 1.0.0.0/8 layer3domain one remove attrs a
$ ndcli show container 1.0.0.0/8 layer3domain one
c:d
created:2017-08-08 11:52:20
ip:1.0.0.0/8
layer3domain:one
modified:2017-08-08 11:52:20
modified_by:admin
status:Container

$ ndcli list containers
ERROR - A layer3domain is needed
$ ndcli list containers layer3domain one
1.0.0.0/8 (Container) c:d
  1.0.0.0/8 (Available)
$ ndcli list containers layer3domain one 1.0.0.0/8
1.0.0.0/8 (Container) c:d
  1.0.0.0/8 (Available)
$ ndcli create layer3domain two type vrf rd 0:3
$ ndcli create container 2.0.0.0/8 layer3domain two
INFO - Creating container 2.0.0.0/8 in layer3domain two
$ ndcli list containers layer3domain all
layer3domain: default

layer3domain: one
1.0.0.0/8 (Container) c:d
  1.0.0.0/8 (Available)

layer3domain: two
2.0.0.0/8 (Container)
  2.0.0.0/8 (Available)
