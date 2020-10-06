$ ndcli create zone-profile brand-public primary ns-brand.example.com. mail dnsadmin@company.com
$ ndcli modify zone-profile brand-public create rr @ ns ns-brand.example.com.
INFO - Creating RR @ NS ns-brand.example.com. in zone profile brand-public
WARNING - ns-brand.example.com. does not exist.
$ ndcli create zone brand.com profile brand-public
INFO - Creating zone brand.com with profile brand-public
$ ndcli modify zone brand.com create view us profile brand-public
$ ndcli modify zone brand.com rename view default to eu
$ ndcli create rr www.brand.com. a 217.160.12.18 view eu
INFO - Marked IP 217.160.12.18 from layer3domain default as static
INFO - Creating RR www A 217.160.12.18 in zone brand.com view eu
INFO - No zone found for 18.12.160.217.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.brand.com. a 217.160.12.19 view eu
INFO - Marked IP 217.160.12.19 from layer3domain default as static
INFO - Creating RR a A 217.160.12.19 in zone brand.com view eu
INFO - No zone found for 19.12.160.217.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.brand.com. cname www view us
INFO - Creating RR a CNAME www in zone brand.com view us
WARNING - www.brand.com. does not exist.
$ ndcli list rrs *brand*
record zone    view ttl   type  value
@      brand.com eu         NS    ns-brand.example.com.
@      brand.com eu   86400 SOA   ns-brand.example.com. dnsadmin.company.com. 2012121003 14400 3600 605000 86400
@      brand.com us         NS    ns-brand.example.com.
@      brand.com us   86400 SOA   ns-brand.example.com. dnsadmin.company.com. 2012121002 14400 3600 605000 86400
a      brand.com eu         A     217.160.12.19
a      brand.com us         CNAME www
www    brand.com eu         A     217.160.12.18
INFO - Result for list rrs *brand*
$ ndcli list rrs *brand* NS
record zone    view ttl type value
@      brand.com eu       NS   ns-brand.example.com.
@      brand.com us       NS   ns-brand.example.com.
INFO - Result for list rrs *brand*
$ ndcli modify zone brand.com delete view eu --cleanup
INFO - Deleting RR @ NS ns-brand.example.com. from zone brand.com view eu
INFO - Deleting RR www A 217.160.12.18 from zone brand.com view eu
INFO - Freeing IP 217.160.12.19 from layer3domain default
INFO - Deleting RR a A 217.160.12.19 from zone brand.com view eu
INFO - Freeing IP 217.160.12.18 from layer3domain default
$ ndcli delete zone brand.com --cleanup
INFO - Deleting RR @ NS ns-brand.example.com. from zone brand.com
INFO - Deleting RR a CNAME www from zone brand.com
$ ndcli delete zone-profile brand-public
