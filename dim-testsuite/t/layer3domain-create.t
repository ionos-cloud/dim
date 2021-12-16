$ ndcli create layer3domain test type vrf rd 1
ERROR - Invalid rd '1'
$ ndcli create layer3domain test type vrf rd 0:a
ERROR - Invalid rd '0:a'
$ ndcli create layer3domain test type vrf rd 65535:65536
ERROR - Invalid rd '65535:65536'
$ ndcli create layer3domain test type vrf rd 65536:65535
ERROR - Invalid rd '65536:65535'
$ ndcli create layer3domain max type vrf rd 65535:65535
$ ndcli create layer3domain min type vrf rd 0:0
$ ndcli list layer3domains
type name    properties     comment
vrf  default rd:8560:1
vrf  max     rd:65535:65535
vrf  min     rd:0:0
$ ndcli delete layer3domain max
$ ndcli create container 192.168.0.0/16 layer3domain min
INFO - Creating container 192.168.0.0/16 in layer3domain min
$ ndcli delete layer3domain min
ERROR - layer3domain min still contains objects
$ ndcli create layer3domain test type vrf rd 256:256
$ ndcli create pool somepool layer3domain test
$ ndcli delete layer3domain test
ERROR - layer3domain test still contains pools
