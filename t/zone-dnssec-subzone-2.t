# ksk rollover, multiple views
$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone a.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create zone subzone.a.com
WARNING - Creating zone subzone.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default, internal for zone subzone.a.com

$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key a.com_ksk_20160721_141911853808 for zone a.com
INFO - Created key a.com_zsk_20160721_141911975689 for zone a.com
WARNING - unsigned child zone(s) exit: subzone.a.com
$ ndcli modify zone subzone.a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key subzone.a.com_ksk_20160721_141912022755 for zone subzone.a.com
INFO - Creating RR subzone DS 47485 8 2 50CF0B388C949FEB98855762169829F859B519228F39989D08DF1C1F6CE6DF61 in zone a.com view default
INFO - Creating RR subzone DS 47485 8 2 50CF0B388C949FEB98855762169829F859B519228F39989D08DF1C1F6CE6DF61 in zone a.com view internal
INFO - Created key subzone.a.com_zsk_20160721_141912082687 for zone subzone.a.com

# rollover for subzone.a.com ksk
$ ndcli modify zone subzone.a.com dnssec new ksk
INFO - Created key subzone.a.com_ksk_20160721_141912114236 for zone subzone.a.com
WARNING - The name subzone.a.com. already existed, creating round robin record
INFO - Creating RR subzone DS 23900 8 2 710B3390D14A61ED364656133504046486A895F4067FA23AA265CAEE8DC0DE77 in zone a.com view default
WARNING - The name subzone.a.com. already existed, creating round robin record
INFO - Creating RR subzone DS 23900 8 2 710B3390D14A61ED364656133504046486A895F4067FA23AA265CAEE8DC0DE77 in zone a.com view internal
$ ndcli list zone subzone.a.com keys
label                                   type tag   algorithm bits created
subzone.a.com_ksk_20160721_141912022755 KSK  47485 8         2048 2016-07-21 14:19:12
subzone.a.com_zsk_20160721_141912082687 ZSK  39991 8         1024 2016-07-21 14:19:12
subzone.a.com_ksk_20160721_141912114236 KSK  23900 8         2048 2016-07-21 14:19:12

# delete old ksk (two spaces after $ to run with bash)
$  ndcli list zone subzone.a.com keys -H | grep ksk | cut -s -f 1 | head -n1 | xargs ndcli modify zone subzone.a.com dnssec delete key 2> /dev/null
$ ndcli list zone subzone.a.com keys
label                                   type tag   algorithm bits created
subzone.a.com_ksk_20160721_141912114236 KSK  23900 8         2048 2016-07-21 14:19:12
subzone.a.com_zsk_20160721_141912082687 ZSK  39991 8         1024 2016-07-21 14:19:12
# list to check that the DS rrs got deleted
$ ndcli list zone a.com view default
record  zone  ttl   type value
@       a.com 86400 SOA  localhost. hostmaster.a.com. 2016072104 14400 3600 605000 86400
subzone a.com       DS   23900 8 2 710B3390D14A61ED364656133504046486A895F4067FA23AA265CAEE8DC0DE77
$ ndcli list zone a.com view internal
record  zone  ttl   type value
@       a.com 86400 SOA  localhost. hostmaster.a.com. 2016072104 14400 3600 605000 86400
subzone a.com       DS   23900 8 2 710B3390D14A61ED364656133504046486A895F4067FA23AA265CAEE8DC0DE77

$ ndcli modify zone subzone.a.com dnssec disable
INFO - Deleting RR subzone DS 23900 8 2 710B3390D14A61ED364656133504046486A895F4067FA23AA265CAEE8DC0DE77 from zone a.com view default
INFO - Deleting RR subzone DS 23900 8 2 710B3390D14A61ED364656133504046486A895F4067FA23AA265CAEE8DC0DE77 from zone a.com view internal

$ ndcli list zone a.com view default
record zone  ttl   type value
@      a.com 86400 SOA  localhost. hostmaster.a.com. 2016072205 14400 3600 605000 86400
$ ndcli list zone a.com view internal
record zone  ttl   type value
@      a.com 86400 SOA  localhost. hostmaster.a.com. 2016072205 14400 3600 605000 86400
