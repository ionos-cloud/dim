$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone a.de dnssec enable 8 ksk 2048 zsk 1024 nsec3
Created key a.de_ksk_20160705_114940 for zone a.de
Created key a.de_zsk_20160705_114941 for zone a.de
$ ndcli modify zone a.de dnssec disable
$ ndcli history zone a.de -L 20
timestamp                  user  tool   originating_ip objclass  name                           action
2021-04-12 15:27:33.379893 admin native 127.0.0.1      zone      a.de                           dnssec disabled
2021-04-12 15:27:33.372399 admin native 127.0.0.1      key       a.de_zsk_20210412_132721409415 deleted
2021-04-12 15:27:33.369720 admin native 127.0.0.1      key       a.de_ksk_20210412_132720994121 deleted
2021-04-12 15:27:21.540397 admin native 127.0.0.1      zone      a.de                           dnssec enabled
2021-04-12 15:27:21.532983 admin native 127.0.0.1      key       a.de_zsk_20210412_132721409415 created
2021-04-12 15:27:21.529183 admin native 127.0.0.1      key       a.de_ksk_20210412_132720994121 created
2021-04-12 15:27:21.515917 admin native 127.0.0.1      zone      a.de                           set_attr default_zsk_bits=1024
2021-04-12 15:27:21.515464 admin native 127.0.0.1      zone      a.de                           set_attr default_ksk_bits=2048
2021-04-12 15:27:21.514869 admin native 127.0.0.1      zone      a.de                           set_attr default_algorithm=8
2021-04-12 15:26:54.293465 admin native 127.0.0.1      zone-view default                        created
2021-04-12 15:26:54.287705 admin native 127.0.0.1      zone      a.de                           created
