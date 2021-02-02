$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@1u
$ ndcli modify zone-profile internal create rr @ NS ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ NS ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.

$ ndcli create container 172.16.0.0/12 
INFO - Creating container 172.16.0.0/12 in layer3domain default

$ ndcli create zone 29.172.in-addr.arpa profile internal
INFO - Creating zone 29.172.in-addr.arpa with profile internal

$ ndcli create zone customer.test profile internal
INFO - Creating zone customer.test with profile internal

$ ndcli create rr rtr.customer.test. txt test
INFO - Creating RR rtr TXT "test" in zone customer.test

$ ndcli create rr blartr.customer.test. a 172.29.0.100
INFO - Marked IP 172.29.0.100 from layer3domain default as static
INFO - Creating RR blartr A 172.29.0.100 in zone customer.test
INFO - Creating RR 100.0 PTR blartr.customer.test. in zone 29.172.in-addr.arpa

$ ndcli create rr blubb.rtr.customer.test. a 172.29.10.100
INFO - Marked IP 172.29.10.100 from layer3domain default as static
INFO - Creating RR blubb.rtr A 172.29.10.100 in zone customer.test
INFO - Creating RR 100.10 PTR blubb.rtr.customer.test. in zone 29.172.in-addr.arpa

$ ndcli create rr rtrblubb.customer.test. a 172.29.20.100
INFO - Marked IP 172.29.20.100 from layer3domain default as static
INFO - Creating RR rtrblubb A 172.29.20.100 in zone customer.test
INFO - Creating RR 100.20 PTR rtrblubb.customer.test. in zone 29.172.in-addr.arpa

$ ndcli create zone 0.29.172.in-addr.arpa
WARNING - Creating zone 0.29.172.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone 0.29.172.in-addr.arpa
INFO - Moving RR 100.0 PTR blartr.customer.test. in zone 0.29.172.in-addr.arpa from zone 29.172.in-addr.arpa

$ ndcli create zone rtr.customer.test profile internal
INFO - Creating zone rtr.customer.test with profile internal
INFO - Creating views default for zone rtr.customer.test
INFO - Moving RR rtr TXT "test" in zone rtr.customer.test from zone customer.test
INFO - Moving RR blubb.rtr A 172.29.10.100 in zone rtr.customer.test from zone customer.test
INFO - Creating RR rtr NS ins01.internal.test. in zone customer.test
WARNING - ins01.internal.test. does not exist.
WARNING - The name rtr.customer.test. already existed, creating round robin record
INFO - Creating RR rtr NS ins02.internal.test. in zone customer.test
WARNING - ins02.internal.test. does not exist.

$ ndcli dump zone customer.test
customer.test.	86400	IN	SOA	ins01.internal.test. dnsadmin.1u. 2013091005 14400 3600 605000 86400
blartr.customer.test.	86400	IN	A	172.29.0.100
customer.test.	86400	IN	NS	ins01.internal.test.
customer.test.	86400	IN	NS	ins02.internal.test.
rtr.customer.test.	86400	IN	NS	ins01.internal.test.
rtr.customer.test.	86400	IN	NS	ins02.internal.test.
rtrblubb.customer.test.	86400	IN	A	172.29.20.100

$ ndcli dump zone rtr.customer.test
rtr.customer.test.	86400	IN	SOA	ins01.internal.test. dnsadmin.1u. 2013091003 14400 3600 605000 86400
blubb.rtr.customer.test.	86400	IN	A	172.29.10.100
rtr.customer.test.	86400	IN	TXT	"test"
rtr.customer.test.	86400	IN	NS	ins01.internal.test.
rtr.customer.test.	86400	IN	NS	ins02.internal.test.

$ ndcli dump zone 29.172.in-addr.arpa
29.172.in-addr.arpa.	86400	IN	SOA	ins01.internal.test. dnsadmin.1u. 2013091005 14400 3600 605000 86400
100.10.29.172.in-addr.arpa.	86400	IN	PTR	blubb.rtr.customer.test.
100.20.29.172.in-addr.arpa.	86400	IN	PTR	rtrblubb.customer.test.
29.172.in-addr.arpa.	86400	IN	NS	ins01.internal.test.
29.172.in-addr.arpa.	86400	IN	NS	ins02.internal.test.

$ ndcli dump zone 0.29.172.in-addr.arpa
0.29.172.in-addr.arpa.	86400	IN	SOA	localhost. hostmaster.0.29.172.in-addr.arpa. 2013091002 14400 3600 605000 86400
100.0.29.172.in-addr.arpa.	86400	IN	PTR	blartr.customer.test.

$ ndcli delete zone rtr.customer.test -c -q
$ ndcli delete zone 0.29.172.in-addr.arpa -c -q
$ ndcli delete zone 29.172.in-addr.arpa -c -q

$ ndcli delete container 172.16.0.0/12
INFO - Deleting container 172.16.0.0/12 from layer3domain default
$ ndcli delete zone-profile internal

