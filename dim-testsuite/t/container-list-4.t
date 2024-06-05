
$ ndcli list containers
$ ndcli list containers 0.0.0.0/0
ERROR - No containers matching '0.0.0.0/0' exist in layer3domain default
$ ndcli list containers layer3domain default 0.0.0.0/0
$ ndcli list containers layer3domain 6724-global 0.0.0.0/0

$ ndcli list containers ::/0
ERROR - No containers matching '::/0' exist in layer3domain default

$ ndcli create container 10.0.0.0/8 
INFO - Creating container 10.0.0.0/8 in layer3domain default

$ ndcli list containers 0.0.0.0/0
WARNING - 0.0.0.0/0 rounded to 10.0.0.0/8 because no ipblock exists at 0.0.0.0/0 with status Container
layer3domain: default
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)

$ ndcli create container 2001:db8::/32
INFO - Creating container 2001:db8::/32 in layer3domain default

$ ndcli list containers ::/0
WARNING - ::/0 rounded to 2001:db8::/32 because no ipblock exists at ::/0 with status Container
layer3domain: default
2001:db8::/32 (Container)
  2001:db8::/32 (Available)

$ ndcli create layer3domain test type vrf rd 256:256
type name    properties comment
vrf  default rd:8560:1  
vrf  test    rd:256:256

$ ndcli list containers layer3domain test 0.0.0.0/0
ERROR - No containers matching '0.0.0.0/0' exist in layer3domain test

$ ndcli create container 10.0.0.0/16 layer3domain test
 INFO - Creating container 10.0.0.0/16 in layer3domain test

$ ndcli create container 2001:db8::/64 layer3domain test
  INFO - Creating container 2001:db8::/64 in layer3domain test

$ ndcli list containers layer3domain test
layer3domain: test
10.0.0.0/16 (Container)
  10.0.0.0/16 (Available)
2001:db8::/64 (Container)
  2001:db8::/64 (Available)

