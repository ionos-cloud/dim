# First create some containers used to demonstrate the desired behaviour.
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create container 192.168.0.0/16
INFO - Creating container 192.168.0.0/16 in layer3domain default
$ ndcli create container 10.30.0.0/16
INFO - Creating container 10.30.0.0/16 in layer3domain default
$ ndcli create container 10.30.2.0/23
INFO - Creating container 10.30.2.0/23 in layer3domain default

# Round down invalid CIDR
$ ndcli list containers 10.30.3.0/23
WARNING - 10.30.3.0/23 rounded to 10.30.2.0/23 because it is not a valid CIDR block
10.30.2.0/23 (Container)
  10.30.2.0/23 (Available)

# Round up invalid CIDR
$ ndcli list containers 192.168.0.0/12
WARNING - 192.168.0.0/12 rounded to 192.160.0.0/12 because it is not a valid CIDR block
WARNING - 192.160.0.0/12 rounded to 192.168.0.0/16 because no ipblock exists at 192.160.0.0/12 with status Container
192.168.0.0/16 (Container)
  192.168.0.0/16 (Available)

# Round down valid CIDR because no container exists at that CIDR
$ ndcli list containers 192.160.0.0/12
WARNING - 192.160.0.0/12 rounded to 192.168.0.0/16 because no ipblock exists at 192.160.0.0/12 with status Container
192.168.0.0/16 (Container)
  192.168.0.0/16 (Available)

# Round up valid CIDR because no container exists at that CIDR
$ ndcli list containers 10.40.0.0/16
WARNING - 10.40.0.0/16 rounded to 10.0.0.0/8 because no ipblock exists at 10.40.0.0/16 with status Container
10.0.0.0/8 (Container)
  10.0.0.0/12 (Available)
  10.16.0.0/13 (Available)
  10.24.0.0/14 (Available)
  10.28.0.0/15 (Available)
  10.30.0.0/16 (Container)
    10.30.0.0/23 (Available)
    10.30.2.0/23 (Container)
      10.30.2.0/23 (Available)
    10.30.4.0/22 (Available)
    10.30.8.0/21 (Available)
    10.30.16.0/20 (Available)
    10.30.32.0/19 (Available)
    10.30.64.0/18 (Available)
    10.30.128.0/17 (Available)
  10.31.0.0/16 (Available)
  10.32.0.0/11 (Available)
  10.64.0.0/10 (Available)
  10.128.0.0/9 (Available)
