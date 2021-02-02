$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli delete zone a.de
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone-profile profile
$ ndcli modify zone-profile profile create rr @ txt "profile txt record"
INFO - Creating RR @ TXT "profile txt record" in zone profile profile
$ ndcli modify zone-profile profile set ttl 1002
$ ndcli rename zone-profile profile to profile2

$ ndcli modify zone a.de create view vvv
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone a.de rename view vvv to www
$ ndcli create rr a.de. txt "a.de txt rr" view www
INFO - Creating RR @ TXT "a.de txt rr" in zone a.de view www
$ ndcli modify rr view www a.de. -c "rr comment"
comment:rr comment
created:2013-03-19 12:49:22
created_by:admin
modified:2013-03-19 12:49:22
modified_by:admin
rr:@ TXT "a.de txt rr"
view:www
zone:a.de
$ ndcli modify zone a.de set view www ttl 2000 mail b@b.de
$ ndcli modify zone a.de set attrs a:b c:d

$ ndcli create zone-group zg
$ ndcli modify zone-group zg add zone a.de view default

$ ndcli history zone-profiles
timestamp           user  tool   originating_ip objclass     name    action
2014-03-05 16:36:10 admin native 127.0.0.1      zone-profile profile renamed to profile2
2014-03-05 16:36:09 admin native 127.0.0.1      zone-profile profile created

$ ndcli history zone-profile profile
timestamp           user  tool   originating_ip objclass     name                              action
2014-03-05 16:36:10 admin native 127.0.0.1      zone-profile profile                           renamed to profile2
2014-03-05 16:36:09 admin native 127.0.0.1      zone-profile profile                           created
2014-03-05 16:36:09 admin native 127.0.0.1      rr           profile. TXT "profile txt record" created
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view    default                           created
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view    default                           set_attr serial=2014030502
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view    default                           set_attr serial=2014030503
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view    default                           set_attr ttl=1002

$ ndcli history zones
timestamp           user  tool   originating_ip objclass name action
2014-03-05 16:36:09 admin native 127.0.0.1      zone     a.de created
2014-03-05 16:36:09 admin native 127.0.0.1      zone     a.de deleted
2014-03-05 16:36:09 admin native 127.0.0.1      zone     a.de created

$ ndcli history zone a.de -L 30
timestamp           user  tool   originating_ip objclass   name                    action
2014-03-05 16:36:10 admin native 127.0.0.1      zone       a.de                    set_attr a=b
2014-03-05 16:36:10 admin native 127.0.0.1      zone       a.de                    set_attr c=d
2014-03-05 16:36:10 admin native 127.0.0.1      rr         a.de. TXT "a.de txt rr" created in view www
2014-03-05 16:36:10 admin native 127.0.0.1      rr         a.de. TXT "a.de txt rr" set_attr comment=rr comment in view www
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view  vvv                     created
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view  vvv                     renamed to www
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view  www                     set_attr serial=2014030502
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view  www                     set_attr mail=b.b.de.
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view  www                     set_attr serial=2014030503
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view  www                     set_attr ttl=2000
2014-03-05 16:36:10 admin native 127.0.0.1      zone-group zg                      added zone a.de view default
2014-03-05 16:36:09 admin native 127.0.0.1      zone       a.de                    created
2014-03-05 16:36:09 admin native 127.0.0.1      zone       a.de                    deleted
2014-03-05 16:36:09 admin native 127.0.0.1      zone       a.de                    created
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view  default                 created
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view  default                 deleted
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view  default                 created

$ ndcli create zone b.de
WARNING - Creating zone b.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli history zone a.de views -L 20
timestamp           user  tool   originating_ip objclass  name    action
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view vvv     created
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view vvv     renamed to www
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www     set_attr serial=2014030502
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www     set_attr mail=b.b.de.
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www     set_attr serial=2014030503
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www     set_attr ttl=2000
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view default created
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view default deleted
2014-03-05 16:36:09 admin native 127.0.0.1      zone-view default created

$ ndcli history zone a.de view www -L 20
timestamp           user  tool   originating_ip objclass  name                    action
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www                     set_attr serial=2014030502
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www                     set_attr mail=b.b.de.
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www                     set_attr serial=2014030503
2014-03-05 16:36:10 admin native 127.0.0.1      zone-view www                     set_attr ttl=2000
2014-03-05 16:36:10 admin native 127.0.0.1      rr        a.de. TXT "a.de txt rr" created
2014-03-05 16:36:10 admin native 127.0.0.1      rr        a.de. TXT "a.de txt rr" set_attr comment=rr comment

$ ndcli history rrs
timestamp           user  tool   originating_ip objclass name                              action
2014-03-05 16:36:10 admin native 127.0.0.1      rr       profile. TXT "profile txt record" renamed to profile2.
2014-03-05 16:36:10 admin native 127.0.0.1      rr       a.de. TXT "a.de txt rr"           created in zone a.de view www
2014-03-05 16:36:10 admin native 127.0.0.1      rr       a.de. TXT "a.de txt rr"           set_attr comment=rr comment in zone a.de view www
2014-03-05 16:36:09 admin native 127.0.0.1      rr       profile. TXT "profile txt record" created in zone profile view default

$ ndcli history rr a.de.
timestamp           user  tool   originating_ip objclass name                    action
2014-03-05 16:36:10 admin native 127.0.0.1      rr       a.de. TXT "a.de txt rr" created in zone a.de view www
2014-03-05 16:36:10 admin native 127.0.0.1      rr       a.de. TXT "a.de txt rr" set_attr comment=rr comment in zone a.de view www
