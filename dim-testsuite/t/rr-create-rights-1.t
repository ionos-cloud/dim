$ ndcli login -u user-mam -p p
$ ndcli login -u bigadmin -p p
$ ndcli login -u admin -p p
$ ndcli create user-group dns-admins
$ ndcli create user-group network-admins
$ ndcli modify user-group dns-admins grant dns_admin
$ ndcli modify user-group network-admins grant network_admin
$ ndcli modify user-group network-admins add user bigadmin
$ ndcli modify user-group dns-admins add user bigadmin

$ ndcli login -u bigadmin -p p
$ ndcli create user-group dns-mam
$ ndcli create user-group ipam-mam
$ ndcli modify user-group dns-mam add user user-mam
$ ndcli modify user-group ipam-mam add user user-mam

$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone company.com
WARNING - Creating zone company.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone company.net
WARNING - Creating zone company.net without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone company.com create view public
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone company.com rename view default to internal

$ ndcli modify user-group dns-mam grant create_rr example.com
$ ndcli modify user-group dns-mam grant create_rr company.com view internal

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool pool-mam
$ ndcli modify pool pool-mam add subnet 10.30.0.0/25
INFO - Created subnet 10.30.0.0/25 in layer3domain default
WARNING - Creating zone 0.30.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create pool pool-non-mam
$ ndcli modify pool pool-non-mam add subnet 10.30.0.128/25
INFO - Created subnet 10.30.0.128/25 in layer3domain default

$ ndcli modify user-group ipam-mam grant allocate pool-mam

$ ndcli list user-group dns-mam rights
action   object
create_rr example.com
create_rr company.com view internal

$ ndcli list user-group ipam-mam rights
action   object
allocate pool-mam

$ ndcli login -u user-mam -p p

$ ndcli create rr foo.example.com. a 10.30.0.2
INFO - Marked IP 10.30.0.2 from layer3domain default as static
INFO - Creating RR foo A 10.30.0.2 in zone example.com
INFO - Creating RR 2 PTR foo.example.com. in zone 0.30.10.in-addr.arpa

$ ndcli create rr bar.example.com. a 10.30.0.130
ERROR - Permission denied (can_allocate pool-non-mam)

$ ndcli login -u bigadmin -p p
$ ndcli create rr batz.example.com. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR batz A 1.2.3.4 in zone example.com
INFO - No zone found for 4.3.2.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli login -u user-mam -p p
$ ndcli create rr one.company.com. a 10.30.0.3 view internal
INFO - Marked IP 10.30.0.3 from layer3domain default as static
INFO - Creating RR one A 10.30.0.3 in zone company.com view internal
INFO - Creating RR 3 PTR one.company.com. in zone 0.30.10.in-addr.arpa

$ ndcli create rr two.company.com. a 10.30.0.4 view public
ERROR - Permission denied (can_create_rr zone company.com view public)

$ ndcli create rr 10.30.0.4 ptr two.company.com.
ERROR - A view must be selected from: internal public

$ ndcli create rr 10.30.0.4 ptr two.company.com. view internal
INFO - Marked IP 10.30.0.4 from layer3domain default as static
INFO - Creating RR 4 PTR two.company.com. in zone 0.30.10.in-addr.arpa
INFO - Creating RR two A 10.30.0.4 in zone company.com view internal

$ ndcli create rr 10.30.0.5 ptr two.company.net.
ERROR - Permission denied (can_create_rr zone company.net)

$ ndcli create rr 10.30.0.5 ptr five.example.com.
INFO - Marked IP 10.30.0.5 from layer3domain default as static
INFO - Creating RR five A 10.30.0.5 in zone example.com
INFO - Creating RR 5 PTR five.example.com. in zone 0.30.10.in-addr.arpa

$ ndcli create rr 10.30.0.132 ptr six.example.com.
ERROR - Permission denied (can_allocate pool-non-mam)

$ ndcli login -u bigadmin -p p
$ ndcli delete zone example.com -q --cleanup
$ ndcli modify zone company.com delete view public -q --cleanup
$ ndcli delete zone company.com -q --cleanup

$ ndcli modify pool pool-mam remove subnet 10.30.0.0/25
$ ndcli delete pool pool-mam

$ ndcli modify pool pool-non-mam remove subnet 10.30.0.128/25
INFO - Deleting zone 0.30.10.in-addr.arpa
$ ndcli delete pool pool-non-mam

$ ndcli delete user-group dns-mam
$ ndcli delete user-group ipam-mam
