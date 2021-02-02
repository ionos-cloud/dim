$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone b.a.com
WARNING - Creating zone b.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone b.a.com
$ ndcli create zone c.b.a.com
WARNING - Creating zone c.b.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone c.b.a.com

$ ndcli modify zone a.com dnssec enable 8 ksk 1024 zsk 1024
INFO - Created key a.com_ksk_20160721_144922821129 for zone a.com
INFO - Created key a.com_zsk_20160721_144922850363 for zone a.com
WARNING - unsigned child zone(s) exit: b.a.com
$ ndcli modify zone c.b.a.com dnssec enable 8 ksk 1024 zsk 1024
INFO - Created key c.b.a.com_ksk_20160721_144922894030 for zone c.b.a.com
INFO - Created key c.b.a.com_zsk_20160721_144922925359 for zone c.b.a.com
$ ndcli modify zone b.a.com dnssec enable 8 ksk 1024 zsk 1024
INFO - Created key b.a.com_ksk_20160721_144922961316 for zone b.a.com
INFO - Creating RR b DS 44174 8 2 6EDFFCA99BBEDF81CB8342DCEB450B19C1AD488D8AE58BCE6D39B9622B4A83B0 in zone a.com
INFO - Created key b.a.com_zsk_20160721_144923017310 for zone b.a.com
INFO - Creating RR c DS 17275 8 2 B2C08D5182EB726D5B4BDD2931E58DBCC5AA00DEF1797C1CC79F7FC146FF0613 in zone b.a.com

$ ndcli modify zone b.a.com dnssec disable
INFO - Deleting RR c DS 17275 8 2 B2C08D5182EB726D5B4BDD2931E58DBCC5AA00DEF1797C1CC79F7FC146FF0613 from zone b.a.com
INFO - Deleting RR b DS 44174 8 2 6EDFFCA99BBEDF81CB8342DCEB450B19C1AD488D8AE58BCE6D39B9622B4A83B0 from zone a.com
$ ndcli modify zone b.a.com dnssec enable 8 ksk 1024 zsk 1024
INFO - Created key b.a.com_ksk_20160721_144923128645 for zone b.a.com
INFO - Creating RR b DS 31369 8 2 A2A67A5298967CA0F4FA5B03F835EC582734737A23075F0E527F7F8B45B1267B in zone a.com
INFO - Created key b.a.com_zsk_20160721_144923168405 for zone b.a.com
INFO - Creating RR c DS 17275 8 2 B2C08D5182EB726D5B4BDD2931E58DBCC5AA00DEF1797C1CC79F7FC146FF0613 in zone b.a.com
$ ndcli delete zone b.a.com -c
INFO - Deleting RR c DS 17275 8 2 B2C08D5182EB726D5B4BDD2931E58DBCC5AA00DEF1797C1CC79F7FC146FF0613 from zone b.a.com
INFO - Deleting RR b DS 31369 8 2 A2A67A5298967CA0F4FA5B03F835EC582734737A23075F0E527F7F8B45B1267B from zone a.com
