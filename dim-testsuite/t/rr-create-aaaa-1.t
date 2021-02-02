$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create container 2001:db8::/32 rir:ripe
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli create pool demo-v6 vlan 312
$ ndcli modify pool demo-v6 add subnet 2001:db8:400:100::/64 gw 2001:db8:400:100::1
INFO - Created subnet 2001:db8:400:100::/64 in layer3domain default
WARNING - Creating zone 0.0.1.0.0.0.4.0.8.d.8.0.1.0.0.2.ip6.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool demo-v6 get delegation 112 "comment:networking equipment only"
comment:networking equipment only
created:2012-11-15 14:31:35
gateway:2001:db8:400:100::1
ip:2001:db8:400:100::1:0/112
layer3domain:default
modified:2012-11-15 14:31:35
modified_by:user
pool:demo-v6
prefixlength:64
reverse_zone:0.0.1.0.0.0.4.0.8.d.8.0.1.0.0.2.ip6.arpa
status:Delegation
subnet:2001:db8:400:100::/64
$ ndcli create rr gw-v312.bs.kae.de.example.com. aaaa 2001:db8:400:100::1 -q
$ ndcli create rr gw-v312a.bs.kae.de.example.com. aaaa 2001:db8:400:100::a -q
$ ndcli create rr gw-v312b.bs.kae.de.example.com. aaaa 2001:db8:400:100::b -q
$ ndcli create rr s1.example.com. from demo-v6 -q
created:2012-11-28 16:58:11
gateway:2001:db8:400:100::1
ip:2001:db8:400:100::2
layer3domain:default
modified:2012-11-28 16:58:11
modified_by:admin
pool:demo-v6
prefixlength:64
ptr_target:s1.example.com.
reverse_zone:0.0.1.0.0.0.4.0.8.b.d.0.1.0.0.2.ip6.arpa
status:Static
subnet:2001:db8:400:100::/64
$ ndcli modify pool demo-v6 ip 2001:db8:400:100::1 set attrs domain:gw-v312
$ ndcli list ips 2001:db8:400:100::/124 -L 20 -a ip,status,ptr_target,domain,comment
ip                  status    ptr_target                        domain     comment
2001:db8:400:100::  Reserved
2001:db8:400:100::1 Static    gw-v312.bs.kae.de.example.com.  gw-v312
2001:db8:400:100::2 Static    s1.example.com.
2001:db8:400:100::3 Available
2001:db8:400:100::4 Available
2001:db8:400:100::5 Available
2001:db8:400:100::6 Available
2001:db8:400:100::7 Available
2001:db8:400:100::8 Available
2001:db8:400:100::9 Available
2001:db8:400:100::a Static    gw-v312a.bs.kae.de.example.com.
2001:db8:400:100::b Static    gw-v312b.bs.kae.de.example.com.
2001:db8:400:100::c Available
2001:db8:400:100::d Available
2001:db8:400:100::e Available
2001:db8:400:100::f Available
INFO - Result for list ips 2001:db8:400:100::/124
$ ndcli delete rr gw-v312.bs.kae.de.example.com. -q
$ ndcli delete rr gw-v312a.bs.kae.de.example.com. -q
$ ndcli delete rr gw-v312b.bs.kae.de.example.com. -q
$ ndcli delete rr s1.example.com. -q
$ ndcli delete zone example.com
$ ndcli delete zone 0.0.1.0.0.0.4.0.8.d.8.0.1.0.0.2.ip6.arpa
$ ndcli modify pool demo-v6 remove delegation 2001:db8:400:100::1:0/112
$ ndcli modify pool demo-v6 remove subnet 2001:db8:400:100::/64
$ ndcli delete pool demo-v6
$ ndcli delete container 2001:db8::/32
INFO - Deleting container 2001:db8::/32 from layer3domain default
