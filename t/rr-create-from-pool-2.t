$ ndcli create zone-profile internal-rev-dns primary ins01.internal.com. mail dnsadmin@example.de
$ ndcli modify zone-profile internal-rev-dns create rr @ NS ins01.internal.com.
INFO - Creating RR @ NS ins01.internal.com. in zone profile internal-rev-dns
WARNING - ins01.internal.com. does not exist.
$ ndcli modify zone-profile internal-rev-dns create rr @ NS ins02.internal.com.
WARNING - The name internal-rev-dns. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.com. in zone profile internal-rev-dns
WARNING - ins02.internal.com. does not exist.

$ ndcli create zone-profile public-rev-dns primary rns.example.de. mail dnsadmin@example.de
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

$ ndcli create zone-profile internal primary ins01.internal.com. mail dnsadmin@example.de
$ ndcli modify zone-profile internal create rr @ NS ins01.internal.com.
INFO - Creating RR @ NS ins01.internal.com. in zone profile internal
WARNING - ins01.internal.com. does not exist.
$ ndcli modify zone-profile internal create rr @ NS ins02.internal.com.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.com. in zone profile internal
WARNING - ins02.internal.com. does not exist.

$ ndcli create zone-profile public primary ns.example.de. mail dnsadmin@example.de
$ ndcli modify zone-profile public create rr @ NS ns.example.de.
INFO - Creating RR @ NS ns.example.de. in zone profile public
WARNING - ns.example.de. does not exist.
$ ndcli modify zone-profile public create rr @ NS ns.example.com.
WARNING - The name public. already existed, creating round robin record
INFO - Creating RR @ NS ns.example.com. in zone profile public
WARNING - ns.example.com. does not exist.
$ ndcli modify zone-profile public create rr @ NS ns.example.org.
WARNING - The name public. already existed, creating round robin record
INFO - Creating RR @ NS ns.example.org. in zone profile public
WARNING - ns.example.org. does not exist.
$ ndcli modify zone-profile public create rr @ NS ns.example.biz.
WARNING - The name public. already existed, creating round robin record
INFO - Creating RR @ NS ns.example.biz. in zone profile public
WARNING - ns.example.biz. does not exist.

$ ndcli create container 172.16.0.0/12
INFO - Creating container 172.16.0.0/12 in layer3domain default
$ ndcli modify container 172.16.0.0/12 set attrs reverse_dns_profile:internal-rev-dns
$ ndcli create container 217.160.0.0/16
INFO - Creating container 217.160.0.0/16 in layer3domain default
$ ndcli modify container 217.160.0.0/16 set attrs reverse_dns_profile:public-rev-dns
$ ndcli create container 2001:db8::/32
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli modify container 2001:db8::/32 set attrs reverse_dns_profile:public-rev-dns

$ ndcli create pool it-infra vlan 562
$ ndcli modify pool it-infra add subnet 172.20.36.0/24 gw 172.20.36.1
INFO - Created subnet 172.20.36.0/24 in layer3domain default
INFO - Creating zone 36.20.172.in-addr.arpa with profile internal-rev-dns

$ ndcli create pool dns-public vlan 473
$ ndcli modify pool dns-public add subnet 217.160.80.0/22 gw 217.160.80.1
INFO - Created subnet 217.160.80.0/22 in layer3domain default
INFO - Creating zone 80.160.217.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 81.160.217.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 82.160.217.in-addr.arpa with profile public-rev-dns
INFO - Creating zone 83.160.217.in-addr.arpa with profile public-rev-dns
$ ndcli create pool dns-public-v6
$ ndcli modify pool dns-public-v6 add subnet 2001:db8:fe:53::/64 gw 2001:db8:fe:53::1
INFO - Created subnet 2001:db8:fe:53::/64 in layer3domain default
INFO - Creating zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa with profile public-rev-dns

$ ndcli create zone example.net profile internal
INFO - Creating zone example.net with profile internal
$ ndcli modify zone example.net create view public profile public
$ ndcli modify zone example.net rename view default to internal

# Now do the tests :-)

$ ndcli create rr gw-v563.example.net. a 172.20.36.1 view internal -q

$ ndcli create rr gw-v473.example.net. a 217.160.80.1 view internal public -q

$ ndcli create rr gw-v473-v6.example.net. aaaa 2001:db8:fe:53::1 view internal public -q

$ ndcli create rr int-srv.example.net. from it-infra view internal -q
created:2013-08-20 18:08:09
gateway:172.20.36.1
ip:172.20.36.2
layer3domain:default
mask:255.255.255.0
modified:2013-08-20 18:08:09
modified_by:admin
pool:it-infra
ptr_target:int-srv.example.net.
reverse_zone:36.20.172.in-addr.arpa
status:Static
subnet:172.20.36.0/24

$ ndcli create rr pub-srv.example.net. from dns-public view internal public -q
created:2013-08-20 18:08:09
gateway:217.160.80.1
ip:217.160.80.2
layer3domain:default
mask:255.255.252.0
modified:2013-08-20 18:08:09
modified_by:admin
pool:dns-public
ptr_target:pub-srv.example.net.
reverse_zone:80.160.217.in-addr.arpa
status:Static
subnet:217.160.80.0/22

$ ndcli create rr pub-srv.example.net. from dns-public-v6 view internal public -q
created:2013-08-20 18:08:09
gateway:2001:db8:fe:53::1
ip:2001:db8:fe:53::2
layer3domain:default
modified:2013-08-20 18:08:09
modified_by:admin
pool:dns-public-v6
prefixlength:64
ptr_target:pub-srv.example.net.
reverse_zone:3.5.0.0.e.f.0.0.8.d.8.0.1.0.0.2.ip6.arpa
status:Static
subnet:2001:db8:fe:53::/64

$ ndcli list zone example.net view public
record     zone       ttl   type value
@          example.net 86400 SOA  ns.example.de. dnsadmin.example.de. 2013082005 14400 3600 605000 86400
@          example.net       NS   ns.example.de.
@          example.net       NS   ns.example.com.
@          example.net       NS   ns.example.org.
@          example.net       NS   ns.example.biz.
gw-v473    example.net       A    217.160.80.1 
gw-v473-v6 example.net       AAAA 2001:db8:fe:53::1
pub-srv    example.net       A    217.160.80.2
pub-srv    example.net       AAAA 2001:db8:fe:53::2

$ ndcli list zone example.net view internal
record     zone       ttl   type value
@          example.net 86400 SOA  ins01.internal.com. dnsadmin.example.de. 2013082007 14400 3600 605000 86400
@          example.net       NS   ins01.internal.com.
@          example.net       NS   ins02.internal.com.
gw-v563    example.net       A    172.20.36.1
gw-v473    example.net       A    217.160.80.1 
gw-v473-v6 example.net       AAAA 2001:db8:fe:53::1
int-srv    example.net       A    172.20.36.2
pub-srv    example.net       A    217.160.80.2
pub-srv    example.net       AAAA 2001:db8:fe:53::2

# Cleanup

$ ndcli delete zone 36.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 80.160.217.in-addr.arpa --cleanup -q
$ ndcli delete zone 81.160.217.in-addr.arpa --cleanup -q
$ ndcli delete zone 82.160.217.in-addr.arpa --cleanup -q
$ ndcli delete zone 83.160.217.in-addr.arpa --cleanup -q
$ ndcli delete zone 3.5.0.0.e.f.0.0.8.d.8.0.1.0.0.2.ip6.arpa --cleanup -q

$ ndcli modify zone example.net delete view public --cleanup -q
$ ndcli delete zone example.net --cleanup -q

$ ndcli delete zone-profile internal
$ ndcli delete zone-profile public
$ ndcli delete zone-profile internal-rev-dns
$ ndcli delete zone-profile public-rev-dns

$ ndcli modify pool it-infra remove subnet 172.20.36.0/24
$ ndcli delete pool it-infra
$ ndcli modify pool dns-public remove subnet 217.160.80.0/22
$ ndcli delete pool dns-public
$ ndcli modify pool dns-public-v6 remove subnet 2001:db8:fe:53::/64
$ ndcli delete pool dns-public-v6

$ ndcli delete container 172.16.0.0/12
INFO - Deleting container 172.16.0.0/12 from layer3domain default
$ ndcli delete container 217.160.0.0/16
INFO - Deleting container 217.160.0.0/16 from layer3domain default
$ ndcli delete container 2001:db8::/32
INFO - Deleting container 2001:db8::/32 from layer3domain default
