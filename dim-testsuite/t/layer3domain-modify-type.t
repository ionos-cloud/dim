$ ndcli create layer3domain test type vrf rd 0:0
$ ndcli modify layer3domain test set type test
$ ndcli list layer3domains
type  name    properties comment
vrf   default rd:8560:1  
test  test
$ ndcli modify layer3domain test set type vrf rd 256:256
$ ndcli delete layer3domain test
