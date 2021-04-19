$ ndcli create zone some.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone some.domain without profile
$ ndcli create rr www.some.domain. a 192.168.78.2
INFO - Marked IP 192.168.78.2 from layer3domain default as static
INFO - Creating RR www A 192.168.78.2 in zone some.domain
INFO - No zone found for 2.78.168.192.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr some.domain. ttl 1200 mx 10 mail.other.domain.
INFO - Creating RR @ 1200 MX 10 mail.other.domain. in zone some.domain
WARNING - mail.other.domain. does not exist.
$ ndcli list zone some.domain
record zone        ttl   type value
@      some.domain 86400 SOA  ins01.internal.test. dnsadmin.company.com. 2012102603 14400 3600 605000 86400
@      some.domain 1200  MX   10 mail.other.domain.
www    some.domain       A    192.168.78.2
$ ndcli delete zone some.domain --cleanup
INFO - Deleting RR @ 1200 MX 10 mail.other.domain. from zone some.domain
INFO - Deleting RR www A 192.168.78.2 from zone some.domain
INFO - Freeing IP 192.168.78.2 from layer3domain default
