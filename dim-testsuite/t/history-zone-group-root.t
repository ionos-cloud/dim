$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-group zg
$ ndcli create zone-group another_zg
$ ndcli modify zone-group zg set comment "first_comment"
$ ndcli modify zone-group zg add zone . view default
$ ndcli modify zone-group zg remove zone .
$ ndcli rename zone-group zg to zg2
$ ndcli delete zone-group another_zg

$ ndcli history zone-groups
timestamp           user  tool   originating_ip objclass   name       action
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group another_zg deleted
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg         renamed to zg2
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg         removed zone . view default
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg         added zone . view default
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg         set_attr comment=first_comment
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group another_zg created
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg         created

$ ndcli history zone-group zg
timestamp           user  tool   originating_ip objclass   name action
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg   renamed to zg2
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg   removed zone . view default
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg   added zone . view default
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg   set_attr comment=first_comment
2014-03-05 16:36:11 admin native 127.0.0.1      zone-group zg   created


$ ndcli create output nsia-de.kae.bs plugin pdns-db db-uri "uri" comment "comment"
$ ndcli modify output nsia-de.kae.bs set comment "second_comment"
$ ndcli create output fake plugin pdns-db db-uri "uri"
$ ndcli delete output fake
$ ndcli modify output nsia-de.kae.bs add zone-group zg2
$ ndcli modify output nsia-de.kae.bs remove zone-group zg2
$ ndcli rename output nsia-de.kae.bs to real_output

$ ndcli history outputs
timestamp                  user  tool   originating_ip objclass name           action
2021-04-13 11:06:55.707851 admin native 127.0.0.1      output   nsia-de.kae.bs renamed to real_output
2021-04-13 11:06:55.600728 admin native 127.0.0.1      output   nsia-de.kae.bs removed zone-group zg2
2021-04-13 11:06:55.492692 admin native 127.0.0.1      output   nsia-de.kae.bs added zone-group zg2
2021-04-13 11:06:55.367204 admin native 127.0.0.1      output   fake           deleted
2021-04-13 11:06:55.258243 admin native 127.0.0.1      output   fake           created
2021-04-13 11:06:55.148242 admin native 127.0.0.1      output   nsia-de.kae.bs set_attr comment=second_comment
2021-04-13 11:06:55.040687 admin native 127.0.0.1      output   nsia-de.kae.bs created

$ ndcli history output nsia-de.kae.bs
timestamp                  user  tool   originating_ip objclass name           action
2021-04-13 11:12:21.610879 admin native 127.0.0.1      output   nsia-de.kae.bs renamed to real_output
2021-04-13 11:12:21.472252 admin native 127.0.0.1      output   nsia-de.kae.bs removed zone-group zg2
2021-04-13 11:12:21.330870 admin native 127.0.0.1      output   nsia-de.kae.bs added zone-group zg2
2021-04-13 11:12:20.995497 admin native 127.0.0.1      output   nsia-de.kae.bs set_attr comment=second_comment
2021-04-13 11:12:20.887146 admin native 127.0.0.1      output   nsia-de.kae.bs created
