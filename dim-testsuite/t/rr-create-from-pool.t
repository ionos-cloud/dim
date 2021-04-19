$ ndcli create zone-profile internal-rev-dns primary ins01.internal.zone. mail dnsadmin@company.com
$ ndcli modify zone-profile internal-rev-dns create rr @ NS ins01.internal.zone.
INFO - Creating RR @ NS ins01.internal.zone. in zone profile internal-rev-dns
WARNING - ins01.internal.zone. does not exist.
$ ndcli modify zone-profile internal-rev-dns create rr @ NS ins02.internal.zone.
WARNING - The name internal-rev-dns. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.zone. in zone profile internal-rev-dns
WARNING - ins02.internal.zone. does not exist.
$ ndcli create zone-profile public-rev-dns primary rns.example.de. mail dnsadmin@company.com
$ ndcli modify zone-profile public-rev-dns create rr @ NS rns.example.biz.
INFO - Creating RR @ NS rns.example.biz. in zone profile public-rev-dns
WARNING - rns.example.biz. does not exist.
$ ndcli modify zone-profile public-rev-dns create rr @ NS rns.example.com.
WARNING - The name public-rev-dns. already existed, creating round robin record
INFO - Creating RR @ NS rns.example.com. in zone profile public-rev-dns
WARNING - rns.example.com. does not exist.
$ ndcli modify zone-profile public-rev-dns create rr @ NS rns.example.de.
WARNING - The name public-rev-dns. already existed, creating round robin record
INFO - Creating RR @ NS rns.example.de. in zone profile public-rev-dns
WARNING - rns.example.de. does not exist.
$ ndcli modify zone-profile public-rev-dns create rr @ NS rns.example.org.
WARNING - The name public-rev-dns. already existed, creating round robin record
INFO - Creating RR @ NS rns.example.org. in zone profile public-rev-dns
WARNING - rns.example.org. does not exist.
$ ndcli create zone-profile internal primary ins01.internal.zone. mail dnsadmin@company.com
$ ndcli modify zone-profile internal create rr @ NS ins01.internal.zone.
INFO - Creating RR @ NS ins01.internal.zone. in zone profile internal
WARNING - ins01.internal.zone. does not exist.
$ ndcli modify zone-profile internal create rr @ NS ins02.internal.zone.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.zone. in zone profile internal
WARNING - ins02.internal.zone. does not exist.
$ ndcli create container 172.16.0.0/12
INFO - Creating container 172.16.0.0/12 in layer3domain default
$ ndcli modify container 172.16.0.0/12 set attrs reverse_dns_profile:internal-rev-dns
$ ndcli create container 217.160.0.0/16
INFO - Creating container 217.160.0.0/16 in layer3domain default
$ ndcli modify container 217.160.0.0/16 set attrs reverse_dns_profile:public-rev-dns
$ ndcli create container 2001:db8::/32
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli modify container 2001:db8::/32 set attrs reverse_dns_profile:public-rev-dns
$ ndcli create pool dlan vlan 2
$ ndcli modify pool dlan add subnet 172.20.0.0/21 gw 172.20.0.10
INFO - Created subnet 172.20.0.0/21 in layer3domain default
INFO - Creating zone 0.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 1.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 2.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 3.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 4.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 5.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 6.20.172.in-addr.arpa with profile internal-rev-dns
INFO - Creating zone 7.20.172.in-addr.arpa with profile internal-rev-dns
$ ndcli modify pool dlan add subnet 172.20.8.0/24 gw 172.20.8.1
INFO - Created subnet 172.20.8.0/24 in layer3domain default
INFO - Creating zone 8.20.172.in-addr.arpa with profile internal-rev-dns
$ ndcli list zone 0.20.172.in-addr.arpa
record zone                  ttl   type value
@      0.20.172.in-addr.arpa 86400 SOA  ins01.internal.zone. dnsadmin.company.com. 2012102603 14400 3600 605000 86400
@      0.20.172.in-addr.arpa       NS   ins01.internal.zone.
@      0.20.172.in-addr.arpa       NS   ins02.internal.zone.
$ ndcli create pool dns-public-any
$ ndcli modify pool dns-public-any add subnet 217.160.80.0/22
INFO - Created subnet 217.160.80.0/22 in layer3domain default
INFO - Creating zone 80.160.217.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 81.160.217.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 82.160.217.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 83.160.217.in-addr.arpa with profile public-rev-dns
$ ndcli create pool dns-public-any-v6
$ ndcli modify pool dns-public-any-v6 add subnet 2001:db8:fe:53::/64 --no-default-reserve
INFO - Created subnet 2001:db8:fe:53::/64 in layer3domain default
INFO - Creating zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa with profile public-rev-dns
$ ndcli create zone internal.zone profile internal
INFO - Creating zone internal.zone with profile internal
$ ndcli create zone example.de profile public-rev-dns
INFO - Creating zone example.de with profile public-rev-dns
$ ndcli create rr gw-v2.bs.kae.de.example.com. a 172.20.0.10
INFO - Marked IP 172.20.0.10 from layer3domain default as static
INFO - No zone found for gw-v2.bs.kae.de.example.com.
INFO - Creating RR 10 PTR gw-v2.bs.kae.de.example.com. in zone 0.20.172.in-addr.arpa
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr s1.internal.zone. from dlan
INFO - Marked IP 172.20.0.1 from layer3domain default as static
INFO - Creating RR s1 A 172.20.0.1 in zone internal.zone
INFO - Creating RR 1 PTR s1.internal.zone. in zone 0.20.172.in-addr.arpa
created:2012-11-14 09:06:24
gateway:172.20.0.10
ip:172.20.0.1
layer3domain:default
mask:255.255.248.0
modified:2012-11-14 09:06:24
modified_by:user
pool:dlan
ptr_target:s1.internal.zone.
reverse_zone:0.20.172.in-addr.arpa
status:Static
subnet:172.20.0.0/21

# it should be possible to use vlan numbers instead of pool names
$ ndcli create rr s2.internal.zone. from 2
INFO - Marked IP 172.20.0.2 from layer3domain default as static
INFO - Creating RR s2 A 172.20.0.2 in zone internal.zone
INFO - Creating RR 2 PTR s2.internal.zone. in zone 0.20.172.in-addr.arpa
created:2012-11-14 09:06:24
gateway:172.20.0.10
ip:172.20.0.2
layer3domain:default
mask:255.255.248.0
modified:2012-11-14 09:06:24
modified_by:user
pool:dlan
ptr_target:s2.internal.zone.
reverse_zone:0.20.172.in-addr.arpa
status:Static
subnet:172.20.0.0/21

$ ndcli list zone 0.20.172.in-addr.arpa
record zone                  ttl   type value
@      0.20.172.in-addr.arpa 86400 SOA  ins01.internal.zone. dnsadmin.company.com. 2012102603 14400 3600 605000 86400
@      0.20.172.in-addr.arpa       NS   ins01.internal.zone.
@      0.20.172.in-addr.arpa       NS   ins02.internal.zone.
1      0.20.172.in-addr.arpa       PTR  s1.internal.zone.
2      0.20.172.in-addr.arpa       PTR  s2.internal.zone.
10     0.20.172.in-addr.arpa       PTR  gw-v2.bs.kae.de.example.com.
$ ndcli create rr gw-v573.bs.kae.de.example.com. aaaa 2001:db8:fe:53::
INFO - Marked IP 2001:db8:fe:53:: from layer3domain default as static
INFO - No zone found for gw-v573.bs.kae.de.example.com.
INFO - Creating RR 0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR gw-v573.bs.kae.de.example.com. in zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr gw-v573-1.bs.kae.de.example.com. aaaa 2001:db8:fe:53::1
INFO - Marked IP 2001:db8:fe:53::1 from layer3domain default as static
INFO - No zone found for gw-v573-1.bs.kae.de.example.com.
INFO - Creating RR 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR gw-v573-1.bs.kae.de.example.com. in zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr gw-v573-2.bs.kae.de.example.com. aaaa 2001:db8:fe:53::2
INFO - Marked IP 2001:db8:fe:53::2 from layer3domain default as static
INFO - No zone found for gw-v573-2.bs.kae.de.example.com.
INFO - Creating RR 2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR gw-v573-2.bs.kae.de.example.com. in zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr s1.example.de. from dns-public-any-v6
INFO - Marked IP 2001:db8:fe:53::3 from layer3domain default as static
INFO - Creating RR s1 AAAA 2001:db8:fe:53::3 in zone example.de
INFO - Creating RR 3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR s1.example.de. in zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
created:2012-11-14 08:50:13
ip:2001:db8:fe:53::3
layer3domain:default
modified:2012-11-14 08:50:13
modified_by:user
pool:dns-public-any-v6
prefixlength:64
ptr_target:s1.example.de.
reverse_zone:3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
status:Static
subnet:2001:db8:fe:53::/64
$ ndcli create rr s1.example.de. ttl 6000 from dns-public-any
INFO - Marked IP 217.160.80.1 from layer3domain default as static
INFO - Creating RR s1 6000 A 217.160.80.1 in zone example.de
INFO - Creating RR 1 6000 PTR s1.example.de. in zone 80.160.217.in-addr.arpa
created:2012-11-14 11:03:02
ip:217.160.80.1
layer3domain:default
mask:255.255.252.0
modified:2012-11-14 11:03:02
modified_by:user
pool:dns-public-any
ptr_target:s1.example.de.
reverse_zone:80.160.217.in-addr.arpa
status:Static
subnet:217.160.80.0/22

$ ndcli list zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
record                          zone                                     ttl   type value
@                               3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa 86400 SOA  rns.example.de. dnsadmin.company.com. 2012102603 14400 3600 605000 86400
@                               3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       NS   rns.example.biz.
@                               3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       NS   rns.example.com.
@                               3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       NS   rns.example.de.
@                               3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       NS   rns.example.org.
0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       PTR  gw-v573.bs.kae.de.example.com.
1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       PTR  gw-v573-1.bs.kae.de.example.com.
2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       PTR  gw-v573-2.bs.kae.de.example.com.
3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa       PTR  s1.example.de.
$ ndcli list zone 80.160.217.in-addr.arpa
record zone                    ttl   type value
@      80.160.217.in-addr.arpa 86400 SOA  rns.example.de. dnsadmin.company.com. 2012102603 14400 3600 605000 86400
@      80.160.217.in-addr.arpa       NS   rns.example.biz.
@      80.160.217.in-addr.arpa       NS   rns.example.com.
@      80.160.217.in-addr.arpa       NS   rns.example.de.
@      80.160.217.in-addr.arpa       NS   rns.example.org.
1      80.160.217.in-addr.arpa 6000  PTR  s1.example.de.
$ ndcli list zone example.de
record zone      ttl   type value
@      example.de 86400 SOA  rns.example.de. dnsadmin.company.com. 2012102603 14400 3600 605000 86400
@      example.de       NS   rns.example.biz.
@      example.de       NS   rns.example.com.
@      example.de       NS   rns.example.de.
@      example.de       NS   rns.example.org.
s1     example.de       AAAA 2001:db8:fe:53::3
s1     example.de 6000  A    217.160.80.1
$ ndcli delete zone 0.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 0.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 0.20.172.in-addr.arpa
INFO - Deleting RR s1 A 172.20.0.1 from zone internal.zone
INFO - Deleting RR 1 PTR s1.internal.zone. from zone 0.20.172.in-addr.arpa
INFO - Freeing IP 172.20.0.1 from layer3domain default
INFO - Deleting RR s2 A 172.20.0.2 from zone internal.zone
INFO - Deleting RR 2 PTR s2.internal.zone. from zone 0.20.172.in-addr.arpa
INFO - Freeing IP 172.20.0.2 from layer3domain default
INFO - Deleting RR 10 PTR gw-v2.bs.kae.de.example.com. from zone 0.20.172.in-addr.arpa
INFO - Freeing IP 172.20.0.10 from layer3domain default
$ ndcli delete zone 1.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 1.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 1.20.172.in-addr.arpa
$ ndcli delete zone 2.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 2.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 2.20.172.in-addr.arpa
$ ndcli delete zone 3.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 3.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 3.20.172.in-addr.arpa
$ ndcli delete zone 4.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 4.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 4.20.172.in-addr.arpa
$ ndcli delete zone 5.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 5.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 5.20.172.in-addr.arpa
$ ndcli delete zone 6.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 6.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 6.20.172.in-addr.arpa
$ ndcli delete zone 7.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 7.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 7.20.172.in-addr.arpa
$ ndcli delete zone 8.20.172.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 8.20.172.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 8.20.172.in-addr.arpa
$ ndcli delete zone 80.160.217.in-addr.arpa --cleanup
INFO - Deleting RR @ NS rns.example.biz. from zone 80.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.com. from zone 80.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.de. from zone 80.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.org. from zone 80.160.217.in-addr.arpa
INFO - Deleting RR s1 6000 A 217.160.80.1 from zone example.de
INFO - Deleting RR 1 6000 PTR s1.example.de. from zone 80.160.217.in-addr.arpa
INFO - Freeing IP 217.160.80.1 from layer3domain default
$ ndcli delete zone 81.160.217.in-addr.arpa --cleanup
INFO - Deleting RR @ NS rns.example.biz. from zone 81.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.com. from zone 81.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.de. from zone 81.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.org. from zone 81.160.217.in-addr.arpa
$ ndcli delete zone 82.160.217.in-addr.arpa --cleanup
INFO - Deleting RR @ NS rns.example.biz. from zone 82.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.com. from zone 82.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.de. from zone 82.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.org. from zone 82.160.217.in-addr.arpa
$ ndcli delete zone 83.160.217.in-addr.arpa --cleanup
INFO - Deleting RR @ NS rns.example.biz. from zone 83.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.com. from zone 83.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.de. from zone 83.160.217.in-addr.arpa
INFO - Deleting RR @ NS rns.example.org. from zone 83.160.217.in-addr.arpa
$ ndcli delete zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa --cleanup
INFO - Deleting RR @ NS rns.example.biz. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ NS rns.example.com. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ NS rns.example.de. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ NS rns.example.org. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR 0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR gw-v573.bs.kae.de.example.com. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:fe:53:: from layer3domain default
INFO - Deleting RR 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR gw-v573-1.bs.kae.de.example.com. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:fe:53::1 from layer3domain default
INFO - Deleting RR 2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR gw-v573-2.bs.kae.de.example.com. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:fe:53::2 from layer3domain default
INFO - Deleting RR s1 AAAA 2001:db8:fe:53::3 from zone example.de
INFO - Deleting RR 3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 PTR s1.example.de. from zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:fe:53::3 from layer3domain default
$ ndcli delete zone internal.zone --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone internal.zone
INFO - Deleting RR @ NS ins02.internal.zone. from zone internal.zone
$ ndcli delete zone example.de --cleanup
INFO - Deleting RR @ NS rns.example.biz. from zone example.de
INFO - Deleting RR @ NS rns.example.com. from zone example.de
INFO - Deleting RR @ NS rns.example.de. from zone example.de
INFO - Deleting RR @ NS rns.example.org. from zone example.de
$ ndcli delete zone-profile internal
$ ndcli delete zone-profile internal-rev-dns
$ ndcli delete zone-profile public-rev-dns
