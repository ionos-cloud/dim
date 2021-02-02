$ cat <<EOF | ndcli import zone 0.ms
; <<>> DiG 9.6-ESV-R7-P3 <<>> axfr 0.ms @nspa-de-kae-bs01.internal.test
;; global options: +cmd
0.ms.			3600	IN	SOA	ns-com.company.de. dnsadmin.company.com. 2011021429 28800 7200 604800 3600
0.ms.			3600	IN	NS	ns04.company.biz.
0.ms.			3600	IN	RP	dnsadmin.example.com. dnsfe.system.
0.ms.			3600	IN	SOA	ns-com.company.de. dnsadmin.company.com. 2011021429 28800 7200 604800 3600
;; Query time: 3 msec
;; SERVER: 172.20.38.46#53(172.20.38.46)
;; WHEN: Thu May  2 15:43:37 2013
;; XFR size: 14 records (messages 3, bytes 568)
EOF
INFO - Creating zone 0.ms
RECORD - 0.ms. 3600 IN SOA ns-com.company.de. dnsadmin.company.com. 2011021429 28800 7200 604800 3600
INFO - Creating RR @ SOA ns-com.company.de. dnsadmin.company.com. 2011021429 28800 7200 604800 3600 in zone 0.ms
RECORD - 0.ms. 3600 IN NS ns04.company.biz.
INFO - Creating RR @ NS ns04.company.biz. in zone 0.ms
WARNING - ns04.company.biz. does not exist.
RECORD - 0.ms. 3600 IN RP dnsadmin.example.com. dnsfe.system.
WARNING - TXT Record dnsfe.system. not found
INFO - Creating RR @ RP dnsadmin.example.com. dnsfe.system. in zone 0.ms

$ ndcli list zone 0.ms
record zone ttl  type value
@      0.ms 3600 SOA  ns-com.company.de. dnsadmin.company.com. 2011021431 28800 7200 604800 3600
@      0.ms      NS   ns04.company.biz.
@      0.ms      RP   dnsadmin.example.com. dnsfe.system.

$ ndcli delete zone 0.ms --cleanup
INFO - Deleting RR @ NS ns04.company.biz. from zone 0.ms
INFO - Deleting RR @ RP dnsadmin.example.com. dnsfe.system. from zone 0.ms
