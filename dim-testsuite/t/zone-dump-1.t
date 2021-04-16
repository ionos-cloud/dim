$ ndcli create zone some.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone some.domain without profile
$ ndcli create rr some.domain. ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone some.domain
WARNING - ins01.internal.test. does not exist.
$ ndcli create rr www.some.domain. a 192.168.78.2
INFO - Marked IP 192.168.78.2 from layer3domain default as static
INFO - Creating RR www A 192.168.78.2 in zone some.domain
INFO - No zone found for 2.78.168.192.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr some.domain. ttl 1200 mx 10 mail.other.domain.
INFO - Creating RR @ 1200 MX 10 mail.other.domain. in zone some.domain
WARNING - mail.other.domain. does not exist.
$ ndcli create rr my.some.domain. cname www
INFO - Creating RR my CNAME www in zone some.domain
$ ndcli create rr this.some.domain. cname www.some.domain.
INFO - Creating RR this CNAME www.some.domain. in zone some.domain
$ ndcli dump zone some.domain
some.domain.	86400	IN	SOA	ins01.internal.test. dnsadmin.company.com. 2012010105 28800 7200 604800 3600
my.some.domain.	86400	IN	CNAME	www.some.domain.
some.domain.	86400	IN	NS	ins01.internal.test.
some.domain.	1200	IN	MX	10 mail.other.domain.
this.some.domain.	86400	IN	CNAME	www.some.domain.
www.some.domain.	86400	IN	A	192.168.78.2
$ ndcli delete zone some.domain --cleanup
INFO - Deleting RR @ NS ins01.internal.test. from zone some.domain
INFO - Deleting RR @ 1200 MX 10 mail.other.domain. from zone some.domain
INFO - Deleting RR my CNAME www from zone some.domain
INFO - Deleting RR this CNAME www.some.domain. from zone some.domain
INFO - Deleting RR www A 192.168.78.2 from zone some.domain
INFO - Freeing IP 192.168.78.2 from layer3domain default
