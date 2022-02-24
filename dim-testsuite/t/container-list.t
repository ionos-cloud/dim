# no output on no containers
$ ndcli list containers
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli list containers
layer3domain: default
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)

$ ndcli create layer3domain one type vrf rd 0:1
$ ndcli create container 10.0.0.0/8
ERROR - A layer3domain is needed
$ ndcli create container 10.0.0.0/8 layer3domain one
INFO - Creating container 10.0.0.0/8 in layer3domain one
$ ndcli create container 11.0.0.0/8 layer3domain one
INFO - Creating container 11.0.0.0/8 in layer3domain one
$ ndcli list containers
layer3domain: default
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)

layer3domain: one
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)
11.0.0.0/8 (Container)
  11.0.0.0/8 (Available)
$ ndcli list containers layer3domain all
layer3domain: default
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)

layer3domain: one
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)
11.0.0.0/8 (Container)
  11.0.0.0/8 (Available)
$ ndcli list containers layer3domain default
layer3domain: default
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)

$ ndcli list containers layer3domain one
layer3domain: one
10.0.0.0/8 (Container)
  10.0.0.0/8 (Available)
11.0.0.0/8 (Container)
  11.0.0.0/8 (Available)

$ ndcli list containers layer3domain one 11.0.0.0/8
layer3domain: one
11.0.0.0/8 (Container)
  11.0.0.0/8 (Available)

$ ndcli list containers layer3domain all 11.0.0.0/8
layer3domain: one
11.0.0.0/8 (Container)
  11.0.0.0/8 (Available)

$ ndcli create container 192.168.42.0/24 layer3domain default
INFO - Creating container 192.168.42.0/24 in layer3domain default
$ ndcli create container 192.168.42.168/30 layer3domain default
INFO - Creating container 192.168.42.168/30 in layer3domain default
$ ndcli create rr example.com. A 192.168.42.166 layer3domain default
INFO - Marked IP 192.168.42.166 from layer3domain default as static
INFO - No zone found for example.com.
INFO - No zone found for 166.42.168.192.in-addr.arpa.
WARNING - No record was created because no forward or reverse zone found.
$ ndcli create rr example.com. A 192.168.42.173 layer3domain default
INFO - Marked IP 192.168.42.173 from layer3domain default as static
INFO - No zone found for example.com.
INFO - No zone found for 173.42.168.192.in-addr.arpa.
WARNING - No record was created because no forward or reverse zone found.
$ ndcli list containers layer3domain default 192.168.42.0/24
layer3domain: default
192.168.42.0/24 (Container)
  192.168.42.0/25 (Available)
  192.168.42.128/27 (Available)
  192.168.42.160/30 (Available)
  192.168.42.164/31 (Available)
  192.168.42.166 (Static)
  192.168.42.167 (Available)
  192.168.42.168/30 (Container)
    192.168.42.168/30 (Available)
  192.168.42.172 (Available)
  192.168.42.173 (Static)
  192.168.42.174/31 (Available)
  192.168.42.176/28 (Available)
  192.168.42.192/26 (Available)
