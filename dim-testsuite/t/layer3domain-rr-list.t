$ ndcli create layer3domain two type vrf rd 0:2
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a.de. a 10.0.0.1 layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain default as static
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.de. a 10.0.0.1 layer3domain two --allow-overlap
WARNING - 10.0.0.1 in layer3domain two overlaps with 10.0.0.1 in layer3domain default
INFO - Marked IP 10.0.0.1 from layer3domain two as static
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ A 10.0.0.1 in zone a.de
INFO - No zone found for 1.0.0.10.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.
$ ndcli create rr a.de. txt "text here"
INFO - Creating RR @ TXT "text here" in zone a.de

$ ndcli list zone a.de
record zone ttl   type value                                                          layer3domain
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2017092004 14400 3600 605000 86400
@      a.de       A    10.0.0.1                                                        default
@      a.de       A    10.0.0.1                                                        two
@      a.de       TXT  "text here"
$ ndcli list zone a.de
record zone ttl   type value                                                          layer3domain
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2021041404 14400 3600 605000 86400
@      a.de       A    10.0.0.1                                                       default
@      a.de       A    10.0.0.1                                                       two
@      a.de       TXT  "text here"

$ ndcli list rrs *a.de
INFO - Result for list rrs *a.de
record zone view    ttl   type value                                                          layer3domain
@      a.de default 86400 SOA  localhost. hostmaster.a.de. 2017092004 14400 3600 605000 86400
@      a.de default       A    10.0.0.1                                                        default
@      a.de default       A    10.0.0.1                                                        two
@      a.de default       TXT  "text here"
$ ndcli list rrs 10.0.0.1
INFO - Result for list rrs 10.0.0.1
record zone view    ttl type value   layer3domain
@      a.de default     A    10.0.0.1 default
@      a.de default     A    10.0.0.1 two
$ ndcli list rrs 10.0.0.1 layer3domain two
INFO - Result for list rrs 10.0.0.1
record zone view    ttl type value
@      a.de default     A    10.0.0.1
$ ndcli list zone a.de layer3domain two
record zone ttl type value
@      a.de     A    10.0.0.1

$ ndcli delete zone a.de -c
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Freeing IP 10.0.0.1 from layer3domain default
INFO - Deleting RR @ A 10.0.0.1 from zone a.de
INFO - Freeing IP 10.0.0.1 from layer3domain two
INFO - Deleting RR @ TXT "text here" from zone a.de
