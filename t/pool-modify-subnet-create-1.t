# Testing messages about reverse zone creation when adding subnets to pools
$ ndcli create zone-profile public-rev-dns primary rns.example.com. mail dnsadmin@example.com
$ ndcli modify zone-profile public-rev-dns create rr @ ns rns.example.com.
INFO - Creating RR @ NS rns.example.com. in zone profile public-rev-dns
WARNING - rns.example.com. does not exist.

$ ndcli create zone-profile internal-rev-dns primary ins01.internal.com. mail dnsadmin@example.com
$ ndcli modify zone-profile internal-rev-dns create rr @ ns ins01.internal.com.
INFO - Creating RR @ NS ins01.internal.com. in zone profile internal-rev-dns
WARNING - ins01.internal.com. does not exist.

$ ndcli create container 2001:db8::/32 rir:ripe reverse_dns_profile:public-rev-dns
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli create container 172.16.0.0/12 source:rfc1918 reverse_dns_profile:internal-rev-dns
INFO - Creating container 172.16.0.0/12 in layer3domain default
$ ndcli create container 10.0.0.0/8 source:rfc1918
INFO - Creating container 10.0.0.0/8 in layer3domain default

$ ndcli create pool tp_v6 vlan 12
$ ndcli modify pool tp_v6 add subnet 2001:db8:be:ef::/64 gw 2001:db8:be:ef::1
INFO - Created subnet 2001:db8:be:ef::/64 in layer3domain default
INFO - Creating zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa with profile public-rev-dns

$ ndcli list zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
record zone                                     ttl   type value
@      f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa 86400 SOA  rns.example.com. dnsadmin.example.com. 2012121301 14400 3600 605000 86400
@      f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa       NS   rns.example.com.

$ ndcli create pool tp vlan 12
$ ndcli modify pool tp add subnet 172.16.0.64/29 gw 172.16.0.65
INFO - Created subnet 172.16.0.64/29 in layer3domain default
INFO - Creating zone 0.16.172.in-addr.arpa with profile internal-rev-dns

$ ndcli list zone 0.16.172.in-addr.arpa
record zone                  ttl   type value
@      0.16.172.in-addr.arpa 86400 SOA  ins01.internal.com. dnsadmin.example.com. 2012121301 14400 3600 605000 86400
@      0.16.172.in-addr.arpa       NS   ins01.internal.com.

$ ndcli modify pool tp add subnet 172.18.0.0/23 gw 172.18.0.1
INFO - Created subnet 172.18.0.0/23 in layer3domain default
INFO - Creating zone 0.18.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 1.18.172.in-addr.arpa with profile internal-rev-dns

$ ndcli list zone 1.18.172.in-addr.arpa
record zone                  ttl   type value
@      1.18.172.in-addr.arpa 86400 SOA  ins01.internal.com. dnsadmin.example.com. 2012121301 14400 3600 605000 86400
@      1.18.172.in-addr.arpa       NS   ins01.internal.com.

$ ndcli modify pool tp add subnet 10.0.0.32/27 gw 10.0.0.33
INFO - Created subnet 10.0.0.32/27 in layer3domain default
WARNING - Creating zone 0.0.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify pool tp_v6 remove subnet 2001:db8:be:ef::/64
INFO - Deleting RR @ NS rns.example.com. from zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli delete pool tp_v6

$ ndcli modify pool tp remove subnet 172.16.0.64/29
INFO - Deleting RR @ NS ins01.internal.com. from zone 0.16.172.in-addr.arpa
INFO - Deleting zone 0.16.172.in-addr.arpa
$ ndcli modify pool tp remove subnet 172.18.0.0/23
INFO - Deleting RR @ NS ins01.internal.com. from zone 0.18.172.in-addr.arpa
INFO - Deleting zone 0.18.172.in-addr.arpa
INFO - Deleting RR @ NS ins01.internal.com. from zone 1.18.172.in-addr.arpa
INFO - Deleting zone 1.18.172.in-addr.arpa
$ ndcli modify pool tp remove subnet 10.0.0.32/27
INFO - Deleting zone 0.0.10.in-addr.arpa
$ ndcli delete pool tp

$ ndcli delete container 2001:db8::/32
INFO - Deleting container 2001:db8::/32 from layer3domain default
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
$ ndcli delete container 172.16.0.0/12
INFO - Deleting container 172.16.0.0/12 from layer3domain default
