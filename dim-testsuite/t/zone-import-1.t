# The real migration will be done by
# - importing reverse Zones (no forward entries will be created)
# - importing forward Zones (if no reverse entry exists, reverse entry is created)

$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@1and1.com
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

$ ndcli create pool ilan
$ ndcli modify pool ilan add subnet 172.20.0.0/21
INFO - Created subnet 172.20.0.0/21 in layer3domain default
INFO - Creating zone 0.20.172.in-addr.arpa with profile internal
INFO - Creating zone 1.20.172.in-addr.arpa with profile internal
INFO - Creating zone 2.20.172.in-addr.arpa with profile internal
INFO - Creating zone 3.20.172.in-addr.arpa with profile internal
INFO - Creating zone 4.20.172.in-addr.arpa with profile internal
INFO - Creating zone 5.20.172.in-addr.arpa with profile internal
INFO - Creating zone 6.20.172.in-addr.arpa with profile internal
INFO - Creating zone 7.20.172.in-addr.arpa with profile internal
$ ndcli modify pool ilan add subnet 172.20.8.0/24
INFO - Created subnet 172.20.8.0/24 in layer3domain default
INFO - Creating zone 8.20.172.in-addr.arpa with profile internal

$ ndcli create zone ilan.legacy.test profile internal
INFO - Creating zone ilan.legacy.test with profile internal

# Let's get it rolling with a "simple" forward zone
$ cat <<EOF | ndcli import zone ilan.legacy.test
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.10.rc1.el6_3.6 <<>> axfr ilan.legacy.test @anyins-ins-bs01.ilan.legacy.test
;; global options: +cmd
ilan.legacy.test.        3600    IN      SOA     ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600
ilan.legacy.test.        3600    IN      NS      ins01.internal.test.
ilan.legacy.test.        3600    IN      NS      ins02.internal.test.
ilan.legacy.test.        3600    IN      MX      100 mailgate3.ilan.legacy.test.
ilan.legacy.test.        3600    IN      MX      300 mailgate2.ilan.legacy.test.
01212.ilan.legacy.test.  3600    IN      CNAME   edit01.ilan.legacy.test.
01212lb01.ilan.legacy.test. 3600 IN      A       172.20.5.208
42.ilan.legacy.test.     3600    IN      CNAME   42.itbsxen01.ilan.legacy.test.
1021931729._dkimkey.ilan.legacy.test. 300 IN TXT "v=DKIM1\;k=rsa\;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB"
1021931729._domainkey.ilan.legacy.test. 300 IN TXT "v=DKIM1\;k=rsa\;p=MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKqoZPt2VLATJW6g1VjfmKerwwLqIZ4n S9l1dwm0TD+tgwmVcakpd/I7dIxqUMvkxA/xijbYnw1AammKRkH1KHUCAwEAAQ=="
abmadmin.ilan.legacy.test. 3600  IN      CNAME   abmfe01.ilan.legacy.test.
EOF
INFO - Creating zone ilan.legacy.test
ERROR - Zone ilan.legacy.test already exists

$ ndcli delete zone ilan.legacy.test --cleanup -q

# only testing what happens if someting is in the reverse Zone.
$ ndcli create rr 172.20.5.22 ptr adimgfe01.ilan.legacy.test.
INFO - Marked IP 172.20.5.22 from layer3domain default as static
INFO - No zone found for adimgfe01.ilan.legacy.test.
INFO - Creating RR 22 PTR adimgfe01.ilan.legacy.test. in zone 5.20.172.in-addr.arpa
WARNING - No forward zone found. Only creating reverse entry.
$ ndcli create rr 172.20.5.23 ptr foo.bar.
INFO - Marked IP 172.20.5.23 from layer3domain default as static
INFO - No zone found for foo.bar.
INFO - Creating RR 23 PTR foo.bar. in zone 5.20.172.in-addr.arpa
WARNING - No forward zone found. Only creating reverse entry.

$ cat <<EOF | ndcli import zone ilan.legacy.test
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.10.rc1.el6_3.6 <<>> axfr ilan.legacy.test @anyins-ins-bs01.ilan.legacy.test
;; global options: +cmd
ilan.legacy.test.        3600    IN      SOA     ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600
ilan.legacy.test.        3600    IN      NS      ins01.internal.test.
ilan.legacy.test.        3600    IN      NS      ins02.internal.test.
ilan.legacy.test.        3600    IN      MX      100 mailgate3.ilan.legacy.test.
ilan.legacy.test.        3600    IN      MX      300 mailgate2.ilan.legacy.test.
01212.ilan.legacy.test.  3600    IN      CNAME   edit01.ilan.legacy.test.
01212lb01.ilan.legacy.test. 3600 IN      A       172.20.5.208
1021931729._dkimkey.ilan.legacy.test. 300 IN TXT "v=DKIM1\;k=rsa\;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB"
01212lb01.ilan.legacy.test. 300 IN TXT "some key=" "some value"
adimgfe01.ilan.legacy.test. 3600 IN      A       172.20.5.22
adimgfe02.ilan.legacy.test. 3600 IN      A       172.20.5.23
adimgfe03.ilan.legacy.test. 3600 IN      A       172.19.22.5
EOF
INFO - Creating zone ilan.legacy.test
RECORD - ilan.legacy.test. 3600 IN SOA ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600
INFO - Creating RR @ SOA ins01.internal.test. dnsadmin.company.com. 2005110840 600 180 604800 3600 in zone ilan.legacy.test
RECORD - ilan.legacy.test. 3600 IN NS ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone ilan.legacy.test
WARNING - ins01.internal.test. does not exist.
RECORD - ilan.legacy.test. 3600 IN NS ins02.internal.test.
INFO - Marked IP 172.19.22.5 from layer3domain default as static
INFO - Creating RR @ NS ins02.internal.test. in zone ilan.legacy.test
WARNING - ins02.internal.test. does not exist.
WARNING - The name ilan.legacy.test. already existed, creating round robin record
RECORD - ilan.legacy.test. 3600 IN MX 100 mailgate3.ilan.legacy.test.
INFO - Creating RR @ MX 100 mailgate3.ilan.legacy.test. in zone ilan.legacy.test
WARNING - mailgate3.ilan.legacy.test. does not exist.
RECORD - ilan.legacy.test. 3600 IN MX 300 mailgate2.ilan.legacy.test.
WARNING - The name ilan.legacy.test. already existed, creating round robin record
INFO - Creating RR @ MX 300 mailgate2.ilan.legacy.test. in zone ilan.legacy.test
WARNING - mailgate2.ilan.legacy.test. does not exist.
RECORD - 01212.ilan.legacy.test. 3600 IN CNAME edit01.ilan.legacy.test.
INFO - Creating RR 01212 CNAME edit01.ilan.legacy.test. in zone ilan.legacy.test
WARNING - edit01.ilan.legacy.test. does not exist.
RECORD - 01212lb01.ilan.legacy.test. 3600 IN A 172.20.5.208
INFO - Creating RR 01212lb01 A 172.20.5.208 in zone ilan.legacy.test
INFO - Creating RR 208 PTR 01212lb01.ilan.legacy.test. in zone 5.20.172.in-addr.arpa
RECORD - 1021931729._dkimkey.ilan.legacy.test. 300 IN TXT "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB"
INFO - Creating RR 1021931729._dkimkey 300 TXT "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFpZEaLQAbzDDMkmDMZNzulKNI9QWcGOtD9SaMPwJ48xHRfTUxW1AIUgH/i1gFg0uM988hcNSyljkK81p0ASDGTmRBEwDZrHE+G96XOUhi4OZppteMswbbuDy3AIXQB/JG5ktFl0eYdAejkucOG0uIlvpeNhrSNn2wjASgYlqJBwIDAQAB" in zone ilan.legacy.test
RECORD - 01212lb01.ilan.legacy.test. 300 IN TXT "some key=" "some value"
INFO - Creating RR 01212lb01 300 TXT "some key=" "some value" in zone ilan.legacy.test
RECORD - adimgfe01.ilan.legacy.test. 3600 IN A 172.20.5.22
INFO - Creating RR adimgfe01 A 172.20.5.22 in zone ilan.legacy.test
INFO - 22.5.20.172.in-addr.arpa. PTR adimgfe01.ilan.legacy.test. already exists
RECORD - adimgfe02.ilan.legacy.test. 3600 IN A 172.20.5.23
INFO - Creating RR adimgfe02 A 172.20.5.23 in zone ilan.legacy.test
WARNING - Not overwriting: 23.5.20.172.in-addr.arpa. PTR foo.bar.
INFO - Marked IP 172.20.5.208 from layer3domain default as static
RECORD - adimgfe03.ilan.legacy.test. 3600 IN A 172.19.22.5
INFO - Creating RR adimgfe03 A 172.19.22.5 in zone ilan.legacy.test
INFO - No zone found for 5.22.19.172.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli delete zone ilan.legacy.test -q --cleanup
$ ndcli delete zone 0.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 1.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 2.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 3.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 4.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 5.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 6.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 7.20.172.in-addr.arpa -q --cleanup
$ ndcli delete zone 8.20.172.in-addr.arpa -q --cleanup

$ ndcli modify pool ilan remove subnet 172.20.8.0/24
$ ndcli modify pool ilan remove subnet 172.20.0.0/21
$ ndcli delete pool ilan

$ ndcli delete zone-profile internal
$ ndcli delete container 172.16.0.0/12
INFO - Deleting container 172.16.0.0/12 from layer3domain default
