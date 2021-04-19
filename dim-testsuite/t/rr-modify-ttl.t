# To be able to modify the comment of RR,
# ndcli modify rr is introduced

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr www.a.de. a 172.19.2.251
INFO - Marked IP 172.19.2.251 from layer3domain default as static
INFO - Creating RR www A 172.19.2.251 in zone a.de
INFO - No zone found for 251.2.19.172.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli list rrs 172.19.2.251
INFO - Result for list rrs 172.19.2.251
record zone view    ttl type value
www    a.de default     A    172.19.2.251

$ ndcli modify rr www.a.de. a 172.19.2.251 --ttl 600
$ ndcli list rrs 172.19.2.251
INFO - Result for list rrs 172.19.2.251
record zone view    ttl type value
www    a.de default 600 A    172.19.2.251

$ ndcli modify rr www.a.de. a 172.19.2.251 --ttl default
$ ndcli list rrs 172.19.2.251
INFO - Result for list rrs 172.19.2.251
record zone view    ttl type value
www    a.de default     A    172.19.2.251

$ ndcli modify rr www.a.de. a 172.19.2.251 --ttl invalid
ERROR - Invalid ttl: invalid

$ ndcli delete zone a.de -q --cleanup

