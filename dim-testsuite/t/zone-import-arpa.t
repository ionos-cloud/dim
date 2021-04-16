# The real migration will be done by
# - importing reverse Zones (no forward entries will be created)
# - if reverse zone does not exist, create it
# - importing forward Zones
# - if no reverse entry exists, reverse entry is created
# - if reverse zone for reverse entry does not exist, do not create reverse zone, just warn
#
# As you may notice, i'm using two distinct keywords
# - import <some.zone> for importing zone in a newly created zone
# - import-rev-zone for importing records in a pre defined structure. I think
#   we need this feature to sort our legacy rev zones to usable

$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@example.com
$ ndcli modify zone-profile internal create rr @ ns ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ ns ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.

$ ndcli create container 172.16.0.0/12
INFO - Creating container 172.16.0.0/12 in layer3domain default
$ ndcli modify container 172.16.0.0/12 set attrs reverse_dns_profile:internal

$ ndcli create pool dlan
$ ndcli modify pool dlan add subnet 172.20.0.0/21
INFO - Created subnet 172.20.0.0/21 in layer3domain default
INFO - Creating zone 0.20.172.in-addr.arpa with profile internal
INFO - Creating zone 1.20.172.in-addr.arpa with profile internal
INFO - Creating zone 2.20.172.in-addr.arpa with profile internal
INFO - Creating zone 3.20.172.in-addr.arpa with profile internal
INFO - Creating zone 4.20.172.in-addr.arpa with profile internal
INFO - Creating zone 5.20.172.in-addr.arpa with profile internal
INFO - Creating zone 6.20.172.in-addr.arpa with profile internal
INFO - Creating zone 7.20.172.in-addr.arpa with profile internal
$ ndcli modify pool dlan add subnet 172.20.8.0/24
INFO - Created subnet 172.20.8.0/24 in layer3domain default
INFO - Creating zone 8.20.172.in-addr.arpa with profile internal

$ ndcli create zone dlan.legacy.test profile internal
INFO - Creating zone dlan.legacy.test with profile internal

$ cat <<EOF | ndcli import zone dlan.legacy.test
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.10.rc1.el6_3.6 <<>> axfr dlan.legacy.test @anyins-ins-bs01.dlan.legacy.test
;; global options: +cmd
dlan.legacy.test.        3600    IN      SOA     ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600
dlan.legacy.test.        3600    IN      NS      ins01.internal.test.
dlan.legacy.test.        3600    IN      NS      ins02.internal.test.
dlan.legacy.test.        3600    IN      MX      100 mailgate3.dlan.legacy.test.
dlan.legacy.test.        3600    IN      MX      300 mailgate2.dlan.legacy.test.
01212.dlan.legacy.test.  3600    IN      CNAME   edit01.dlan.legacy.test.
01212lb01.dlan.legacy.test. 3600 IN      A       172.20.5.208
42.dlan.legacy.test.     3600    IN      CNAME   42.itbsxen01.dlan.legacy.test.
1021931729._dkimkey.dlan.legacy.test. 300 IN TXT "v=DKIM1\;k=rsa\;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB"
1021931729._domainkey.dlan.legacy.test. 300 IN TXT "v=DKIM1\;k=rsa\;p=MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKqoZPt2VLATJW6g1VjfmKerwwLqIZ4n S9l1dwm0TD+tgwmVcakpd/I7dIxqUMvkxA/xijbYnw1AammKRkH1KHUCAwEAAQ=="
abmadmin.dlan.legacy.test. 3600  IN      CNAME   abmfe01.dlan.legacy.test.
EOF
INFO - Creating zone dlan.legacy.test
ERROR - Zone dlan.legacy.test already exists

$ ndcli delete zone dlan.legacy.test --cleanup -q

$ cat <<EOF | ndcli import rev-zone
$ORIGIN 20.172.in-addr.arpa.
20.172.in-addr.arpa.	3600	IN	SOA	ins01.internal.test. dnsadmin.company.com. 2005099742 21601 7200 604800 3600
22.5.20.172.in-addr.arpa. 3600	IN	PTR	adimgfe01.dlan.legacy.test.
23.5.20.172.in-addr.arpa. 3600	IN	PTR	foo.bar.
1.11.20.172.in-addr.arpa. 300	IN	PTR	v558.gw-distwi.bs.ka.dlan.legacy.test.
EOF
RECORD - 20.172.in-addr.arpa. 3600 IN SOA ins01.internal.test. dnsadmin.company.com. 2005099742 21601 7200 604800 3600
INFO - Nothing to do
RECORD - 22.5.20.172.in-addr.arpa. 3600 IN PTR adimgfe01.dlan.legacy.test.
INFO - Marked IP 172.20.5.22 from layer3domain default as static
INFO - Creating RR 22 PTR adimgfe01.dlan.legacy.test. in zone 5.20.172.in-addr.arpa
RECORD - 23.5.20.172.in-addr.arpa. 3600 IN PTR foo.bar.
INFO - Marked IP 172.20.5.23 from layer3domain default as static
INFO - Creating RR 23 PTR foo.bar. in zone 5.20.172.in-addr.arpa
RECORD - 1.11.20.172.in-addr.arpa. 300 IN PTR v558.gw-distwi.bs.ka.dlan.legacy.test.
INFO - Marked IP 172.20.11.1 from layer3domain default as static
INFO - Creating zone 11.20.172.in-addr.arpa with profile internal
INFO - Creating RR 1 300 PTR v558.gw-distwi.bs.ka.dlan.legacy.test. in zone 11.20.172.in-addr.arpa

# The ns records, of the reverse zones, which were create
# when the zone was created, should survive the import
$ ndcli list zone 11.20.172.in-addr.arpa
record zone                   ttl   type value
@      11.20.172.in-addr.arpa 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2012122705 14400 3600 605000 86400
@      11.20.172.in-addr.arpa       NS   ins01.internal.test.
@      11.20.172.in-addr.arpa       NS   ins02.internal.test.
1      11.20.172.in-addr.arpa 300   PTR  v558.gw-distwi.bs.ka.dlan.legacy.test.

$ ndcli list zone 5.20.172.in-addr.arpa
record zone                  ttl   type value
@      5.20.172.in-addr.arpa 86400 SOA  ins01.internal.test. dnsadmin.example.com. 2012122705 14400 3600 605000 86400
@      5.20.172.in-addr.arpa       NS   ins01.internal.test.
@      5.20.172.in-addr.arpa       NS   ins02.internal.test.
22     5.20.172.in-addr.arpa       PTR  adimgfe01.dlan.legacy.test.
23     5.20.172.in-addr.arpa       PTR  foo.bar.

$ cat <<EOF | ndcli import zone dlan.legacy.test
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.10.rc1.el6_3.6 <<>> axfr dlan.legacy.test @anyins-ins-bs01.dlan.legacy.test
;; global options: +cmd
dlan.legacy.test.        3600    IN      SOA     ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600
dlan.legacy.test.        3600    IN      NS      ins01.internal.test.
dlan.legacy.test.        3600    IN      NS      ins02.internal.test.
dlan.legacy.test.        3600    IN      MX      100 mailgate3.dlan.legacy.test.
dlan.legacy.test.        3600    IN      MX      300 mailgate2.dlan.legacy.test.
01212.dlan.legacy.test.  3600    IN      CNAME   edit01.dlan.legacy.test.
01212lb01.dlan.legacy.test. 3600 IN      A       172.20.5.208
1021931729._dkimkey.dlan.legacy.test. 300 IN TXT "v=DKIM1\;k=rsa\;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB"
01212lb01.dlan.legacy.test. 300 IN TXT "some key=" "some value"
adimgfe01.dlan.legacy.test. 3600 IN      A       172.20.5.22
adimgfe02.dlan.legacy.test. 3600 IN      A       172.20.5.23
adimgfe03.dlan.legacy.test. 3600 IN      A       172.19.22.5
EOF
INFO - Creating zone dlan.legacy.test
RECORD - dlan.legacy.test. 3600 IN SOA ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600
INFO - Creating RR @ SOA ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600 in zone dlan.legacy.test
RECORD - dlan.legacy.test. 3600 IN NS ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone dlan.legacy.test
WARNING - ins01.internal.test. does not exist.
RECORD - dlan.legacy.test. 3600 IN NS ins02.internal.test.
WARNING - The name dlan.legacy.test. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone dlan.legacy.test
WARNING - ins02.internal.test. does not exist.
RECORD - dlan.legacy.test. 3600 IN MX 100 mailgate3.dlan.legacy.test.
INFO - Creating RR @ MX 100 mailgate3.dlan.legacy.test. in zone dlan.legacy.test
WARNING - mailgate3.dlan.legacy.test. does not exist.
RECORD - dlan.legacy.test. 3600 IN MX 300 mailgate2.dlan.legacy.test.
WARNING - The name dlan.legacy.test. already existed, creating round robin record
INFO - Creating RR @ MX 300 mailgate2.dlan.legacy.test. in zone dlan.legacy.test
WARNING - mailgate2.dlan.legacy.test. does not exist.
RECORD - 01212.dlan.legacy.test. 3600 IN CNAME edit01.dlan.legacy.test.
INFO - Creating RR 01212 CNAME edit01.dlan.legacy.test. in zone dlan.legacy.test
WARNING - edit01.dlan.legacy.test. does not exist.
RECORD - 01212lb01.dlan.legacy.test. 3600 IN A 172.20.5.208
INFO - Marked IP 172.20.5.208 from layer3domain default as static
INFO - Creating RR 01212lb01 A 172.20.5.208 in zone dlan.legacy.test
INFO - Creating RR 208 PTR 01212lb01.dlan.legacy.test. in zone 5.20.172.in-addr.arpa
RECORD - 01212lb01.dlan.legacy.test. 300 IN TXT "some key=" "some value"
INFO - Creating RR 01212lb01 300 TXT "some key=" "some value" in zone dlan.legacy.test
RECORD - 1021931729._dkimkey.dlan.legacy.test. 300 IN TXT "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB"
INFO - Creating RR 1021931729._dkimkey 300 TXT "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB" in zone dlan.legacy.test
RECORD - adimgfe01.dlan.legacy.test. 3600 IN A 172.20.5.22
INFO - Creating RR adimgfe01 A 172.20.5.22 in zone dlan.legacy.test
INFO - 22.5.20.172.in-addr.arpa. PTR adimgfe01.dlan.legacy.test. already exists
RECORD - adimgfe02.dlan.legacy.test. 3600 IN A 172.20.5.23
INFO - Creating RR adimgfe02 A 172.20.5.23 in zone dlan.legacy.test
WARNING - Not overwriting: 23.5.20.172.in-addr.arpa. PTR foo.bar.
RECORD - adimgfe03.dlan.legacy.test. 3600 IN A 172.19.22.5
INFO - Marked IP 172.19.22.5 from layer3domain default as static
INFO - Creating RR adimgfe03 A 172.19.22.5 in zone dlan.legacy.test
INFO - No zone found for 5.22.19.172.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli delete zone 11.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 8.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 7.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 6.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 5.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 4.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 3.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 2.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 1.20.172.in-addr.arpa --cleanup -q
$ ndcli delete zone 0.20.172.in-addr.arpa --cleanup -q

$ ndcli delete zone dlan.legacy.test --cleanup -q

$ ndcli modify pool dlan remove subnet 172.20.8.0/24
$ ndcli modify pool dlan remove subnet 172.20.0.0/21
$ ndcli delete pool dlan

$ ndcli delete zone-profile internal
$ ndcli delete container 172.16.0.0/12
INFO - Deleting container 172.16.0.0/12 from layer3domain default

