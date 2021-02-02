# ipblock reverse_dns_profile with layer3domain
$ ndcli create zone-profile internal primary ns.example.com. mail dnsadmin@example.com
$ ndcli modify zone-profile internal create rr @ NS ns.example.com.
INFO - Creating RR @ NS ns.example.com. in zone profile internal
WARNING - ns.example.com. does not exist.
$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify container 10.0.0.0/8 set attrs reverse_dns_profile:internal
$ ndcli create pool p
$ ndcli modify pool p add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
INFO - Creating zone 0.0.10.in-addr.arpa with profile internal

$ ndcli create zone-profile external primary ext.example.com. mail dnsadmin@example.com
$ ndcli modify zone-profile external create rr @ NS ext.example.com.
INFO - Creating RR @ NS ext.example.com. in zone profile external
WARNING - ext.example.com. does not exist.
$ ndcli create layer3domain one type vrf rd 0:2
$ ndcli create container 10.0.0.0/8 layer3domain one
INFO - Creating container 10.0.0.0/8 in layer3domain one
$ ndcli modify container 10.0.0.0/8 layer3domain one set attrs reverse_dns_profile:external

$ ndcli create pool p2 layer3domain one
$ ndcli modify pool p2 add subnet 10.0.0.0/24 --allow-overlap
INFO - Created subnet 10.0.0.0/24 in layer3domain one
WARNING - 10.0.0.0/24 in layer3domain one overlaps with 10.0.0.0/24 in layer3domain default
INFO - Creating view one in zone 0.0.10.in-addr.arpa with profile external

$ ndcli list zone 0.0.10.in-addr.arpa
ERROR - A view must be selected from: default one

$ ndcli list zone 0.0.10.in-addr.arpa view default
record zone                ttl   type value
     @ 0.0.10.in-addr.arpa 86400 SOA  ns.example.com. dnsadmin.example.com. 2017080701 14400 3600 605000 86400
     @ 0.0.10.in-addr.arpa       NS   ns.example.com.

$ ndcli list zone 0.0.10.in-addr.arpa view one
record zone                ttl   type value
     @ 0.0.10.in-addr.arpa 86400 SOA  ext.example.com. dnsadmin.example.com. 2017080701 14400 3600 605000 86400
     @ 0.0.10.in-addr.arpa       NS   ext.example.com.
