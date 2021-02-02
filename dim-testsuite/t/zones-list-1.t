$ ndcli create zone some.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone some.domain without profile
$ ndcli create zone my.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone my.domain without profile
$ ndcli list zones *domain
name        views zone_groups
my.domain   1     0
some.domain 1     0
INFO - Result for list zones *domain
$ ndcli show zone some.domain
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
views:1
name:some.domain
$ ndcli show zone my.domain
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
views:1
name:my.domain
$ ndcli create zone vier.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone vier.domain without profile
$ ndcli create zone fuenf.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone fuenf.domain without profile
$ ndcli create zone sechs.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone sechs.domain without profile
$ ndcli create zone sieben.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone sieben.domain without profile
$ ndcli create zone acht.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone acht.domain without profile
$ ndcli create zone neun.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone neun.domain without profile
$ ndcli create zone zehn.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone zehn.domain without profile
$ ndcli create zone elf.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone elf.domain without profile
$ ndcli create zone zwoelf.domain primary ins01.internal.test. mail dnsadmin@company.com
WARNING - Creating zone zwoelf.domain without profile

$ ndcli list zones *domain
name          views zone_groups
acht.domain   1     0
elf.domain    1     0
fuenf.domain  1     0
my.domain     1     0
neun.domain   1     0
sechs.domain  1     0
sieben.domain 1     0
some.domain   1     0
vier.domain   1     0
zehn.domain   1     0
INFO - Result for list zones *domain
WARNING - More results available

$ ndcli list zones *domain -L 20 -H
acht.domain	1	0
elf.domain	1	0
fuenf.domain	1	0
my.domain	1	0
neun.domain	1	0
sechs.domain	1	0
sieben.domain	1	0
some.domain	1	0
vier.domain	1	0
zehn.domain	1	0
zwoelf.domain	1	0
INFO - Result for list zones *domain

$ ndcli delete zone vier.domain
$ ndcli delete zone fuenf.domain
$ ndcli delete zone sechs.domain
$ ndcli delete zone sieben.domain
$ ndcli delete zone acht.domain
$ ndcli delete zone neun.domain
$ ndcli delete zone elf.domain
$ ndcli delete zone zwoelf.domain
$ ndcli delete zone some.domain
$ ndcli delete zone my.domain
