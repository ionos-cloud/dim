$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create output output plugin pdns-db db-uri mysql://pdns:pdns@127.0.0.1:3307/pdns_slave
$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone a.com
$ ndcli modify output output add zone-group zg
$ ndcli modify zone a.com dnssec enable 8 ksk 1024 zsk 1024 nsec3
Created key a.com_ksk_20151120_110508 for zone a.com
Created key a.com_zsk_20151120_110508 for zone a.com
# DIM-177
$ ndcli delete zone a.com
