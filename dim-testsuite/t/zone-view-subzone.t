$ ndcli create zone-profile brand-public primary ns-brand.company.com.
$ ndcli modify zone-profile brand-public create rr @ ns ns-brand.company.com.
INFO - Creating RR @ NS ns-brand.company.com. in zone profile brand-public
WARNING - ns-brand.company.com. does not exist.
$ ndcli modify zone-profile brand-public create rr @ ns ns-brand.company.org.
WARNING - The name brand-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-brand.company.org. in zone profile brand-public
WARNING - ns-brand.company.org. does not exist.
$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@example.com
$ ndcli modify zone-profile internal create rr @ ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ ns ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.
$ ndcli create zone brand.com profile brand-public
INFO - Creating zone brand.com with profile brand-public
$ ndcli modify zone brand.com create view us
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone brand.com rename view default to eu
$ ndcli create rr foo.v300.brand.com. a 1.2.3.4 view us
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR foo.v300 A 1.2.3.4 in zone brand.com view us
INFO - No zone found for 4.3.2.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create zone v300.brand.com profile internal
INFO - Creating zone v300.brand.com with profile internal
INFO - Creating views eu, us for zone v300.brand.com
INFO - Moving RR foo.v300 A 1.2.3.4 in zone v300.brand.com view us from zone brand.com view us
INFO - Creating RR v300 NS ins01.internal.test. in zone brand.com view eu
WARNING - ins01.internal.test. does not exist.
WARNING - The name v300.brand.com. already existed, creating round robin record
INFO - Creating RR v300 NS ins02.internal.test. in zone brand.com view eu
WARNING - ins02.internal.test. does not exist.
INFO - Creating RR v300 NS ins01.internal.test. in zone brand.com view us
WARNING - ins01.internal.test. does not exist.
WARNING - The name v300.brand.com. already existed, creating round robin record
INFO - Creating RR v300 NS ins02.internal.test. in zone brand.com view us
WARNING - ins02.internal.test. does not exist.
$ ndcli list zone v300.brand.com views
name
eu
us
$ ndcli list zone v300.brand.com view eu
record   zone           ttl   type value
@        v300.brand.com 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2012121102 14400 3600 605000 86400
@        v300.brand.com       NS   ins01.internal.test.
@        v300.brand.com       NS   ins02.internal.test.

$ ndcli list zone v300.brand.com view us
record   zone           ttl   type value
@        v300.brand.com 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2012121102 14400 3600 605000 86400
@        v300.brand.com       NS   ins01.internal.test.
@        v300.brand.com       NS   ins02.internal.test.
foo      v300.brand.com       A    1.2.3.4

$ ndcli modify zone brand.com delete view eu --cleanup
INFO - Deleting RR @ NS ns-brand.company.com. from zone brand.com view eu
INFO - Deleting RR @ NS ns-brand.company.org. from zone brand.com view eu
INFO - Deleting RR v300 NS ins01.internal.test. from zone brand.com view eu
INFO - Deleting RR v300 NS ins02.internal.test. from zone brand.com view eu
$ ndcli delete zone brand.com --cleanup
INFO - Deleting RR v300 NS ins01.internal.test. from zone brand.com
INFO - Deleting RR v300 NS ins02.internal.test. from zone brand.com
$ ndcli modify zone v300.brand.com delete view eu --cleanup
INFO - Deleting RR @ NS ins01.internal.test. from zone v300.brand.com view eu
INFO - Deleting RR @ NS ins02.internal.test. from zone v300.brand.com view eu
$ ndcli delete zone v300.brand.com --cleanup
INFO - Deleting RR @ NS ins01.internal.test. from zone v300.brand.com
INFO - Deleting RR @ NS ins02.internal.test. from zone v300.brand.com
INFO - Deleting RR foo A 1.2.3.4 from zone v300.brand.com
INFO - Freeing IP 1.2.3.4 from layer3domain default
$ ndcli delete zone-profile brand-public
$ ndcli delete zone-profile internal
