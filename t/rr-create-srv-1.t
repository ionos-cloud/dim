# rfc 2782 and 6335
# service proto name SRV Prio Weight Port Target
# prio 0-65535
# weight 0-65535
# port 0-65535
# target must be a or aaaa
# at the moment I dont want to put effort in testing out rfc6335 limits
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de.
INFO - No zone found for _ldap._tcp.a.de.
$ ndcli create container 2001:db8::/32
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool vlan 12
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create pool apool_v6 vlan 12
$ ndcli modify pool apool_v6 add subnet 2001:db8:dead:fe::/64 --no-default-reserve
INFO - Created subnet 2001:db8:dead:fe::/64 in layer3domain default
WARNING - Creating zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool apool_v6 get delegation 112
created:2012-11-27 22:57:35
ip:2001:db8:dead:fe::/112
layer3domain:default
modified:2012-11-27 22:57:35
modified_by:user
pool:apool_v6
prefixlength:64
reverse_zone:e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
status:Delegation
subnet:2001:db8:dead:fe::/64
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 1.2.3.2
INFO - Marked IP 1.2.3.2 from layer3domain default as static
INFO - Creating RR @ A 1.2.3.2 in zone a.de
INFO - Creating RR 2 PTR a.de. in zone 3.2.1.in-addr.arpa
$ ndcli create rr a.de. aaaa 2001:db8:dead:fe:389::1:100
INFO - Marked IP 2001:db8:dead:fe:389:0:1:100 from layer3domain default as static
INFO - Creating RR @ AAAA 2001:db8:dead:fe:389:0:1:100 in zone a.de
INFO - Creating RR 0.0.1.0.1.0.0.0.0.0.0.0.9.8.3.0 PTR a.de. in zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli create rr 4.a.de. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR 4 A 1.2.3.4 in zone a.de
INFO - Creating RR 4 PTR 4.a.de. in zone 3.2.1.in-addr.arpa
$ ndcli create rr 6.a.de. aaaa 2001:db8:dead:fe:389::1:200
INFO - Marked IP 2001:db8:dead:fe:389:0:1:200 from layer3domain default as static
INFO - Creating RR 6 AAAA 2001:db8:dead:fe:389:0:1:200 in zone a.de
INFO - Creating RR 0.0.2.0.1.0.0.0.0.0.0.0.9.8.3.0 PTR 6.a.de. in zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli create rr srv.a.de. cname a.de.
INFO - Creating RR srv CNAME a.de. in zone a.de
$ ndcli create rr a.de. srv 12 12 12 a.de.
ERROR - SRV records must start with two _ labels service and proto
$ ndcli create rr _d.a.de. srv 12 12 12 a.de.
ERROR - SRV records must start with two _ labels service and proto
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 srv.a.de.
ERROR - The target of SRV records must have A, AAAA or NS resource records
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 a.de.
INFO - Creating RR _ldap._tcp SRV 10 10 389 a.de. in zone a.de
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 4.a.de.
WARNING - The name _ldap._tcp.a.de. already existed, creating round robin record
INFO - Creating RR _ldap._tcp SRV 10 10 389 4.a.de. in zone a.de
$ ndcli create rr _ldap._tcp.a.de. srv 10 10 389 6.a.de.
WARNING - The name _ldap._tcp.a.de. already existed, creating round robin record
INFO - Creating RR _ldap._tcp SRV 10 10 389 6.a.de. in zone a.de
$ ndcli create rr w4.a.de. from apool
created:2012-12-04 16:22:55
gateway:1.2.3.1
layer3domain:default
ip:1.2.3.1
mask:255.255.255.0
modified:2012-12-04 16:22:55
modified_by:user
pool:apool
ptr_target:w4.a.de.
reverse_zone:3.2.1.in-addr.arpa
status:Static
subnet:1.2.3.0/24
INFO - Marked IP 1.2.3.1 from layer3domain default as static
INFO - Creating RR w4 A 1.2.3.1 in zone a.de
INFO - Creating RR 1 PTR w4.a.de. in zone 3.2.1.in-addr.arpa
$ ndcli create rr w7.a.de. from apool_v6 -q
created:2012-12-04 16:24:39
ip:2001:db8:dead:fe::1:0
layer3domain:default
modified:2012-12-04 16:24:39
modified_by:user
pool:apool_v6
prefixlength:64
ptr_target:w7.a.de.
reverse_zone:e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
status:Static
subnet:2001:db8:dead:fe::/64
$ ndcli create rr w6.a.de. from apool_v6
created:2012-12-04 16:14:29
layer3domain:default
ip:2001:db8:dead:fe::1:1
modified:2012-12-04 16:14:29
modified_by:user
pool:apool_v6
prefixlength:64
ptr_target:w6.a.de.
reverse_zone:e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
status:Static
subnet:2001:db8:dead:fe::/64
INFO - Marked IP 2001:db8:dead:fe::1:1 from layer3domain default as static
INFO - Creating RR w6 AAAA 2001:db8:dead:fe::1:1 in zone a.de
INFO - Creating RR 1.0.0.0.1.0.0.0.0.0.0.0.0.0.0.0 PTR w6.a.de. in zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli delete zone a.de --cleanup
INFO - Deleting RR _ldap._tcp SRV 10 10 389 a.de. from zone a.de
INFO - Deleting RR 2 PTR a.de. from zone 3.2.1.in-addr.arpa
INFO - Deleting RR 0.0.0.0.1.0.0.0.0.0.0.0.0.0.0.0 PTR w7.a.de. from zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ AAAA 2001:db8:dead:fe:389:0:1:100 from zone a.de
INFO - Freeing IP 1.2.3.2 from layer3domain default
INFO - Deleting RR srv CNAME a.de. from zone a.de
INFO - Deleting RR w7 AAAA 2001:db8:dead:fe::1:0 from zone a.de
INFO - Freeing IP 2001:db8:dead:fe:389:0:1:100 from layer3domain default
INFO - Deleting RR 0.0.1.0.1.0.0.0.0.0.0.0.9.8.3.0 PTR a.de. from zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR 1 PTR w4.a.de. from zone 3.2.1.in-addr.arpa
INFO - Deleting RR @ A 1.2.3.2 from zone a.de
INFO - Freeing IP 1.2.3.4 from layer3domain default
INFO - Deleting RR w6 AAAA 2001:db8:dead:fe::1:1 from zone a.de
INFO - Deleting RR 4 A 1.2.3.4 from zone a.de
INFO - Deleting RR 4 PTR 4.a.de. from zone 3.2.1.in-addr.arpa
INFO - Freeing IP 2001:db8:dead:fe:389:0:1:200 from layer3domain default
INFO - Deleting RR 1.0.0.0.1.0.0.0.0.0.0.0.0.0.0.0 PTR w6.a.de. from zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR w4 A 1.2.3.1 from zone a.de
INFO - Freeing IP 1.2.3.1 from layer3domain default
INFO - Deleting RR _ldap._tcp SRV 10 10 389 6.a.de. from zone a.de
INFO - Deleting RR 0.0.2.0.1.0.0.0.0.0.0.0.9.8.3.0 PTR 6.a.de. from zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:dead:fe::1:1 from layer3domain default
INFO - Deleting RR _ldap._tcp SRV 10 10 389 4.a.de. from zone a.de
INFO - Deleting RR 6 AAAA 2001:db8:dead:fe:389:0:1:200 from zone a.de
INFO - Freeing IP 2001:db8:dead:fe::1:0 from layer3domain default
$ ndcli delete zone 3.2.1.in-addr.arpa
$ ndcli delete zone e.f.0.0.d.a.e.d.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli modify pool apool_v6 remove delegation 2001:db8:dead:fe::/112
$ ndcli modify pool apool_v6 remove subnet 2001:db8:dead:fe::/64
$ ndcli delete pool apool_v6
$ ndcli modify pool apool remove subnet 1.2.3.0/24
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
