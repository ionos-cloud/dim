$ ndcli create zone 2.1.10.in-addr.arpa
WARNING - Creating zone 2.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr 256.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR 256 TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr _.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR _ TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr _a.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR _a TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr *.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR * TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr *.2.1.10.in-addr.arpa. txt supi
WARNING - The name *.2.1.10.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR * TXT "supi" in zone 2.1.10.in-addr.arpa
$ ndcli create rr *.2.1.10.in-addr.arpa. txt super
WARNING - The name *.2.1.10.in-addr.arpa. already existed, creating round robin record
INFO - Creating RR * TXT "super" in zone 2.1.10.in-addr.arpa
$ ndcli create rr 1.2.1.10.in-addr.arpa. ptr a.de.
INFO - Marked IP 10.1.2.1 from layer3domain default as static
INFO - Creating RR 1 PTR a.de. in zone 2.1.10.in-addr.arpa
INFO - No zone found for a.de.
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr 3.2.1.10.in-addr.arpa. ptr a.de.
INFO - Marked IP 10.1.2.3 from layer3domain default as static
INFO - Creating RR 3 PTR a.de. in zone 2.1.10.in-addr.arpa
INFO - No zone found for a.de.
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr 255.2.1.10.in-addr.arpa. ptr z.de.
INFO - Marked IP 10.1.2.255 from layer3domain default as static
INFO - Creating RR 255 PTR z.de. in zone 2.1.10.in-addr.arpa
INFO - No zone found for z.de.
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr b.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR b TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr h.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR h TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr hab.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR hab TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli create rr z.2.1.10.in-addr.arpa. txt sup
INFO - Creating RR z TXT "sup" in zone 2.1.10.in-addr.arpa
$ ndcli list zone 2.1.10.in-addr.arpa
record zone                ttl   type value
     @ 2.1.10.in-addr.arpa 86400 SOA  localhost. hostmaster.2.1.10.in-addr.arpa. 2017071714 14400 3600 605000 86400
     _ 2.1.10.in-addr.arpa       TXT  "sup"
    _a 2.1.10.in-addr.arpa       TXT  "sup"
     * 2.1.10.in-addr.arpa       TXT  "sup"
     * 2.1.10.in-addr.arpa       TXT  "super"
     * 2.1.10.in-addr.arpa       TXT  "supi"
     b 2.1.10.in-addr.arpa       TXT  "sup"
     h 2.1.10.in-addr.arpa       TXT  "sup"
   hab 2.1.10.in-addr.arpa       TXT  "sup"
     z 2.1.10.in-addr.arpa       TXT  "sup"
     1 2.1.10.in-addr.arpa       PTR  a.de.
     3 2.1.10.in-addr.arpa       PTR  a.de.
   255 2.1.10.in-addr.arpa       PTR  z.de.
   256 2.1.10.in-addr.arpa       TXT  "sup"
