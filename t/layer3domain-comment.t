$ ndcli create layer3domain min type vrf rd 0:0 comment "a comment"
$ ndcli list layer3domains
type name    properties comment
vrf  default rd:8560:1
vrf  min     rd:0:0     a comment

$ ndcli show layer3domain min
comment:a comment
created:2019-01-04 18:03:54
created_by:admin
modified:2019-01-04 18:03:54
modified_by:admin
rd:0:0

$ ndcli modify layer3domain min set comment "another comment"
$ ndcli list layer3domains
type name    properties comment
vrf  default rd:8560:1
vrf  min     rd:0:0     another comment

$ ndcli show layer3domain min
comment:another comment
created:2019-01-04 18:03:54
created_by:admin
modified:2019-01-04 18:03:54
modified_by:admin
rd:0:0
