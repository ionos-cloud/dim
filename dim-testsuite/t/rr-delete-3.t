# ndcli delete rr <name> <typ> [<value>] [[[-R|--recursive]|--force] [--keep-ip-reservation]|[-n]]
# Delete records referenced from more than one view or test
# All cross test recursive deletes are allowed.

$ ndcli create container 2001:db8::/32 source:rfc3849
INFO - Creating container 2001:db8::/32 in layer3domain default
$ ndcli create container 10.0.0.0/8 source:rfc1918
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool tp_v6 vlan 12
$ ndcli modify pool tp_v6 add subnet 2001:db8:be:ef::/64 gw 2001:db8:be:ef::1
INFO - Created subnet 2001:db8:be:ef::/64 in layer3domain default
WARNING - Creating zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create pool tp vlan 12
$ ndcli modify pool tp add subnet 10.1.2.0/24 gw 10.1.2.1
INFO - Created subnet 10.1.2.0/24 in layer3domain default
WARNING - Creating zone 2.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone one.test
WARNING - Creating zone one.test without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone two.test
WARNING - Creating zone two.test without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr mail.one.test. a 10.1.2.25
INFO - Marked IP 10.1.2.25 from layer3domain default as static
INFO - Creating RR mail A 10.1.2.25 in zone one.test
INFO - Creating RR 25 PTR mail.one.test. in zone 2.1.10.in-addr.arpa

$ ndcli create rr mail.one.test. aaaa 2001:db8:be:ef::25:1
INFO - Marked IP 2001:db8:be:ef::25:1 from layer3domain default as static
INFO - Creating RR mail AAAA 2001:db8:be:ef::25:1 in zone one.test
INFO - Creating RR 1.0.0.0.5.2.0.0.0.0.0.0.0.0.0.0 PTR mail.one.test. in zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa

$ ndcli create rr pop.one.test. cname mail
INFO - Creating RR pop CNAME mail in zone one.test
$ ndcli create rr pop-old.one.test. cname pop
INFO - Creating RR pop-old CNAME pop in zone one.test
$ ndcli delete rr pop.one.test.
ERROR - pop.one.test. is referenced by other records
$ ndcli delete rr pop.one.test. -R
INFO - Deleting RR pop-old CNAME pop from zone one.test
INFO - Deleting RR pop CNAME mail from zone one.test

$ ndcli create rr imap.one.test. cname mail
INFO - Creating RR imap CNAME mail in zone one.test
$ ndcli create rr one.test. mx 10 mail.one.test.
INFO - Creating RR @ MX 10 mail.one.test. in zone one.test

$ ndcli delete rr mail.one.test. aaaa 2001:db8:be:ef::25:1
INFO - Deleting RR mail AAAA 2001:db8:be:ef::25:1 from zone one.test
INFO - Deleting RR 1.0.0.0.5.2.0.0.0.0.0.0.0.0.0.0 PTR mail.one.test. from zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:be:ef::25:1 from layer3domain default

$ ndcli delete rr mail.one.test. -R
INFO - Deleting RR mail A 10.1.2.25 from zone one.test
INFO - Deleting RR imap CNAME mail from zone one.test
INFO - Deleting RR @ MX 10 mail.one.test. from zone one.test
INFO - Deleting RR 25 PTR mail.one.test. from zone 2.1.10.in-addr.arpa
INFO - Freeing IP 10.1.2.25 from layer3domain default

$ ndcli create rr mail-ng.one.test. a 10.1.2.26
INFO - Marked IP 10.1.2.26 from layer3domain default as static
INFO - Creating RR mail-ng A 10.1.2.26 in zone one.test
INFO - Creating RR 26 PTR mail-ng.one.test. in zone 2.1.10.in-addr.arpa

$ ndcli create rr mail-ng.one.test. aaaa 2001:db8:be:ef::25:2
INFO - Marked IP 2001:db8:be:ef::25:2 from layer3domain default as static
INFO - Creating RR mail-ng AAAA 2001:db8:be:ef::25:2 in zone one.test
INFO - Creating RR 2.0.0.0.5.2.0.0.0.0.0.0.0.0.0.0 PTR mail-ng.one.test. in zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa

$ ndcli create rr pop3.one.test. cname mail-ng.one.test.
INFO - Creating RR pop3 CNAME mail-ng.one.test. in zone one.test

$ ndcli create rr pop3.two.test. cname pop3.one.test.
INFO - Creating RR pop3 CNAME pop3.one.test. in zone two.test

$ ndcli create rr imap4.two.test. cname mail-ng.one.test.
INFO - Creating RR imap4 CNAME mail-ng.one.test. in zone two.test

$ ndcli create rr two.test. mx 10 mail-ng.one.test.
INFO - Creating RR @ MX 10 mail-ng.one.test. in zone two.test

$ ndcli delete rr mail-ng.one.test. aaaa 2001:db8:be:ef::25:2
INFO - Deleting RR mail-ng AAAA 2001:db8:be:ef::25:2 from zone one.test
INFO - Deleting RR 2.0.0.0.5.2.0.0.0.0.0.0.0.0.0.0 PTR mail-ng.one.test. from zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
INFO - Freeing IP 2001:db8:be:ef::25:2 from layer3domain default

$ ndcli delete rr mail-ng.one.test. a 10.1.2.26 -R
INFO - Deleting RR mail-ng A 10.1.2.26 from zone one.test
INFO - Deleting RR imap4 CNAME mail-ng.one.test. from zone two.test
INFO - Deleting RR pop3 CNAME mail-ng.one.test. from zone one.test
INFO - Deleting RR pop3 CNAME pop3.one.test. from zone two.test
INFO - Deleting RR @ MX 10 mail-ng.one.test. from zone two.test
INFO - Deleting RR 26 PTR mail-ng.one.test. from zone 2.1.10.in-addr.arpa
INFO - Freeing IP 10.1.2.26 from layer3domain default

$ ndcli delete zone two.test --cleanup -q
$ ndcli delete zone one.test --cleanup -q

$ ndcli modify pool tp_v6 remove subnet 2001:db8:be:ef::/64
INFO - Deleting zone f.e.0.0.e.b.0.0.8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli delete pool tp_v6
$ ndcli modify pool tp remove subnet 10.1.2.0/24
INFO - Deleting zone 2.1.10.in-addr.arpa
$ ndcli delete pool tp

$ ndcli delete container 2001:db8::/32
INFO - Deleting container 2001:db8::/32 from layer3domain default
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
