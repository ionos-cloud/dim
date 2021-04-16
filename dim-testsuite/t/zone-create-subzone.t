$ ndcli create zone example.net primary ns-example.company.org. mail hostmaster@example.net
WARNING - Creating zone example.net without profile
$ ndcli create rr example.net. ns ns-example.company.com.
INFO - Creating RR @ NS ns-example.company.com. in zone example.net
WARNING - ns-example.company.com. does not exist.
$ ndcli create rr example.net. ns ns-example.company.org.
WARNING - The name example.net. already existed, creating round robin record
INFO - Creating RR @ NS ns-example.company.org. in zone example.net
WARNING - ns-example.company.org. does not exist.
$ ndcli create rr example.net. ns ns-example.company.biz.
WARNING - The name example.net. already existed, creating round robin record
INFO - Creating RR @ NS ns-example.company.biz. in zone example.net
WARNING - ns-example.company.biz. does not exist.
$ ndcli create rr example.net. a 213.165.65.50
INFO - Marked IP 213.165.65.50 from layer3domain default as static
INFO - Creating RR @ A 213.165.65.50 in zone example.net
INFO - No zone found for 50.65.165.213.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr mx0.example.net. a 213.165.64.100
INFO - Marked IP 213.165.64.100 from layer3domain default as static
INFO - Creating RR mx0 A 213.165.64.100 in zone example.net
INFO - No zone found for 100.64.165.213.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr foo.example.net. a 10.99.1.13
INFO - Marked IP 10.99.1.13 from layer3domain default as static
INFO - Creating RR foo A 10.99.1.13 in zone example.net
INFO - No zone found for 13.1.99.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr bar.example.net. a 10.99.1.14
INFO - Marked IP 10.99.1.14 from layer3domain default as static
INFO - Creating RR bar A 10.99.1.14 in zone example.net
INFO - No zone found for 14.1.99.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr example.net. ttl 900 mx 10 mx0.example.net.
INFO - Creating RR @ 900 MX 10 mx0.example.net. in zone example.net
$ ndcli create rr v300.example.net. a 10.99.1.12
INFO - Marked IP 10.99.1.12 from layer3domain default as static
INFO - Creating RR v300 A 10.99.1.12 in zone example.net
INFO - No zone found for 12.1.99.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr foo.v300.example.net. cname foo
INFO - Creating RR foo.v300 CNAME foo in zone example.net
$ ndcli create rr bar.v300.example.net. cname bar.example.net.
INFO - Creating RR bar.v300 CNAME bar.example.net. in zone example.net
$ ndcli list zone v300.example.net
ERROR - Zone v300.example.net does not exist
$ ndcli list zone example.net
record   zone        ttl   type  value
@        example.net 86400 SOA   ns-example.company.org. hostmaster.example.net. 2012102612 14400 3600 605000 86400
@        example.net       NS    ns-example.company.com.
@        example.net       NS    ns-example.company.org.
@        example.net       NS    ns-example.company.biz.
@        example.net       A     213.165.65.50
@        example.net 900   MX    10 mx0.example.net.
bar      example.net       A     10.99.1.14
bar.v300 example.net       CNAME bar.example.net.
foo      example.net       A     10.99.1.13
foo.v300 example.net       CNAME foo
mx0      example.net       A     213.165.64.100
v300     example.net       A     10.99.1.12
$ ndcli dump zone v300.example.net
ERROR - Zone v300.example.net does not exist
$ ndcli dump zone example.net
example.net.	86400	IN	SOA	ns-example.company.org. hostmaster.example.net. 2012092000 600 7200 604800 3600
bar.example.net.	86400	IN	A	10.99.1.14
bar.v300.example.net.	86400	IN	CNAME	bar.example.net.
example.net.	86400	IN	NS	ns-example.company.com.
example.net.	86400	IN	NS	ns-example.company.org.
example.net.	86400	IN	NS	ns-example.company.biz.
example.net.	86400	IN	A	213.165.65.50
example.net.	900	IN	MX	10 mx0.example.net.
foo.example.net.	86400	IN	A	10.99.1.13
foo.v300.example.net.	86400	IN	CNAME	foo.example.net.
mx0.example.net.	86400	IN	A	213.165.64.100
v300.example.net.	86400	IN	A	10.99.1.12
$ ndcli create zone v300.example.net primary ins01.server.lan. mail dnsadmin@1und1.de
WARNING - Creating zone v300.example.net without profile
INFO - Creating views default for zone v300.example.net
INFO - Moving RR v300 A 10.99.1.12 in zone v300.example.net from zone example.net
INFO - Moving RR foo.v300 CNAME foo in zone v300.example.net from zone example.net
INFO - Moving RR bar.v300 CNAME bar.example.net. in zone v300.example.net from zone example.net
$ ndcli list zone v300.example.net
record zone             ttl   type  value
@      v300.example.net 86400 SOA   ins01.server.lan. dnsadmin.1und1.de. <YYYYMMDD01> 600 7200 604800 3600
@      v300.example.net       A     10.99.1.12
bar    v300.example.net       CNAME bar.example.net.
foo    v300.example.net       CNAME foo.example.net.

$ ndcli dump zone v300.example.net
v300.example.net.	86400	IN	SOA	ins01.server.lan. dnsadmin.1und1.de. 2012092000 600 7200 604800 3600
bar.v300.example.net.	86400	IN	CNAME	bar.example.net.
foo.v300.example.net.	86400	IN	CNAME	foo.example.net.
v300.example.net.	86400	IN	A	10.99.1.12

$ ndcli delete zone example.net --cleanup
INFO - Deleting RR @ NS ns-example.company.com. from zone example.net
INFO - Deleting RR @ NS ns-example.company.org. from zone example.net
INFO - Deleting RR @ NS ns-example.company.biz. from zone example.net
INFO - Deleting RR @ A 213.165.65.50 from zone example.net
INFO - Freeing IP 213.165.65.50 from layer3domain default
INFO - Deleting RR @ 900 MX 10 mx0.example.net. from zone example.net
WARNING - bar.example.net. is referenced by other records
INFO - Deleting RR bar A 10.99.1.14 from zone example.net
INFO - Freeing IP 10.99.1.14 from layer3domain default
WARNING - foo.example.net. is referenced by other records
INFO - Deleting RR foo A 10.99.1.13 from zone example.net
INFO - Freeing IP 10.99.1.13 from layer3domain default
INFO - Deleting RR mx0 A 213.165.64.100 from zone example.net
INFO - Freeing IP 213.165.64.100 from layer3domain default
$ ndcli delete zone v300.example.net --cleanup
INFO - Deleting RR @ A 10.99.1.12 from zone v300.example.net
INFO - Freeing IP 10.99.1.12 from layer3domain default
INFO - Deleting RR bar CNAME bar.example.net. from zone v300.example.net
INFO - Deleting RR foo CNAME foo.example.net. from zone v300.example.net
