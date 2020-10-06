$ ndcli create zone a.com
WARNING - Creating zone a.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone subzone.a.com
WARNING - Creating zone subzone.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone subzone.a.com
$ ndcli create zone subzone2.a.com
WARNING - Creating zone subzone2.a.com without profile
WARNING - Primary NS for this Domain is now localhost.
INFO - Creating views default for zone subzone2.a.com

# no DS records are created when parent is not signed
$ ndcli modify zone subzone.a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key subzone.a.com_ksk_20160712_124451736236 for zone subzone.a.com
INFO - Created key subzone.a.com_zsk_20160712_124451942448 for zone subzone.a.com
$ ndcli modify zone subzone.a.com dnssec disable

$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key a.com_ksk_20160712_120343013222 for zone a.com
INFO - Created key a.com_zsk_20160712_120343179434 for zone a.com
WARNING - unsigned child zone(s) exit: subzone.a.com, subzone2.a.com

$ ndcli modify zone subzone.a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key subzone.a.com_ksk_20160712_120343216129 for zone subzone.a.com
INFO - Creating RR subzone DS 31690 8 2 4E1A0D4F2F85CAF47F1C6AD78CE236544B9780564AC94C524462DE09697E8862 in zone a.com
INFO - Created key subzone.a.com_zsk_20160712_120343373456 for zone subzone.a.com

# disabling dnssec for the parent zone triggers DS deletion
$ ndcli modify zone a.com dnssec disable
INFO - Deleting RR subzone DS 57940 8 2 C1AB9BFFB4FF60C25C230301E1329899C0BB9ECA233CC0AC4DA0C08BAD29AB8D from zone a.com

# enabling dnssec for the parent zone triggers DS creation
$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key a.com_ksk_20160712_120343422117 for zone a.com
INFO - Created key a.com_zsk_20160712_120343483054 for zone a.com
WARNING - unsigned child zone(s) exit: subzone2.a.com
INFO - Creating RR subzone DS 57940 8 2 C1AB9BFFB4FF60C25C230301E1329899C0BB9ECA233CC0AC4DA0C08BAD29AB8D in zone a.com

$ ndcli modify zone subzone2.a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key subzone2.a.com_ksk_20160712_120343554894 for zone subzone2.a.com
INFO - Creating RR subzone2 DS 4060 8 2 F17752D9EE3B288E3A9C1C569B0444ED50808E29951A2F914E4A24F52F320AD0 in zone a.com
INFO - Created key subzone2.a.com_zsk_20160712_120343672263 for zone subzone2.a.com
$ ndcli modify zone a.com dnssec disable
INFO - Deleting RR subzone DS 57940 8 2 C1AB9BFFB4FF60C25C230301E1329899C0BB9ECA233CC0AC4DA0C08BAD29AB8D from zone a.com
INFO - Deleting RR subzone2 DS 30185 8 2 C4D68BD8D653051C072EDE97D77451C977E8AD3B15D29CDF6D4A0EF417D6D5F5 from zone a.com
$ ndcli modify zone a.com dnssec enable 8 ksk 2048 zsk 1024
INFO - Created key a.com_ksk_20160712_120343727715 for zone a.com
INFO - Created key a.com_zsk_20160712_120343787379 for zone a.com
INFO - Creating RR subzone DS 57940 8 2 C1AB9BFFB4FF60C25C230301E1329899C0BB9ECA233CC0AC4DA0C08BAD29AB8D in zone a.com
INFO - Creating RR subzone2 DS 30185 8 2 C4D68BD8D653051C072EDE97D77451C977E8AD3B15D29CDF6D4A0EF417D6D5F5 in zone a.com
