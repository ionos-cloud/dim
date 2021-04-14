$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli delete zone .
$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone . create view vvv
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone . rename view vvv to www
$ ndcli create rr . txt ". txt rr" view www
INFO - Creating RR @ TXT ". txt rr" in zone . view www
$ ndcli modify rr view www . -c "rr comment"
comment:rr comment
created:2013-03-19 12:49:22
created_by:admin
modified:2013-03-19 12:49:22
modified_by:admin
rr:@ TXT ". txt rr"
view:www
zone:.
$ ndcli modify zone . set view www ttl 2000 mail b@b.de

$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone . view default

$ ndcli history zones
timestamp           user  tool   originating_ip objclass name action
2014-03-05 16:36:12 admin native 127.0.0.1      zone     .    created
2014-03-05 16:36:12 admin native 127.0.0.1      zone     .    deleted
2014-03-05 16:36:12 admin native 127.0.0.1      zone     .    created

$ ndcli history zone . -L 50
timestamp           user  tool   originating_ip objclass   name             action
2014-03-05 16:36:12 admin native 127.0.0.1      zone-group zg               added zone . view default
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  www              set_attr serial=2014030503
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  www              set_attr mail=b.b.de.
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  www              set_attr ttl=2000
2014-03-05 16:36:12 admin native 127.0.0.1      rr         . TXT ". txt rr" set_attr comment=rr comment in view www
2014-03-05 16:36:12 admin native 127.0.0.1      rr         . TXT ". txt rr" created in view www
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  www              set_attr serial=2014030502
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  vvv              renamed to www
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  vvv              created
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  default          created
2014-03-05 16:36:12 admin native 127.0.0.1      zone       .                created
2014-03-05 16:36:12 admin native 127.0.0.1      zone       .                deleted
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  default          deleted
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view  default          created
2014-03-05 16:36:12 admin native 127.0.0.1      zone       .                created

$ ndcli history zone . views -L 50
timestamp           user  tool   originating_ip objclass  name    action
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www     set_attr serial=2014030502
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www     set_attr mail=b.b.de.
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www     set_attr ttl=2000
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www     set_attr serial=2014030503
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view vvv     renamed to www
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view vvv     created
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view default created
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view default deleted
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view default created

$ ndcli history zone . view www
timestamp           user  tool   originating_ip objclass  name             action
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www              set_attr serial=2014030502
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www              set_attr mail=b.b.de.
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www              set_attr ttl=2000
2014-03-05 16:36:12 admin native 127.0.0.1      rr        . TXT ". txt rr" set_attr comment=rr comment
2014-03-05 16:36:12 admin native 127.0.0.1      rr        . TXT ". txt rr" created
2014-03-05 16:36:12 admin native 127.0.0.1      zone-view www              set_attr serial=2014030503

$ ndcli history rrs
timestamp           user  tool   originating_ip objclass name             action
2014-03-05 16:36:12 admin native 127.0.0.1      rr       . TXT ". txt rr" set_attr comment=rr comment in zone . view www
2014-03-05 16:36:12 admin native 127.0.0.1      rr       . TXT ". txt rr" created in zone . view www

$ ndcli history rr .
timestamp           user  tool   originating_ip objclass name             action
2014-03-05 16:36:12 admin native 127.0.0.1      rr       . TXT ". txt rr" set_attr comment=rr comment in zone . view www
2014-03-05 16:36:12 admin native 127.0.0.1      rr       . TXT ". txt rr" created in zone . view www
