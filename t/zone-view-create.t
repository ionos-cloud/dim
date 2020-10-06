$ ndcli create zone-profile brand1-public primary ns-brand1.company.com.
$ ndcli modify zone-profile brand1-public create rr @ ns ns-brand1.company.com.
INFO - Creating RR @ NS ns-brand1.company.com. in zone profile brand1-public
WARNING - ns-brand1.company.com. does not exist.
$ ndcli modify zone-profile brand1-public create rr @ ns ns-brand1.company.org.
WARNING - The name brand1-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-brand1.company.org. in zone profile brand1-public
WARNING - ns-brand1.company.org. does not exist.
$ ndcli create zone a.com profile brand1-public
INFO - Creating zone a.com with profile brand1-public
#$ ndcli modify zone a.com create view -c
#-c will be parsed as a switch, resulting in a syntax error
$ ndcli modify zone a.com create view de
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone a.com create view us profile brand1-public
$ ndcli modify zone a.com create view de
ERROR - View de already exists for zone a.com
$ ndcli delete zone a.com
ERROR - The zone a.com has more than one view and cannot be deleted.
$ ndcli delete zone a.com --cleanup
ERROR - The zone a.com has more than one view and cannot be deleted.
$ ndcli modify zone a.com delete view de
$ ndcli modify zone a.com delete view us
ERROR - The view us of the zone a.com is not empty.
$ ndcli modify zone a.com delete view us --cleanup
INFO - Deleting RR @ NS ns-brand1.company.com. from zone a.com view us
INFO - Deleting RR @ NS ns-brand1.company.org. from zone a.com view us
$ ndcli delete zone a.com --cleanup
INFO - Deleting RR @ NS ns-brand1.company.com. from zone a.com
INFO - Deleting RR @ NS ns-brand1.company.org. from zone a.com
$ ndcli delete zone-profile brand1-public
