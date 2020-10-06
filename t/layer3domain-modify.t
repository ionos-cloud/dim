$ ndcli create layer3domain low type vrf rd 0:0
$ ndcli create layer3domain min type vrf rd 0:0
ERROR - Layer3domain with type vrf rd 0:0 already exists

$ ndcli modify layer3domain low set rd 0:1
$ ndcli create layer3domain min type vrf rd 0:0
$ ndcli list layer3domains
type name    properties comment
vrf  default rd:8560:1  
vrf  low     rd:0:1     
vrf  min     rd:0:0     

$ ndcli delete layer3domain min
$ ndcli modify layer3domain low set rd 0:0
$ ndcli list layer3domains
type name    properties comment
vrf  default rd:8560:1  
vrf  low     rd:0:0     
