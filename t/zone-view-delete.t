$ ndcli create zone-profile g-brand-public primary ns-g-brand.company.com.
$ ndcli modify zone-profile g-brand-public create rr @ ns ns-g-brand.company.com.
INFO - Creating RR @ NS ns-g-brand.company.com. in zone profile g-brand-public
WARNING - ns-g-brand.company.com. does not exist.
$ ndcli modify zone-profile g-brand-public create rr @ ns ns-g-brand.company.org.
WARNING - The name g-brand-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-g-brand.company.org. in zone profile g-brand-public
WARNING - ns-g-brand.company.org. does not exist.
$ ndcli create zone g-brand.com profile g-brand-public
INFO - Creating zone g-brand.com with profile g-brand-public
$ ndcli create zone g-brand.net profile g-brand-public
INFO - Creating zone g-brand.net with profile g-brand-public
$ ndcli modify zone g-brand.com create view us
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone g-brand.com rename view default to eu
$ ndcli modify zone g-brand.com delete view eu --cleanup
INFO - Deleting RR @ NS ns-g-brand.company.com. from zone g-brand.com view eu
INFO - Deleting RR @ NS ns-g-brand.company.org. from zone g-brand.com view eu
$ ndcli modify zone g-brand.net delete view default --cleanup
ERROR - The zone g-brand.net has only one view.
$ ndcli delete zone g-brand.net --cleanup
INFO - Deleting RR @ NS ns-g-brand.company.com. from zone g-brand.net
INFO - Deleting RR @ NS ns-g-brand.company.org. from zone g-brand.net
$ ndcli modify zone g-brand.com delete view default --cleanup
ERROR - Zone g-brand.com has no view named default.
$ ndcli modify zone g-brand.com delete view us --cleanup
ERROR - The zone g-brand.com has only one view.
$ ndcli delete zone g-brand.com --cleanup
$ ndcli delete zone-profile g-brand-public
