$ ndcli create zone-profile example-public primary ns-example.dns-example.com.
$ ndcli modify zone-profile example-public create rr @ ns ns-example.dns-example.com.
INFO - Creating RR @ NS ns-example.dns-example.com. in zone profile example-public
WARNING - ns-example.dns-example.com. does not exist.
$ ndcli modify zone-profile example-public create rr @ ns ns-example.dns-example.org.
WARNING - The name example-public. already existed, creating round robin record
INFO - Creating RR @ NS ns-example.dns-example.org. in zone profile example-public
WARNING - ns-example.dns-example.org. does not exist.
$ ndcli create zone a.com profile example-public
INFO - Creating zone a.com with profile example-public
$ ndcli modify zone a.com create view de
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone a.com create view us profile example-public
$ ndcli modify zone a.com rename view default to br
$ ndcli create rr a.com. mx 10 mx00.example.com.
ERROR - A view must be selected from: br de us
$ ndcli create rr a.com. mx 10 mx00.company.com. view de
INFO - Creating RR @ MX 10 mx00.company.com. in zone a.com view de
WARNING - mx00.company.com. does not exist.
$ ndcli create rr a.com. mx 20 mx01.example.com. view br us
INFO - Creating RR @ MX 20 mx01.example.com. in zone a.com view br
WARNING - mx01.example.com. does not exist.
INFO - Creating RR @ MX 20 mx01.example.com. in zone a.com view us
WARNING - mx01.example.com. does not exist.
$ ndcli modify zone a.com delete view br --cleanup
INFO - Deleting RR @ NS ns-example.dns-example.com. from zone a.com view br
INFO - Deleting RR @ NS ns-example.dns-example.org. from zone a.com view br
INFO - Deleting RR @ MX 20 mx01.example.com. from zone a.com view br
$ ndcli modify zone a.com delete view us --cleanup
INFO - Deleting RR @ NS ns-example.dns-example.com. from zone a.com view us
INFO - Deleting RR @ NS ns-example.dns-example.org. from zone a.com view us
INFO - Deleting RR @ MX 20 mx01.example.com. from zone a.com view us
$ ndcli delete zone a.com --cleanup
INFO - Deleting RR @ MX 10 mx00.company.com. from zone a.com
$ ndcli delete zone-profile example-public
