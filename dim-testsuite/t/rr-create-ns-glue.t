$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create zone-profile internal primary ins01.internal.zone. mail dnsadmin@example.net
$ ndcli create zone-profile internal primary ins01.internal.zone. mail dnsadmin@example.net
ERROR - Zone profile internal already exists
$ ndcli modify zone-profile internal create rr @ ns ins01.internal.zone.
INFO - Creating RR @ NS ins01.internal.zone. in zone profile internal
WARNING - ins01.internal.zone. does not exist.
$ ndcli modify zone-profile internal create rr @ NS ins02.internal.zone.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.zone. in zone profile internal
WARNING - ins02.internal.zone. does not exist.

$ ndcli create container 10.46.104.0/24 "usage: VDS"
INFO - Creating container 10.46.104.0/24 in layer3domain default
$ ndcli create zone 10.in-addr.arpa profile internal
INFO - Creating zone 10.in-addr.arpa with profile internal
$ ndcli create zone 46.10.in-addr.arpa profile internal
INFO - Creating zone 46.10.in-addr.arpa with profile internal
INFO - Creating views default for zone 46.10.in-addr.arpa
INFO - Creating RR 46 NS ins01.internal.zone. in zone 10.in-addr.arpa
WARNING - ins01.internal.zone. does not exist.
WARNING - The name 46.10.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 46 NS ins02.internal.zone. in zone 10.in-addr.arpa
WARNING - ins02.internal.zone. does not exist.

$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone example.com create view internal profile internal

$ ndcli modify zone example.com rename view default to public

$ ndcli create rr app01.bas.example.com. a 10.46.104.20 view internal
INFO - Marked IP 10.46.104.20 from layer3domain default as static
INFO - Creating RR app01.bas A 10.46.104.20 in zone example.com view internal
INFO - Creating RR 20.104 PTR app01.bas.example.com. in zone 46.10.in-addr.arpa
$ ndcli create rr app02.bas.example.com. a 10.46.104.80 view internal
INFO - Marked IP 10.46.104.80 from layer3domain default as static
INFO - Creating RR app02.bas A 10.46.104.80 in zone example.com view internal
INFO - Creating RR 80.104 PTR app02.bas.example.com. in zone 46.10.in-addr.arpa

$ ndcli create rr bas.example.com. ns app01.bas.example.com. view internal
INFO - Creating RR bas NS app01.bas.example.com. in zone example.com view internal
$ ndcli create rr bas.example.com. ns app02.bas.example.com. view internal
WARNING - The name bas.example.com. already existed, creating round robin record
INFO - Creating RR bas NS app02.bas.example.com. in zone example.com view internal

$ ndcli create rr 104.46.10.in-addr.arpa. ns app01.bas.example.com.
INFO - Creating RR 104 NS app01.bas.example.com. in zone 46.10.in-addr.arpa
$ ndcli create rr 104.46.10.in-addr.arpa. ns app02.bas.example.com.
WARNING - The name 104.46.10.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR 104 NS app02.bas.example.com. in zone 46.10.in-addr.arpa

$ ndcli list zone example.com view internal
record    zone        ttl   type value
@         example.com 86400 SOA  ins01.internal.zone. dnsadmin.example.net. 2012121103 14400 3600 605000 86400
@         example.com       NS   ins01.internal.zone.
@         example.com       NS   ins02.internal.zone.
app01.bas example.com       A    10.46.104.20
app02.bas example.com       A    10.46.104.80
bas       example.com       NS   app01.bas.example.com.
bas       example.com       NS   app02.bas.example.com.

$ ndcli list zone 46.10.in-addr.arpa
record zone               ttl   type value
@      46.10.in-addr.arpa 86400 SOA  ins01.internal.zone. dnsadmin.example.net. 2012121103 14400 3600 605000 86400
@      46.10.in-addr.arpa       NS   ins01.internal.zone.
@      46.10.in-addr.arpa       NS   ins02.internal.zone.
104    46.10.in-addr.arpa       NS   app01.bas.example.com.
104    46.10.in-addr.arpa       NS   app02.bas.example.com.
20.104 46.10.in-addr.arpa       PTR  app01.bas.example.com.
80.104 46.10.in-addr.arpa       PTR  app02.bas.example.com.
$ ndcli modify zone example.com delete view public --cleanup -q
$ ndcli delete zone example.com --cleanup -q

$ ndcli delete zone 10.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ins01.internal.zone. from zone 10.in-addr.arpa
INFO - Deleting RR @ NS ins02.internal.zone. from zone 10.in-addr.arpa
INFO - Deleting RR 46 NS ins01.internal.zone. from zone 10.in-addr.arpa
INFO - Deleting RR 46 NS ins02.internal.zone. from zone 10.in-addr.arpa

$ ndcli delete zone 46.10.in-addr.arpa --cleanup -q
$ ndcli delete container 10.46.104.0/24
INFO - Deleting container 10.46.104.0/24 from layer3domain default
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
$ ndcli delete zone-profile internal
