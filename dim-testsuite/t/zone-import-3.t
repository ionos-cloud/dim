$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ cat <<EOF | ndcli import zone example.com view us
@               IN      SOA     ins01.internal.test. dnsadmin.company.com. 2005110981 600 180 604800 3600

*.app1.devqa.diy                IN CNAME        vm3336.development.lan. ; 2012-12-10 15:37:30 :
*.jimdo-dev16.diy               IN CNAME        jimdo-dev16.diy ; 2012-06-13 11:03:04 : ITOCIS-7783
EOF
INFO - Creating zone example.com view us
RECORD - example.com. 3600 IN SOA ins01.internal.test. dnsadmin.company.com. 2005110981 600 180 604800 3600
INFO - Creating RR @ SOA ins01.internal.test. dnsadmin.company.com. 2005110981 600 180 604800 3600 in zone example.com view us
RECORD - *.app1.devqa.diy.example.com. 3600 IN CNAME vm3336.development.lan.
INFO - Creating RR *.app1.devqa.diy CNAME vm3336.development.lan. in zone example.com view us
WARNING - vm3336.development.lan. does not exist.
RECORD - *.jimdo-dev16.diy.example.com. 3600 IN CNAME jimdo-dev16.diy.example.com.
INFO - Creating RR *.jimdo-dev16.diy CNAME jimdo-dev16.diy.example.com. in zone example.com view us
WARNING - jimdo-dev16.diy.example.com. does not exist.

$ ndcli show rr *.jimdo-dev16.diy.example.com. view us
created:2012-11-14 11:03:02
created_by:user
modified:2012-11-14 11:03:02
modified_by:user
rr:*.jimdo-dev16.diy CNAME jimdo-dev16.diy.example.com.
view:us
zone:example.com

$ ndcli modify zone example.com delete view default -q --cleanup
$ ndcli delete zone example.com -q --cleanup
