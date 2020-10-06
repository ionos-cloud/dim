$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create output output plugin pdns-db db-uri mysql://pdns:pdns@127.0.0.1:3307/pdns1
$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone a.com
$ ndcli modify output output add zone-group zg

# Invalid NSEC3PARAMS
$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024 nsec3 2a
ERROR - invalid literal for int() with base 10: '2a'
$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024 nsec3 66000
ERROR - Invalid NSEC3 iteration count (must be between 0 and 65535)

$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024 nsec3 11
Created key a.com_ksk_20151105_113758 for zone a.com
Created key a.com_zsk_20151105_113758 for zone a.com
$ ndcli show zone a.com
created:2015-10-27 14:01:03
created_by:admin
default_algorithm:8
default_ksk_bits:2048
default_zsk_bits:1024
modified:2015-10-27 14:01:03
modified_by:admin
name:a.com
nsec3_algorithm:1
nsec3_iterations:11
nsec3_salt:-
views:1
zone_groups:1
$ ndcli modify zone a.com create rr t A 1.1.1.1
INFO - Marked IP 1.1.1.1 from layer3domain default as static
INFO - Creating RR t A 1.1.1.1 in zone a.com
$ ndcli modify zone a.com create rr delegate NS test.com.
INFO - Creating RR delegate NS test.com. in zone a.com
WARNING - test.com. does not exist.
$ ndcli list zone a.com dnskeys --rr > /tmp/trusted-key.key
$ /usr/bin/drill @127.1.1.1 t.a.com A -S -k /tmp/trusted-key.key|grep ';; Chase'
;; Chase successful
$ /usr/bin/drill @127.1.1.1 no.a.com A -S -k /tmp/trusted-key.key|grep ';; Chase'
;; Chase successful
$ ndcli list zone a.com keys
label                     type tag   algorithm bits created
a.com_ksk_20151210_091435 KSK  51904 8         2048 2015-12-10 09:14:35
a.com_zsk_20151210_091435 ZSK  35856 8         1024 2015-12-10 09:14:36
$ ndcli list zone a.com dnskeys
tag   flags algorithm pubkey
51904 257   8         AwEAAcCy+qkMS/fPV0MnvNYFZbL0UICkZPy+4yrMVi5bwpe8snGQyMv8hUb5ULsvJElIJmFTFEETHfRPHdN9mtn3nqveYem9hCdNVbX95/x6YZ+7C/GR8X0Skyy9cVS3vyormovoohXnjNNeFNur9JolZIQnhXnJe4EYJDO6PG0vujhqS7x1roa9MdjYpBWBBgUqe+5TrasuhwjDl/fLiGOxvg2TjHdFhqdtE9dWbrImUEmdCcB8NIH4HUl0n1gzzmE5TuyQTZNrvrSo2pyEQwdgT01JWWTZo74sQN+qUS6CEDYa1LT3dviH1mQ9U0BrSdvIUqalCsq4NDItSshWJncpTaU=
35856 256   8         AwEAAcSmzN21zgrdQk3W1nhl7o19uBZGRypg9JMgdBeq6kacCVVxANvhfKVtuNMbkWcmYESk7a7+lS+37cNYb2330lL+3+6jEtTgCvxjC/zjjnyAIAZ7SdTGZM5Mig3hMa1rh9re0FjUy0cPQY+uyWObkUZ7t6ii0JISnxQTXsgUPHsD
$ ndcli list zone a.com ds
tag   algorithm digest_type digest
51904 8         1           c0ee0349c19cbdf383c11021d71e937c24334dc5
51904 8         2           2a3cb007d7a85f21c568e38706593cdb3828718102f26878b16bf41c0d7216b0
51904 8         4           42dfb7ab590e217f2cd6416cea34c64b490c07b73ed01efbd50f15805946f2c3fd17d9cd7773089d5a7c3ce0f5c20ffa
$ rm /tmp/trusted-key.key
