$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone a.de create view two
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create pool p
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create pool p2 layer3domain two
$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain two
WARNING - 10.0.0.0/24 in layer3domain two overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view two in zone 0.0.10.in-addr.arpa without profile
$ ndcli create rr a.de. a 10.0.0.1 view default layer3domain two
INFO - Marked IP 10.0.0.1 from layer3domain two as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de view default
INFO - Creating RR 1 PTR a.de. in zone 0.0.10.in-addr.arpa view two

$ ndcli list layer3domains
type name    properties comment
vrf  default rd:8560:1  
vrf  two     rd:0:2     
$ ndcli list zone 0.0.10.in-addr.arpa views
name
default
two

$ ndcli rename layer3domain two to three
$ ndcli list layer3domains
type name    properties comment
vrf  default rd:8560:1  
vrf  three   rd:0:2     
$ ndcli list zone 0.0.10.in-addr.arpa views
name
default
three
$ ndcli list zone a.de views
name
default
two

$ ndcli modify zone 0.0.10.in-addr.arpa rename view three to four
$ ndcli list zone 0.0.10.in-addr.arpa view four
record zone                ttl   type value
     @ 0.0.10.in-addr.arpa 86400 SOA  localhost. hostmaster.0.0.10.in-addr.arpa. 2017101702 14400 3600 605000 86400
     1 0.0.10.in-addr.arpa       PTR  a.de.
