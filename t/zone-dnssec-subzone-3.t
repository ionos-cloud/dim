$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone subzone.a.com
WARNING - Creating zone subzone.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone subzone.a.com
$ ndcli create output output plugin pdns-db db-uri mysql://pdns:pdns@127.0.0.1:3307/pdns1
$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone a.com
$ ndcli modify zone-group zg add zone subzone.a.com
$ ndcli modify output output add zone-group zg

$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024 nsec3 11
INFO - Created key a.com_ksk_20160713_132246645910 for zone a.com
INFO - Created key a.com_zsk_20160713_132246720742 for zone a.com
WARNING - unsigned child zone(s) exit: subzone.a.com
$ ndcli modify zone subzone.a.com dnssec enable 8 ksk 2048 zsk 1024 nsec3 11
INFO - Created key subzone.a.com_ksk_20160713_132246807181 for zone subzone.a.com
INFO - Creating RR subzone DS 37114 8 2 9DEA91228007C8955623F7BF88279B4B36A0138AF809103CAB16A392076B6B9E in zone a.com
INFO - Created key subzone.a.com_zsk_20160713_132246925205 for zone subzone.a.com

$ ndcli list zone a.com dnskeys --rr > /tmp/trusted-key.key
$ /usr/bin/drill @127.1.1.1 subzone.a.com SOA -S -k /tmp/trusted-key.key|grep ';; Chase'
;; Chase successful
$ /usr/bin/drill @127.1.1.1 subzone.a.com SOA -S -k /tmp/trusted-key.key|grep 'Existence is denied'
$ /usr/bin/drill @127.1.1.1 subzone.a.com A -S -k /tmp/trusted-key.key|grep ';; Chase'
;; Chase successful
$ /usr/bin/drill @127.1.1.1 subzone.a.com A -S -k /tmp/trusted-key.key|grep 'Existence is denied'
|---Existence is denied by:
