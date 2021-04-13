$ ndcli login -u dnsadmin -p p
$ ndcli login -u admin -p p
$ ndcli create user-group usergroup
$ ndcli modify user-group usergroup grant dns_admin
$ ndcli modify user-group usergroup grant network_admin
$ ndcli modify user-group usergroup add user dnsadmin

$ ndcli login -u dnsadmin -p p
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-profile profile
$ ndcli modify zone-profile profile create rr @ txt "profile txt record"
INFO - Creating RR @ TXT "profile txt record" in zone profile profile
$ ndcli modify rr profile. -c "new profile comment"
comment:new profile comment
created:2013-04-03 17:07:42
created_by:dnsadmin
modified:2013-04-03 17:07:42
modified_by:dnsadmin
rr:@ TXT "profile txt record"
zone:profile
$ ndcli modify zone-profile profile set ttl 1002
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli create pool p2 vlan 435 team:"IT Operations Dataservices Infrastructure"

$ ndcli login -u admin -p p
$ ndcli create zone-group zg
$ ndcli modify zone-group zg set comment "first_comment"
$ ndcli modify zone-group zg add zone a.de view default
$ ndcli create output nsia-de.kae.bs plugin pdns-db db-uri "uri" comment "comment"
$ ndcli modify output nsia-de.kae.bs add zone-group zg

$ ndcli history -L 100
timestamp                  user     tool   originating_ip objclass     name                              action
2019-01-15 11:13:05.518797 admin    native 127.0.0.1      output       nsia-de.kae.bs                    added zone-group zg
2019-01-15 11:13:05.503905 admin    native 127.0.0.1      output       nsia-de.kae.bs                    created
2019-01-15 11:13:05.493541 admin    native 127.0.0.1      zone-group   zg                                added zone a.de view default
2019-01-15 11:13:05.480603 admin    native 127.0.0.1      zone-group   zg                                set_attr comment=first_comment
2019-01-15 11:13:05.471582 admin    native 127.0.0.1      zone-group   zg                                created
2019-01-15 11:13:05.453250 dnsadmin native 127.0.0.1      ippool       p2                                set_attr team=IT Operations Dataservices Infrastructure
2019-01-15 11:13:05.450882 dnsadmin native 127.0.0.1      ippool       p2                                created in layer3domain default
2019-01-15 11:13:05.431649 dnsadmin native 127.0.0.1      ipblock      1.0.0.0/8                         created in layer3domain default
2019-01-15 11:13:05.425168 dnsadmin native 127.0.0.1      zone-view    default                           set_attr serial=2019011503 in zone profile
2019-01-15 11:13:05.415700 dnsadmin native 127.0.0.1      zone-view    default                           set_attr ttl=1002 in zone profile
2019-01-15 11:13:05.390432 dnsadmin native 127.0.0.1      rr           profile. TXT "profile txt record" set_attr comment=new profile comment in zone profile view default
2019-01-15 11:13:05.370664 dnsadmin native 127.0.0.1      rr           profile. TXT "profile txt record" created in zone profile view default
2019-01-15 11:13:05.369773 dnsadmin native 127.0.0.1      zone-view    default                           set_attr serial=2019011502 in zone profile
2019-01-15 11:26:05.905917 dnsadmin native 127.0.0.1      zone-view    default                           created in zone profile
2019-01-15 11:13:05.347647 dnsadmin native 127.0.0.1      zone-profile profile                           created
2019-01-15 11:26:05.890087 dnsadmin native 127.0.0.1      zone-view    default                           created in zone a.de
2019-01-15 11:13:05.331539 dnsadmin native 127.0.0.1      zone         a.de                              created
2019-01-15 11:13:05.312678 admin    native 127.0.0.1      group        usergroup                         added user dnsadmin
2019-01-15 11:13:05.302243 admin    native 127.0.0.1      group        usergroup                         granted network_admin
2019-01-15 11:13:05.292171 admin    native 127.0.0.1      group        usergroup                         granted dns_admin
2019-01-15 11:13:05.282938 admin    native 127.0.0.1      group        usergroup                         created
2019-01-15 11:13:05.264154 local    native                group        all_users                         added user dnsadmin
2019-01-15 11:13:05.180973 local    native                group        all_users                         added user admin
2019-01-15 11:13:05.175372 local    native                group        all_users                         created


$ ndcli history user dnsadmin -L 100
timestamp                  user     tool   originating_ip objclass     name                              action
2019-01-15 11:13:05.453250 dnsadmin native 127.0.0.1      ippool       p2                                set_attr team=IT Operations Dataservices Infrastructure
2019-01-15 11:13:05.450882 dnsadmin native 127.0.0.1      ippool       p2                                created in layer3domain default
2019-01-15 11:13:05.431649 dnsadmin native 127.0.0.1      ipblock      1.0.0.0/8                         created in layer3domain default
2019-01-15 11:13:05.425168 dnsadmin native 127.0.0.1      zone-view    default                           set_attr serial=2019011503 in zone profile
2019-01-15 11:13:05.415700 dnsadmin native 127.0.0.1      zone-view    default                           set_attr ttl=1002 in zone profile
2019-01-15 11:13:05.390432 dnsadmin native 127.0.0.1      rr           profile. TXT "profile txt record" set_attr comment=new profile comment in zone profile view default
2019-01-15 11:13:05.370664 dnsadmin native 127.0.0.1      rr           profile. TXT "profile txt record" created in zone profile view default
2019-01-15 11:13:05.369773 dnsadmin native 127.0.0.1      zone-view    default                           set_attr serial=2019011502 in zone profile
2019-01-15 11:26:05.905917 dnsadmin native 127.0.0.1      zone-view    default                           created in zone profile
2019-01-15 11:13:05.347647 dnsadmin native 127.0.0.1      zone-profile profile                           created
2019-01-15 11:26:05.890087 dnsadmin native 127.0.0.1      zone-view    default                           created in zone a.de
2019-01-15 11:13:05.331539 dnsadmin native 127.0.0.1      zone         a.de                              created
