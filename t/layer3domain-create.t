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
