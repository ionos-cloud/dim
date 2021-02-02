$ ndcli create zone-profile rev-public primary rns.company.com. mail dnsadmin@example.com
$ ndcli modify zone-profile rev-public create rr @ ns rns.company.com.
INFO - Creating RR @ NS rns.company.com. in zone profile rev-public
WARNING - rns.company.com. does not exist.

$ ndcli modify zone-profile rev-public create rr @ ns rns.company.org.
WARNING - The name rev-public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.org. in zone profile rev-public
WARNING - rns.company.org. does not exist.

$ ndcli modify zone-profile rev-public create rr @ ns rns.company.biz.
WARNING - The name rev-public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.biz. in zone profile rev-public
WARNING - rns.company.biz. does not exist.

$ ndcli modify zone-profile rev-public create rr @ ns rns.company.de.
WARNING - The name rev-public. already existed, creating round robin record
INFO - Creating RR @ NS rns.company.de. in zone profile rev-public
WARNING - rns.company.de. does not exist.

$ ndcli create container 74.208.0.0/16
INFO - Creating container 74.208.0.0/16 in layer3domain default
$ ndcli modify container 74.208.0.0/16 set attrs reverse_dns_profile:rev-public

# rfc2317 example
# 
# ok, this is also the first use of ndcli modify zone <foo> [create|delete] rr <some rr spec>
# I don't think there is another way to handle these overlapping records

$ ndcli create pool rfc2317
$ ndcli modify pool rfc2317 add subnet 74.208.6.128/26
INFO - Created subnet 74.208.6.128/26 in layer3domain default
INFO - Creating zone 6.208.74.in-addr.arpa with profile rev-public

$ ndcli create zone 128/26.6.208.74.in-addr.arpa
WARNING - Creating zone 128/26.6.208.74.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone 128/26.6.208.74.in-addr.arpa
$ ndcli modify zone 128/26.6.208.74.in-addr.arpa create rr @ ns ns.other.host.
INFO - Creating RR @ NS ns.other.host. in zone 128/26.6.208.74.in-addr.arpa
WARNING - ns.other.host. does not exist.
$ ndcli modify zone 128/26.6.208.74.in-addr.arpa create rr 129 ptr some.host.
INFO - Marked IP 74.208.6.129 from layer3domain default as static
INFO - Creating RR 129 PTR some.host. in zone 128/26.6.208.74.in-addr.arpa

$ ndcli modify zone 6.208.74.in-addr.arpa create rr 128/26 ns ns.other.host.
INFO - Creating RR 128/26 NS ns.other.host. in zone 6.208.74.in-addr.arpa
WARNING - ns.other.host. does not exist.

$ ndcli create rr 129.6.208.74.in-addr.arpa. cname 129.128/26.6.208.74.in-addr.arpa.
INFO - Creating RR 129 CNAME 129.128/26.6.208.74.in-addr.arpa. in zone 6.208.74.in-addr.arpa

$ ndcli list zone 6.208.74.in-addr.arpa
record zone                  ttl   type  value
@      6.208.74.in-addr.arpa 86400 SOA   rns.company.com. dnsadmin.example.com. 2012122801 14400 3600 605000 86400
@      6.208.74.in-addr.arpa       NS    rns.company.com.
@      6.208.74.in-addr.arpa       NS    rns.company.org.
@      6.208.74.in-addr.arpa       NS    rns.company.biz.
@      6.208.74.in-addr.arpa       NS    rns.company.de.
128/26 6.208.74.in-addr.arpa       NS    ns.other.host.
129    6.208.74.in-addr.arpa       CNAME 129.128/26.6.208.74.in-addr.arpa.

$ ndcli list zone  128/26.6.208.74.in-addr.arpa
record zone                         ttl   type value
@      128/26.6.208.74.in-addr.arpa 86400 SOA  localhost. hostmaster.128/26.6.208.74.in-addr.arpa. 2012122801 14400 3600 605000 86400
@      128/26.6.208.74.in-addr.arpa       NS   ns.other.host.
129    128/26.6.208.74.in-addr.arpa       PTR  some.host.

$ ndcli delete zone 128/26.6.208.74.in-addr.arpa -q --cleanup
$ ndcli delete zone 6.208.74.in-addr.arpa -q --cleanup

$ ndcli modify pool rfc2317 remove subnet 74.208.6.128/26
$ ndcli delete pool rfc2317

$ ndcli delete container 74.208.0.0/16
INFO - Deleting container 74.208.0.0/16 from layer3domain default
