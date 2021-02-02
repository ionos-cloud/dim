$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool apool
$ ndcli modify pool apool add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone a.de mail hostmaster@a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.a.de. a 1.2.3.4 -q
$ ndcli create rr a.a.de. a 1.2.3.7 
INFO - Marked IP 1.2.3.7 from layer3domain default as static
WARNING - The name a.a.de. already existed, creating round robin record
INFO - Creating RR a A 1.2.3.7 in zone a.de
INFO - Creating RR 7 PTR a.a.de. in zone 3.2.1.in-addr.arpa
$ ndcli create rr a.a.de. aaaa 2001:db8:400:12::25:1 -q
$ ndcli create rr a.a.de. aaaa 2001:db8:400:12::25:2
INFO - Marked IP 2001:db8:400:12::25:2 from layer3domain default as static
INFO - No zone found for 2.0.0.0.5.2.0.0.0.0.0.0.0.0.0.0.2.1.0.0.0.0.4.0.8.b.d.0.1.0.0.2.ip6.arpa.
INFO - Creating RR a AAAA 2001:db8:400:12::25:2 in zone a.de
WARNING - No reverse zone found. Only creating forward entry.
WARNING - The name a.a.de. already existed, creating round robin record
$ ndcli create rr mail.a.de. cname a -q
$ ndcli create rr mx.a.de. a 1.2.3.5 -q
$ ndcli create rr mx-v6.a.de. aaaa 2001:db8:400:12::25:3 -q
$ ndcli create rr a.de. mx 10 mail -q
ERROR - The target of MX records must have A or AAAA resource records
$ ndcli create rr a.de. mx 10 mx -q
$ ndcli create rr a.de. mx 10 mx-v6 -q
$ ndcli create rr a.de. mx 20 a.a.de. -q
$ ndcli create rr rootserver.a.de. mx 10 mx00.example.com. -q
$ ndcli list zone a.de
record     zone ttl   type  value
@          a.de 86400 SOA   localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
a          a.de       A     1.2.3.4
a          a.de       A     1.2.3.7
a          a.de       AAAA  2001:db8:400:12::25:1
a          a.de       AAAA  2001:db8:400:12::25:2
mail       a.de       CNAME a
mx         a.de       A     1.2.3.5
mx-v6      a.de       AAAA  2001:db8:400:12::25:3
@          a.de       MX    10 mx
@          a.de       MX    10 mx-v6
@          a.de       MX    20 a.a.de.
rootserver a.de       MX    10 mx00.example.com.
# rfc1035 states "PREFERENCE A 16 bit integer....." it does not say explicitly signed or unsigned
# for our use i specify min value 1 max value 2^15-1
$ ndcli create rr m.a.de. mx 0 mx
ERROR - Preference min 1 max 32767
$ ndcli create rr m.a.de. mx 32768 mx
ERROR - Preference min 1 max 32767

$ ndcli delete zone a.de --cleanup
INFO - Deleting RR 7 PTR a.a.de. from zone 3.2.1.in-addr.arpa
INFO - Deleting RR @ MX 20 a.a.de. from zone a.de
INFO - Deleting RR mx A 1.2.3.5 from zone a.de
INFO - Deleting RR 4 PTR a.a.de. from zone 3.2.1.in-addr.arpa
INFO - Deleting RR a AAAA 2001:db8:400:12::25:1 from zone a.de
INFO - Deleting RR 5 PTR mx.a.de. from zone 3.2.1.in-addr.arpa
INFO - Freeing IP 1.2.3.4 from layer3domain default
INFO - Deleting RR rootserver MX 10 mx00.example.com. from zone a.de
INFO - Deleting RR mx-v6 AAAA 2001:db8:400:12::25:3 from zone a.de
INFO - Freeing IP 1.2.3.7 from layer3domain default
INFO - Deleting RR a A 1.2.3.7 from zone a.de
INFO - Freeing IP 2001:db8:400:12::25:1 from layer3domain default
INFO - Deleting RR mail CNAME a from zone a.de
INFO - Freeing IP 2001:db8:400:12::25:2 from layer3domain default
INFO - Deleting RR @ MX 10 mx from zone a.de
INFO - Deleting RR a A 1.2.3.4 from zone a.de
INFO - Freeing IP 1.2.3.5 from layer3domain default
INFO - Deleting RR @ MX 10 mx-v6 from zone a.de
INFO - Freeing IP 2001:db8:400:12::25:3 from layer3domain default
INFO - Deleting RR a AAAA 2001:db8:400:12::25:2 from zone a.de
$ ndcli delete zone 3.2.1.in-addr.arpa --cleanup
$ ndcli modify pool apool remove subnet 1.2.3.0/24
$ ndcli delete pool apool
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
