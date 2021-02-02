$ ndcli create zone-profile example-public primary ns-example.company.com. mail dnsadmin@example.com
$ ndcli modify zone-profile example-public create rr @ ns ns-example.company.com.
INFO - Creating RR @ NS ns-example.company.com. in zone profile example-public
WARNING - ns-example.company.com. does not exist.

$ ndcli modify zone-profile example-public create rr @ ns ns-example.company.org.
WARNING - The name example-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-example.company.org. in zone profile example-public
WARNING - ns-example.company.org. does not exist.

$ ndcli modify zone-profile example-public create rr @ ns ns-example.company.biz.
WARNING - The name example-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-example.company.biz. in zone profile example-public
WARNING - ns-example.company.biz. does not exist.

$ ndcli modify zone-profile example-public create rr @ ns ns-example.company.de.
WARNING - The name example-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-example.company.de. in zone profile example-public
WARNING - ns-example.company.de. does not exist.


$ ndcli create zone-profile rev-public primary rns.company.com. mail dnsadmin@example.com
$ ndcli modify zone-profile rev-public create rr @ ns rns.company.com.
INFO - Creating RR @ NS rns.company.com. in zone profile rev-public
WARNING - rns.company.com. does not exist.

$ ndcli modify zone-profile rev-public create rr @ ns rns.company.org.
WARNING - The name rev-public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.org. in zone profile rev-public
WARNING - rns.company.org. does not exist.

$ ndcli modify zone-profile rev-public create rr @ ns rns.company.biz.
WARNING - The name rev-public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.biz. in zone profile rev-public
WARNING - rns.company.biz. does not exist.

$ ndcli modify zone-profile rev-public create rr @ ns rns.company.de.
WARNING - The name rev-public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.de. in zone profile rev-public
WARNING - rns.company.de. does not exist.

$ ndcli create container 74.208.0.0/16
INFO - Creating container 74.208.0.0/16 in layer3domain default
$ ndcli modify container 74.208.0.0/16 set attrs reverse_dns_profile:rev-public

$ ndcli create pool lxa-example-extern
$ ndcli modify pool lxa-example-extern add subnet 74.208.5.64/26
INFO - Created subnet 74.208.5.64/26 in layer3domain default
INFO - Creating zone 5.208.74.in-addr.arpa with profile rev-public

$ ndcli create pool lxa-ss1-ext
$ ndcli modify pool lxa-ss1-ext add subnet 74.208.2.0/25
INFO - Created subnet 74.208.2.0/25 in layer3domain default
INFO - Creating zone 2.208.74.in-addr.arpa with profile rev-public

$ ndcli create pool PraesenzNetz-LXA-2
$ ndcli modify pool PraesenzNetz-LXA-2 add subnet 74.208.2.128/25
INFO - Created subnet 74.208.2.128/25 in layer3domain default

$ ndcli create container 213.165.64.0/19 reverse_dns_profile:rev-public
INFO - Creating container 213.165.64.0/19 in layer3domain default
$ ndcli create pool example-external vlan 100
$ ndcli modify pool example-external add subnet 213.165.64.0/23 gw 213.165.65.253
INFO - Created subnet 213.165.64.0/23 in layer3domain default
INFO - Creating zone 64.165.213.in-addr.arpa with profile rev-public
INFO - Creating zone 65.165.213.in-addr.arpa with profile rev-public
$ ndcli modify pool example-external add subnet 213.165.66.0/24 gw 213.165.66.253
INFO - Created subnet 213.165.66.0/24 in layer3domain default
INFO - Creating zone 66.165.213.in-addr.arpa with profile rev-public

$ ndcli list zone 2.208.74.in-addr.arpa
record zone                  ttl   type value
@      2.208.74.in-addr.arpa 86400 SOA  rns.company.com. dnsadmin.example.com. 2012122802 14400 3600 605000 86400
@      2.208.74.in-addr.arpa       NS   rns.company.com.
@      2.208.74.in-addr.arpa       NS   rns.company.org.
@      2.208.74.in-addr.arpa       NS   rns.company.biz.
@      2.208.74.in-addr.arpa       NS   rns.company.de.

# import 2.208.74.in-addr.arpa
$ cat <<EOF | ndcli import rev-zone
2.208.74.in-addr.arpa.	86400	IN	SOA	rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400
2.208.74.in-addr.arpa.	86400	IN	NS	rns.company.com.
2.208.74.in-addr.arpa.	86400	IN	NS	rns.company.biz.
2.208.74.in-addr.arpa.	86400	IN	NS	rns.company.de.
2.208.74.in-addr.arpa.	86400	IN	NS	rns.company.org.
1.2.208.74.in-addr.arpa. 86400	IN	PTR	vl-418-sec.gw-dists-r5.slr.lxa.network.test.
254.2.208.74.in-addr.arpa. 86400 IN	NS	crns.example-dns.de.
254.2.208.74.in-addr.arpa. 86400 IN	NS	crns.example-dns.biz.
254.2.208.74.in-addr.arpa. 86400 IN	NS	crns.example-dns.com.
254.2.208.74.in-addr.arpa. 86400 IN	NS	crns.example-dns.org.
2.208.74.in-addr.arpa.	86400	IN	SOA	rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400
EOF
RECORD - 2.208.74.in-addr.arpa. 86400 IN SOA rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400
INFO - Nothing to do
RECORD - 2.208.74.in-addr.arpa. 86400 IN NS rns.company.com.
INFO - 2.208.74.in-addr.arpa. NS rns.company.com. already exists
RECORD - 2.208.74.in-addr.arpa. 86400 IN NS rns.company.biz.
INFO - 2.208.74.in-addr.arpa. NS rns.company.biz. already exists
RECORD - 2.208.74.in-addr.arpa. 86400 IN NS rns.company.de.
INFO - 2.208.74.in-addr.arpa. NS rns.company.de. already exists
RECORD - 2.208.74.in-addr.arpa. 86400 IN NS rns.company.org.
INFO - 2.208.74.in-addr.arpa. NS rns.company.org. already exists
RECORD - 1.2.208.74.in-addr.arpa. 86400 IN PTR vl-418-sec.gw-dists-r5.slr.lxa.network.test.
INFO - Marked IP 74.208.2.1 from layer3domain default as static
INFO - Creating RR 1 PTR vl-418-sec.gw-dists-r5.slr.lxa.network.test. in zone 2.208.74.in-addr.arpa
RECORD - 254.2.208.74.in-addr.arpa. 86400 IN NS crns.example-dns.de.
INFO - Creating RR 254 NS crns.example-dns.de. in zone 2.208.74.in-addr.arpa
WARNING - crns.example-dns.de. does not exist.
RECORD - 254.2.208.74.in-addr.arpa. 86400 IN NS crns.example-dns.biz.
WARNING - The name 254.2.208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 254 NS crns.example-dns.biz. in zone 2.208.74.in-addr.arpa
WARNING - crns.example-dns.biz. does not exist.
RECORD - 254.2.208.74.in-addr.arpa. 86400 IN NS crns.example-dns.com.
WARNING - The name 254.2.208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 254 NS crns.example-dns.com. in zone 2.208.74.in-addr.arpa
WARNING - crns.example-dns.com. does not exist.
RECORD - 254.2.208.74.in-addr.arpa. 86400 IN NS crns.example-dns.org.
WARNING - The name 254.2.208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 254 NS crns.example-dns.org. in zone 2.208.74.in-addr.arpa
WARNING - crns.example-dns.org. does not exist.

$ ndcli list zone 2.208.74.in-addr.arpa
record zone                  ttl   type value
@      2.208.74.in-addr.arpa 86400 SOA  rns.company.com. dnsadmin.example.com. 2012122802 14400 3600 605000 86400
1      2.208.74.in-addr.arpa       PTR  vl-418-sec.gw-dists-r5.slr.lxa.network.test.
@      2.208.74.in-addr.arpa       NS   rns.company.com.
@      2.208.74.in-addr.arpa       NS   rns.company.org.
@      2.208.74.in-addr.arpa       NS   rns.company.biz.
@      2.208.74.in-addr.arpa       NS   rns.company.de.
254    2.208.74.in-addr.arpa       NS   crns.example-dns.de.
254    2.208.74.in-addr.arpa       NS   crns.example-dns.biz.
254    2.208.74.in-addr.arpa       NS   crns.example-dns.com.
254    2.208.74.in-addr.arpa       NS   crns.example-dns.org.

# import 208.74.in-addr.arpa
$ cat <<EOF | ndcli import zone 208.74.in-addr.arpa
208.74.in-addr.arpa.	3600	IN	SOA	rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400
208.74.in-addr.arpa.	3600	IN	NS	rns.company.com.
208.74.in-addr.arpa.	3600	IN	NS	rns.company.de.
208.74.in-addr.arpa.	3600	IN	NS	rns.company.org.
208.74.in-addr.arpa.	3600	IN	NS	rns.company.biz.
188.208.74.in-addr.arpa. 3600	IN	NS	ns1.liveservers.us.
188.208.74.in-addr.arpa. 3600	IN	NS	ns2.liveservers.us.
254.208.74.in-addr.arpa. 3600	IN	NS	rdns1.internetx.de.
254.208.74.in-addr.arpa. 3600	IN	NS	rdns2.internetx.de.
208.74.in-addr.arpa.	3600	IN	SOA	rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400
EOF
INFO - Creating zone 208.74.in-addr.arpa
RECORD - 208.74.in-addr.arpa. 3600 IN SOA rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400
INFO - Creating RR @ SOA rns.company.com. dnsadmin.1und1.de. 2012122700 7200 3600 604800 86400 in zone 208.74.in-addr.arpa
RECORD - 208.74.in-addr.arpa. 3600 IN NS rns.company.com.
INFO - Creating RR @ NS rns.company.com. in zone 208.74.in-addr.arpa
WARNING - rns.company.com. does not exist.
RECORD - 208.74.in-addr.arpa. 3600 IN NS rns.company.de.
WARNING - The name 208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.de. in zone 208.74.in-addr.arpa
WARNING - rns.company.de. does not exist.
RECORD - 208.74.in-addr.arpa. 3600 IN NS rns.company.org.
WARNING - The name 208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.org. in zone 208.74.in-addr.arpa
WARNING - rns.company.org. does not exist.
RECORD - 208.74.in-addr.arpa. 3600 IN NS rns.company.biz.
WARNING - The name 208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.biz. in zone 208.74.in-addr.arpa
WARNING - rns.company.biz. does not exist.
RECORD - 188.208.74.in-addr.arpa. 3600 IN NS ns1.liveservers.us.
INFO - Creating RR 188 NS ns1.liveservers.us. in zone 208.74.in-addr.arpa
WARNING - ns1.liveservers.us. does not exist.
RECORD - 188.208.74.in-addr.arpa. 3600 IN NS ns2.liveservers.us.
WARNING - The name 188.208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 188 NS ns2.liveservers.us. in zone 208.74.in-addr.arpa
WARNING - ns2.liveservers.us. does not exist.
RECORD - 254.208.74.in-addr.arpa. 3600 IN NS rdns1.internetx.de.
INFO - Creating RR 254 NS rdns1.internetx.de. in zone 208.74.in-addr.arpa
WARNING - rdns1.internetx.de. does not exist.
RECORD - 254.208.74.in-addr.arpa. 3600 IN NS rdns2.internetx.de.
WARNING - The name 254.208.74.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 254 NS rdns2.internetx.de. in zone 208.74.in-addr.arpa
WARNING - rdns2.internetx.de. does not exist.

# import example.com de
$ cat <<EOF | ndcli import zone example.com view de
example.com.        86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
wiki.example.com.   86400   IN      A       213.165.65.35
example.com.	86400	IN	MX	10 mailin-de.example.net.
www.example.com.	86400	IN	A	213.165.64.179
example.com.        86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
EOF
INFO - Creating zone example.com view de
RECORD - example.com. 86400 IN SOA dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
INFO - Creating RR @ SOA dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600 in zone example.com
RECORD - wiki.example.com. 86400 IN A 213.165.65.35
INFO - Marked IP 213.165.64.179 from layer3domain default as static
INFO - Creating RR wiki A 213.165.65.35 in zone example.com
INFO - Creating RR 35 PTR wiki.example.com. in zone 65.165.213.in-addr.arpa
RECORD - example.com. 86400 IN MX 10 mailin-de.example.net.
INFO - Creating RR @ MX 10 mailin-de.example.net. in zone example.com
WARNING - mailin-de.example.net. does not exist.
RECORD - www.example.com. 86400 IN A 213.165.64.179
INFO - Marked IP 213.165.65.35 from layer3domain default as static
INFO - Creating RR www A 213.165.64.179 in zone example.com
INFO - Creating RR 179 PTR www.example.com. in zone 64.165.213.in-addr.arpa

$ ndcli list zone example.com views
name
de

# import example.com us
$ cat <<EOF | ndcli import zone example.com view us
example.com.        86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
wiki.example.com.   86400   IN      A       213.165.65.35
example.com.	86400	IN	MX	10 mailin-us.example.net.
www.example.com.	86400	IN	A	74.208.5.85
example.com.        86400   IN      SOA     dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
EOF
INFO - Creating zone example.com view us
RECORD - example.com. 86400 IN SOA dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600
INFO - Creating RR @ SOA dns.example.net. hostmaster.example.net. 2012120600 28800 7200 604800 3600 in zone example.com view us
RECORD - wiki.example.com. 86400 IN A 213.165.65.35
INFO - Marked IP 74.208.5.85 from layer3domain default as static
INFO - Creating RR wiki A 213.165.65.35 in zone example.com view us
INFO - 35.65.165.213.in-addr.arpa. PTR wiki.example.com. already exists
RECORD - example.com. 86400 IN MX 10 mailin-us.example.net.
INFO - Creating RR @ MX 10 mailin-us.example.net. in zone example.com view us
WARNING - mailin-us.example.net. does not exist.
RECORD - www.example.com. 86400 IN A 74.208.5.85
INFO - Creating RR www A 74.208.5.85 in zone example.com view us
INFO - Creating RR 85 PTR www.example.com. in zone 5.208.74.in-addr.arpa

$ ndcli list zone example.com views
name
de
us

$ ndcli modify zone example.com delete view us --cleanup -q
$ ndcli delete zone example.com -q --cleanup
$ ndcli delete zone 208.74.in-addr.arpa -q --cleanup
$ ndcli delete zone 2.208.74.in-addr.arpa -q --cleanup
$ ndcli delete zone 5.208.74.in-addr.arpa -q --cleanup
$ ndcli delete zone 64.165.213.in-addr.arpa -q --cleanup
$ ndcli delete zone 65.165.213.in-addr.arpa -q --cleanup
$ ndcli delete zone 66.165.213.in-addr.arpa -q --cleanup

$ ndcli modify pool example-external remove subnet 213.165.64.0/23
$ ndcli modify pool example-external remove subnet 213.165.66.0/24
$ ndcli delete pool example-external

$ ndcli modify pool lxa-example-extern remove subnet 74.208.5.64/26
$ ndcli delete pool lxa-example-extern

$ ndcli delete container 213.165.64.0/19
INFO - Deleting container 213.165.64.0/19 from layer3domain default
$ ndcli delete container 74.208.0.0/16
INFO - Deleting container 74.208.0.0/16 from layer3domain default
