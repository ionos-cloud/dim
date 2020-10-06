$ ndcli create zone-profile internal "comment:Profile for all internal Zones"
$ ndcli modify zone-profile internal set primary ins01.internal.test.
$ ndcli modify zone-profile internal set mail dnsadmin@company.com
$ ndcli modify zone-profile internal create rr @ ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ ns ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.
$ ndcli modify zone-profile internal delete rr @ ns ins02.internal.test.
INFO - Deleting RR @ NS ins02.internal.test. from zone profile internal
$ ndcli modify zone-profile internal create rr @ mx 10 mintern00.example.com.
INFO - Creating RR @ MX 10 mintern00.example.com. in zone profile internal
WARNING - mintern00.example.com. does not exist.
$ ndcli modify zone-profile internal create rr @ mx 10 mintern01.example.com.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ MX 10 mintern01.example.com. in zone profile internal
WARNING - mintern01.example.com. does not exist.
$ ndcli modify zone-profile internal delete rr @ mx 10 mintern01.example.com.
INFO - Deleting RR @ MX 10 mintern01.example.com. from zone profile internal
$ ndcli modify zone-profile internal create rr w3 cname www
INFO - Creating RR w3 CNAME www in zone profile internal
WARNING - www.internal. does not exist.
$ ndcli modify zone-profile internal create rr @ cname www.other.domain.
ERROR - It is not allowed to create a CNAME for a zone
$ ndcli modify zone-profile internal create rr www a 172.19.0.2
INFO - Marked IP 172.19.0.2 from layer3domain default as static
INFO - Creating RR www A 172.19.0.2 in zone profile internal
$ ndcli modify zone-profile internal create rr @ a 172.19.0.2
INFO - Creating RR @ A 172.19.0.2 in zone profile internal
$ ndcli modify zone-profile internal create rr www.a.zone a 172.19.0.2
WARNING - The left hand side of this record contains '.'. This will probably not do what you expect it to do.
INFO - Creating RR www.a.zone A 172.19.0.2 in zone profile internal
$ ndcli modify zone-profile internal create rr www.a.zone. a 172.19.0.2
ERROR - RR name www.a.zone. not in zone internal
$ ndcli modify zone-profile internal set attrs foo:bar
$ ndcli create zone-profile public-brand1 "comment:Profile for public Domains related to the 2 brand"
$ ndcli create zone-profile public-brand2 "comment:Profile for public Domains related to the G brand"
$ ndcli create zone-profile public-brand3 "comment:Profile for public Domains related to the w brand"
$ ndcli modify zone-profile public-brand2 set attrs eol:31.12.2020
$ ndcli list zone-profiles
name
internal
public-brand1
public-brand2
public-brand3
$ ndcli list zone-profiles -H
internal
public-brand1
public-brand2
public-brand3
$ ndcli show zone-profile internal
name:internal
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
comment:Profile for all internal Zones
foo:bar
$ ndcli list zone-profile internal
record     ttl   type value
@          86400 SOA  ins01.internal.test. dnsadmin.company.com. 2012102610 14400 3600 605000 86400
@                NS   ins01.internal.test.
@                MX   10 mintern00.example.com.
@                A    172.19.0.2
w3               CNAME www
www.a.zone       A    172.19.0.2
www              A    172.19.0.2
$ ndcli list zone-profile internal -H
@	86400	SOA	ins01.internal.test. dnsadmin.company.com. 2012102610 14400 3600 605000 86400
@		NS	ins01.internal.test.
@		MX	10 mintern00.example.com.
@		A	172.19.0.2
w3		CNAME	www
www.a.zone		A	172.19.0.2
www		A	172.19.0.2
$ ndcli delete zone-profile internal
$ ndcli delete zone-profile public-brand1
$ ndcli delete zone-profile public-brand2
$ ndcli delete zone-profile public-brand3
