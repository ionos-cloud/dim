$ ndcli create container 217.160.0.0/16 rir:ripe
INFO - Creating container 217.160.0.0/16 in layer3domain default
$ ndcli create pool brand-public-bs-v1213 vlan 1213
$ ndcli modify pool brand-public-bs-v1213 add subnet 217.160.12.16/28 gw 217.160.12.17
INFO - Created subnet 217.160.12.16/28 in layer3domain default
WARNING - Creating zone 12.160.217.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone network.test
WARNING - Creating zone network.test without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr gw-v1213.bs.kae.de.network.test. a 217.160.12.17
INFO - Marked IP 217.160.12.17 from layer3domain default as static
INFO - Creating RR gw-v1213.bs.kae.de A 217.160.12.17 in zone network.test
INFO - Creating RR 17 PTR gw-v1213.bs.kae.de.network.test. in zone 12.160.217.in-addr.arpa
$ ndcli create zone-profile brand-public primary ns-brand.company.com. mail dnsadmin@example.com
$ ndcli modify zone-profile brand-public create rr @ ns ns-brand.company.com.
INFO - Creating RR @ NS ns-brand.company.com. in zone profile brand-public
WARNING - ns-brand.company.com. does not exist.
$ ndcli create zone brand.com profile brand-public
INFO - Creating zone brand.com with profile brand-public
$ ndcli modify zone brand.com create view us profile brand-public
$ ndcli modify zone brand.com rename view default to eu
$ ndcli create rr www.brand.com. a 217.160.12.18 view eu
INFO - Marked IP 217.160.12.18 from layer3domain default as static
INFO - Creating RR www A 217.160.12.18 in zone brand.com view eu
INFO - Creating RR 18 PTR www.brand.com. in zone 12.160.217.in-addr.arpa

# in reality, the ip addresses will be more different than in this
# example but it can happen that they have the same reverse Zone
$ ndcli create rr www.brand.com. a 217.160.12.19 view us
INFO - Marked IP 217.160.12.19 from layer3domain default as static
INFO - Creating RR www A 217.160.12.19 in zone brand.com view us
INFO - Creating RR 19 PTR www.brand.com. in zone 12.160.217.in-addr.arpa

$ ndcli list rrs *brand.com*
record zone                    view    ttl   type value
@      brand.com                 eu            NS   ns-brand.company.com.
@      brand.com                 eu      86400 SOA  ns-brand.company.com. dnsadmin.example.com. 2012121002 14400 3600 605000 86400
www    brand.com                 eu            A    217.160.12.18
@      brand.com                 us      86400 SOA  ns-brand.company.com. dnsadmin.example.com. 2012121002 14400 3600 605000 86400
@      brand.com                 us            NS   ns-brand.company.com.
www    brand.com                 us            A    217.160.12.19
18     12.160.217.in-addr.arpa default       PTR  www.brand.com.
19     12.160.217.in-addr.arpa default       PTR  www.brand.com.
INFO - Result for list rrs *brand.com*

$ ndcli modify zone brand.com delete view eu --cleanup
INFO - Deleting RR @ NS ns-brand.company.com. from zone brand.com view eu
INFO - Deleting RR www A 217.160.12.18 from zone brand.com view eu
INFO - Deleting RR 18 PTR www.brand.com. from zone 12.160.217.in-addr.arpa
INFO - Freeing IP 217.160.12.18 from layer3domain default
$ ndcli delete zone brand.com --cleanup
INFO - Deleting RR @ NS ns-brand.company.com. from zone brand.com
INFO - Deleting RR www A 217.160.12.19 from zone brand.com
INFO - Deleting RR 19 PTR www.brand.com. from zone 12.160.217.in-addr.arpa
INFO - Freeing IP 217.160.12.19 from layer3domain default
$ ndcli delete zone-profile brand-public
$ ndcli delete zone network.test --cleanup
INFO - Deleting RR 17 PTR gw-v1213.bs.kae.de.network.test. from zone 12.160.217.in-addr.arpa
INFO - Deleting RR gw-v1213.bs.kae.de A 217.160.12.17 from zone network.test
INFO - Freeing IP 217.160.12.17 from layer3domain default
$ ndcli modify pool brand-public-bs-v1213 remove subnet 217.160.12.16/28
INFO - Deleting zone 12.160.217.in-addr.arpa
$ ndcli delete pool brand-public-bs-v1213
$ ndcli delete container 217.160.0.0/16
INFO - Deleting container 217.160.0.0/16 from layer3domain default
