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
timestamp           user  tool   originating_ip objclass name           action
2014-03-05 16:36:12 admin native 127.0.0.1      output   nsia-de.kae.bs renamed to real_output
2014-03-05 16:36:11 admin native 127.0.0.1      output   fake           deleted
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs added zone-group zg2
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs removed zone-group zg2
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs created
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs set_attr comment=second_comment
2014-03-05 16:36:11 admin native 127.0.0.1      output   fake           created

$ ndcli history output nsia-de.kae.bs
timestamp           user  tool   originating_ip objclass name           action
2014-03-05 16:36:12 admin native 127.0.0.1      output   nsia-de.kae.bs renamed to real_output
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs removed zone-group zg2
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs created
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs set_attr comment=second_comment
2014-03-05 16:36:11 admin native 127.0.0.1      output   nsia-de.kae.bs added zone-group zg2
