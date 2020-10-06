$ ndcli create zone-profile brand1-public primary ns-brand1.company.com.
$ ndcli modify zone-profile brand1-public create rr @ ns ns-brand1.company.com.
INFO - Creating RR @ NS ns-brand1.company.com. in zone profile brand1-public
WARNING - ns-brand1.company.com. does not exist.
$ ndcli modify zone-profile brand1-public create rr @ ns ns-brand1.company.org.
WARNING - The name brand1-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-brand1.company.org. in zone profile brand1-public
WARNING - ns-brand1.company.org. does not exist.
$ ndcli create zone 208.74.in-addr.arpa profile brand1-public
INFO - Creating zone 208.74.in-addr.arpa with profile brand1-public
$ ndcli create zone 8.b.d.0.1.0.0.2.ip6.arpa profile brand1-public
INFO - Creating zone 8.b.d.0.1.0.0.2.ip6.arpa with profile brand1-public
$ ndcli modify zone 208.74.in-addr.arpa create view m
ERROR - No layer3domain named m
$ ndcli modify zone 8.b.d.0.1.0.0.2.ip6.arpa create view n
ERROR - No layer3domain named n
$ ndcli delete zone 208.74.in-addr.arpa --cleanup
INFO - Deleting RR @ NS ns-brand1.company.com. from zone 208.74.in-addr.arpa
INFO - Deleting RR @ NS ns-brand1.company.org. from zone 208.74.in-addr.arpa
$ ndcli delete zone 8.b.d.0.1.0.0.2.ip6.arpa --cleanup
INFO - Deleting RR @ NS ns-brand1.company.com. from zone 8.b.d.0.1.0.0.2.ip6.arpa
INFO - Deleting RR @ NS ns-brand1.company.org. from zone 8.b.d.0.1.0.0.2.ip6.arpa
$ ndcli delete zone-profile brand1-public
