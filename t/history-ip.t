$ ndcli create pool p2 vlan 435 team:"IT Operations Dataservices Infrastructure"
$ ndcli rename pool p2 to p
$ ndcli modify pool p remove vlan
$ ndcli modify pool p set vlan 123
$ ndcli modify pool p set attrs key:value key2:value2
$ ndcli modify pool p remove attrs key key2

$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli delete container 1.0.0.0/8
INFO - Deleting container 1.0.0.0/8 from layer3domain default
$ ndcli create container 1.0.0.0/8
INFO - Creating container 1.0.0.0/8 in layer3domain default
$ ndcli modify container 1.0.0.0/8 set attrs a:b c:d
$ ndcli modify container 1.0.0.0/8 remove attrs c

$ ndcli modify pool p add subnet 1.2.3.0/24 gw 1.2.3.1
INFO - Created subnet 1.2.3.0/24 in layer3domain default
WARNING - Creating zone 3.2.1.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify pool p subnet 1.2.3.0/24 remove gw
$ ndcli modify pool p subnet 1.2.3.0/24 set gw 1.2.3.1
$ ndcli modify pool p subnet 1.2.3.0/24 set prio 10
$ ndcli modify pool p subnet 1.2.3.0/24 set attrs x:y z:t
$ ndcli modify pool p subnet 1.2.3.0/24 remove attrs z

$ ndcli modify pool p get delegation 26 maxsplit 32
created:2013-03-29 15:38:13
gateway:1.2.3.1
ip:1.2.3.64/26
layer3domain:default
mask:255.255.255.0
modified:2013-03-29 15:38:13
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Delegation
subnet:1.2.3.0/24

$ ndcli modify pool p get delegation 26 maxsplit 32
created:2013-03-29 15:38:13
gateway:1.2.3.1
ip:1.2.3.128/26
layer3domain:default
mask:255.255.255.0
modified:2013-03-29 15:38:13
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Delegation
subnet:1.2.3.0/24

$ ndcli modify pool p get delegation 26 maxsplit 32
created:2013-03-29 15:38:13
gateway:1.2.3.1
ip:1.2.3.32/27
layer3domain:default
mask:255.255.255.0
modified:2013-03-29 15:38:13
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Delegation
subnet:1.2.3.0/24

created:2013-03-29 15:38:13
gateway:1.2.3.1
ip:1.2.3.192/27
ip:1.2.3.192/27
mask:255.255.255.0
modified:2013-03-29 15:38:13
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Delegation
subnet:1.2.3.0/24

$ ndcli modify pool p subnet 1.2.3.0/24 get delegation 28
created:2013-03-29 15:58:02
gateway:1.2.3.1
ip:1.2.3.16/28
layer3domain:default
mask:255.255.255.0
modified:2013-03-29 15:58:02
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Delegation
subnet:1.2.3.0/24

$ ndcli modify pool p delegation 1.2.3.64/26 get ip
created:2013-03-29 15:58:02
delegation:1.2.3.64/26
gateway:1.2.3.1
ip:1.2.3.64
layer3domain:default
mask:255.255.255.0
modified:2013-03-29 15:58:02
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Static
subnet:1.2.3.0/24

$ ndcli modify pool p delegation 1.2.3.64/26 mark ip 1.2.3.65
created:2013-04-01 17:15:59
delegation:1.2.3.64/26
gateway:1.2.3.1
ip:1.2.3.65
layer3domain:default
mask:255.255.255.0
modified:2013-04-01 17:15:59
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Static
subnet:1.2.3.0/24

$ ndcli modify pool p delegation 1.2.3.64/26 free ip 1.2.3.65

$ ndcli modify pool p get ip
created:2013-03-29 13:23:27
gateway:1.2.3.1
ip:1.2.3.1
layer3domain:default
mask:255.255.255.0
modified:2013-03-29 13:23:27
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Static
subnet:1.2.3.0/24

$ ndcli modify pool p remove delegation 1.2.3.16/28

$ ndcli modify pool p mark delegation 1.2.3.16/28
created:2013-04-01 17:44:19
gateway:1.2.3.1
ip:1.2.3.16/28
layer3domain:default
mask:255.255.255.0
modified:2013-04-01 17:44:19
modified_by:admin
pool:p
reverse_zone:3.2.1.in-addr.arpa
status:Delegation
subnet:1.2.3.0/24

$ ndcli modify pool p remove subnet 1.2.3.0/24 --cleanup --force
INFO - Deleting zone 3.2.1.in-addr.arpa
$ ndcli delete pool p


$ ndcli history pool p2
timestamp                  user  tool   originating_ip objclass name action
2019-01-15 10:29:26.058800 admin native 127.0.0.1      ippool   p2   renamed to p
2019-01-15 10:29:26.043103 admin native 127.0.0.1      ippool   p2   set_attr team=IT Operations Dataservices Infrastructure
2019-01-15 10:29:26.040756 admin native 127.0.0.1      ippool   p2   created in layer3domain default


$ ndcli history pool p -L 50
timestamp                  user  tool   originating_ip objclass name action
2019-01-15 10:29:26.670621 admin native 127.0.0.1      ippool   p    deleted in layer3domain default
2019-01-15 10:29:26.653533 admin native 127.0.0.1      ippool   p    delete subnet 1.2.3.0/24
2019-01-15 10:29:26.578476 admin native 127.0.0.1      ippool   p    create delegation 1.2.3.16/28
2019-01-15 10:29:26.555486 admin native 127.0.0.1      ippool   p    delete delegation 1.2.3.16/28
2019-01-15 10:29:26.527180 admin native 127.0.0.1      ippool   p    create static 1.2.3.1
2019-01-15 10:29:26.506586 admin native 127.0.0.1      ippool   p    delete static 1.2.3.65
2019-01-15 10:29:26.480941 admin native 127.0.0.1      ippool   p    create static 1.2.3.65
2019-01-15 10:29:26.454428 admin native 127.0.0.1      ippool   p    create static 1.2.3.64
2019-01-15 10:29:26.418869 admin native 127.0.0.1      ippool   p    create delegation 1.2.3.16/28
2019-01-15 10:29:26.379836 admin native 127.0.0.1      ippool   p    create delegation 1.2.3.192/27
2019-01-15 10:29:26.379083 admin native 127.0.0.1      ippool   p    create delegation 1.2.3.32/27
2019-01-15 10:29:26.353690 admin native 127.0.0.1      ippool   p    create delegation 1.2.3.128/26
2019-01-15 10:29:26.326640 admin native 127.0.0.1      ippool   p    create delegation 1.2.3.64/26
2019-01-15 10:29:26.239234 admin native 127.0.0.1      ippool   p    create subnet 1.2.3.0/24
2019-01-15 10:29:26.206617 admin native 127.0.0.1      ippool   p    set_attr version=4
2019-01-15 10:29:26.107584 admin native 127.0.0.1      ippool   p    del_attr key2
2019-01-15 10:29:26.107090 admin native 127.0.0.1      ippool   p    del_attr key
2019-01-15 10:29:26.095311 admin native 127.0.0.1      ippool   p    set_attr key=value
2019-01-15 10:29:26.094807 admin native 127.0.0.1      ippool   p    set_attr key2=value2
2019-01-15 10:29:26.080957 admin native 127.0.0.1      ippool   p    set_attr vlan=123
2019-01-15 10:29:26.069508 admin native 127.0.0.1      ippool   p    set_attr vlan=None

$ ndcli history ipblock 1.0.0.0/8  -L 50
timestamp                  user  tool   originating_ip objclass name      action
2019-01-15 10:29:26.182195 admin native 127.0.0.1      ipblock  1.0.0.0/8 del_attr c in layer3domain default
2019-01-15 10:29:26.168569 admin native 127.0.0.1      ipblock  1.0.0.0/8 set_attr c=d in layer3domain default
2019-01-15 10:29:26.167969 admin native 127.0.0.1      ipblock  1.0.0.0/8 set_attr a=b in layer3domain default
2019-01-15 10:29:26.150028 admin native 127.0.0.1      ipblock  1.0.0.0/8 created in layer3domain default
2019-01-15 10:29:26.138103 admin native 127.0.0.1      ipblock  1.0.0.0/8 deleted in layer3domain default
2019-01-15 10:29:26.118903 admin native 127.0.0.1      ipblock  1.0.0.0/8 created in layer3domain default

$ ndcli history ipblock 1.2.3.0/24 -L 50
timestamp                  user  tool   originating_ip objclass name       action
2019-01-15 10:29:26.631978 admin native 127.0.0.1      ipblock  1.2.3.0/24 deleted in layer3domain default
2019-01-15 10:29:26.313794 admin native 127.0.0.1      ipblock  1.2.3.0/24 del_attr z in layer3domain default
2019-01-15 10:29:26.298698 admin native 127.0.0.1      ipblock  1.2.3.0/24 set_attr z=t in layer3domain default
2019-01-15 10:29:26.298163 admin native 127.0.0.1      ipblock  1.2.3.0/24 set_attr x=y in layer3domain default
2019-01-15 10:29:26.280208 admin native 127.0.0.1      ipblock  1.2.3.0/24 set_attr priority=10 in layer3domain default
2019-01-15 10:29:26.266345 admin native 127.0.0.1      ipblock  1.2.3.0/24 set_attr gateway=1.2.3.1 in layer3domain default
2019-01-15 10:29:26.253026 admin native 127.0.0.1      ipblock  1.2.3.0/24 set_attr gateway=None in layer3domain default
2019-01-15 10:29:26.210334 admin native 127.0.0.1      ipblock  1.2.3.0/24 set_attr pool=p in layer3domain default
2019-01-15 10:29:26.197103 admin native 127.0.0.1      ipblock  1.2.3.0/24 created in layer3domain default

$ ndcli history ipblock 1.2.3.64/26 -L 50
timestamp                  user  tool   originating_ip objclass name        action
2019-01-15 10:29:26.626278 admin native 127.0.0.1      ipblock  1.2.3.64/26 deleted in layer3domain default
2019-01-15 10:29:26.328940 admin native 127.0.0.1      ipblock  1.2.3.64/26 created in layer3domain default
