
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


