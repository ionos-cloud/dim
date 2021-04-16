$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone example.com create view de
WARNING - You created a view without specifing a profile, your view is totally empty.

$ cat <<EOF | ndcli import zone example.com
example.com.		86400	IN	SOA	dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
wiki.example.com.		86400	IN	A	213.165.65.35
*.portaldev-demo001.v976.example.com. 86400	IN CNAME portaldev-demo001.v976.example.net.
_jabber._tcp.example.com.	86400	IN	SRV	5 0 5269 xmpp-example.example.net.
example.com.		86400	IN 	AAAA	2001:db8:5c1:80::443:1
example.com.		86400	IN	SOA	dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
EOF
INFO - Creating zone example.com
ERROR - Zone example.com already exists

$ cat <<EOF | ndcli import zone example.com view de
example.com.                86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
wiki.example.com.           86400   IN      A       213.165.65.35
*.portaldev-demo001.v976.example.com. 86400 IN CNAME portaldev-demo001.v976.example.net.
_jabber._tcp.example.com.   86400   IN      SRV     5 0 5269 xmpp-example.example.net.
example.com.                86400   IN      AAAA    2001:db8:5c1:80::443:1
example.com.                86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
EOF
INFO - Creating zone example.com view de
ERROR - View de already exists for zone example.com

$ cat <<EOF | ndcli import zone example.com view us
example.com.                86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
wiki.example.com.           86400   IN      A       213.165.65.35
*.portaldev-demo001.v976.example.com. 86400 IN CNAME portaldev-demo001.v976.example.net.
_jabber._tcp.example.com.   86400   IN      SRV     5 0 5269 xmpp-example.example.net.
example.com.                86400   IN      AAAA    2001:db8:5c1:80::443:1
example.com.                86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
EOF
INFO - Creating zone example.com view us
RECORD - example.com. 86400 IN SOA dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
INFO - Creating RR @ SOA dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600 in zone example.com view us
RECORD - example.com. 86400 IN AAAA 2001:db8:5c1:80::443:1
INFO - Marked IP 2001:db8:5c1:80::443:1 from layer3domain default as static
INFO - Creating RR @ AAAA 2001:db8:5c1:80::443:1 in zone example.com view us
INFO - No zone found for 1.0.0.0.3.4.4.0.0.0.0.0.0.0.0.0.0.8.0.0.1.c.5.0.8.b.d.0.1.0.0.2.ip6.arpa.
WARNING - No reverse zone found. Only creating forward entry.
RECORD - wiki.example.com. 86400 IN A 213.165.65.35
INFO - Marked IP 213.165.65.35 from layer3domain default as static
INFO - Creating RR wiki A 213.165.65.35 in zone example.com view us
INFO - No zone found for 35.65.165.213.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
RECORD - *.portaldev-demo001.v976.example.com. 86400 IN CNAME portaldev-demo001.v976.example.net.
INFO - Creating RR *.portaldev-demo001.v976 CNAME portaldev-demo001.v976.example.net. in zone example.com view us
WARNING - portaldev-demo001.v976.example.net. does not exist.
RECORD - _jabber._tcp.example.com. 86400 IN SRV 5 0 5269 xmpp-example.example.net.
INFO - Creating RR _jabber._tcp SRV 5 0 5269 xmpp-example.example.net. in zone example.com view us
WARNING - xmpp-example.example.net. does not exist.

$ ndcli modify zone example.com delete view default --cleanup -q
$ ndcli modify zone example.com delete view de --cleanup -q
$ ndcli delete zone example.com --cleanup -q
