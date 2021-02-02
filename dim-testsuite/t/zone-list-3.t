$ ndcli create zone 0/25.2.0.192.in-addr.arpa
WARNING - Creating zone 0/25.2.0.192.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr 1.0/25.2.0.192.in-addr.arpa.  PTR my.self.managed.rev.zone.
INFO - Marked IP 192.0.2.1 from layer3domain default as static
INFO - Creating RR 1 PTR my.self.managed.rev.zone. in zone 0/25.2.0.192.in-addr.arpa
INFO - No zone found for my.self.managed.rev.zone.
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr 0/25.2.0.192.in-addr.arpa.  NS ns.A.domain.
INFO - Creating RR @ NS ns.a.domain. in zone 0/25.2.0.192.in-addr.arpa
WARNING - ns.a.domain. does not exist.
$ ndcli create rr 0/25.2.0.192.in-addr.arpa.  NS  some.other.name.server.
WARNING - The name 0/25.2.0.192.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR @ NS some.other.name.server. in zone 0/25.2.0.192.in-addr.arpa
WARNING - some.other.name.server. does not exist.
$ ndcli list zone 0/25.2.0.192.in-addr.arpa
record zone                      ttl   type value
     @ 0/25.2.0.192.in-addr.arpa 86400 SOA  localhost. hostmaster.0/25.2.0.192.in-addr.arpa. 2017072604 14400 3600 605000 86400
     @ 0/25.2.0.192.in-addr.arpa       NS   ns.a.domain.
     @ 0/25.2.0.192.in-addr.arpa       NS   some.other.name.server.
     1 0/25.2.0.192.in-addr.arpa       PTR  my.self.managed.rev.zone.
