# None existing revers Zones for ipv6 are automatically created
# as /64
# When we do the real import this shall not happen because
# the pools are created before the import.
#

$ ndcli create zone-profile public primary rns.company.com. mail dnsadmin@example.com

$ ndcli modify zone-profile public create rr @ ns rns.company.com.
INFO - Creating RR @ NS rns.company.com. in zone profile public
WARNING - rns.company.com. does not exist.

$ ndcli modify zone-profile public create rr @ ns rns.company.biz.
WARNING - The name public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.biz. in zone profile public
WARNING - rns.company.biz. does not exist.

$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@example.com
$ ndcli modify zone-profile internal create rr @ ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ ns ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.

$ ndcli create container 2001:db8::/32
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli modify container 2001:db8::/32 set attrs reverse_dns_profile:public

$ ndcli create container 2001:db8:fe::/47 "comment: a comment"
INFO - Creating container 2001:db8:fe::/47 in layer3domain default
$ ndcli create container 2001:db8:fc::/47 "comment: another comment" reverse_dns_profile:internal
INFO - Creating container 2001:db8:fc::/47 in layer3domain default

$ ndcli create pool dns-public-anycast_v6
$ ndcli modify pool dns-public-anycast_v6 add subnet 2001:db8:fe:53::/64
INFO - Created subnet 2001:db8:fe:53::/64 in layer3domain default
INFO - Creating zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa with profile public

$ cat <<EOF | ndcli import rev-zone
f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. 3600    IN      SOA     rns.company.de. dnsadmin.foo.test. 2005099742 21601 7200 604800 3600
0.0.1.0.1.c.0.5.0.a.9.d.0.0.0.0.3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN PTR ns-de.company.de.
1.0.0.0.1.c.0.5.0.a.9.d.0.0.0.0.3.5.0.0.c.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN PTR anyins1.internal.test.
f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN NS rns.company.de.
f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN NS rns.company.com.
f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. 3600    IN      SOA     rns.company.de. dnsadmin.foo.test. 2005099742 21601 7200 604800 3600
EOF
RECORD - f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. 3600 IN SOA rns.company.de. dnsadmin.foo.test. 2005099742 21601 7200 604800 3600
INFO - Nothing to do
RECORD - 0.0.1.0.1.c.0.5.0.a.9.d.0.0.0.0.3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN PTR ns-de.company.de.
INFO - Creating RR 0.0.1.0.1.c.0.5.0.a.9.d.0.0.0.0 PTR ns-de.company.de. in zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
RECORD - 1.0.0.0.1.c.0.5.0.a.9.d.0.0.0.0.3.5.0.0.c.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN PTR anyins1.internal.test.
INFO - Creating zone 3.5.0.0.c.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa with profile internal
INFO - Creating RR 1.0.0.0.1.c.0.5.0.a.9.d.0.0.0.0 PTR anyins1.internal.test. in zone 3.5.0.0.c.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Marked IP 2001:db8:fe:53:0:d9a0:50c1:100 from layer3domain default as static
RECORD - f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN NS rns.company.de.
INFO - No zone found for f.0.0.8.b.d.0.1.0.0.2.ip6.arpa.
INFO - Marked IP 2001:db8:fc:53:0:d9a0:50c1:1 from layer3domain default as static
RECORD - f.0.0.8.b.d.0.1.0.0.2.ip6.arpa. IN NS rns.company.com.
INFO - No zone found for f.0.0.8.b.d.0.1.0.0.2.ip6.arpa.
# Only the first SOA record will be processed
#RECORD - f.0.0.8.b.d.0.1.0.0.2.ip6.arpa 3600    IN      SOA     rns.company.de. dnsadmin.foo.test. 2005099742 21601 7200 604800 3600
#INFO - Nothing to do

$ ndcli delete zone 3.5.0.0.e.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa --cleanup -q
$ ndcli delete zone 3.5.0.0.c.f.0.0.8.b.d.0.1.0.0.2.ip6.arpa --cleanup -q

$ ndcli modify pool dns-public-anycast_v6 remove subnet 2001:db8:fe:53::/64
$ ndcli delete pool dns-public-anycast_v6

$ ndcli delete zone-profile internal
$ ndcli delete zone-profile public
$ ndcli delete container 2001:db8:fe::/47
INFO - Deleting container 2001:db8:fe::/47 from layer3domain default
$ ndcli delete container 2001:db8:fc::/47
INFO - Deleting container 2001:db8:fc::/47 from layer3domain default
$ ndcli delete container 2001:db8::/32
INFO - Deleting container 2001:db8::/32 from layer3domain default

