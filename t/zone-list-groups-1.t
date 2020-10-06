# Need an easier way to see who has rights on a specific zone
$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone company.com
WARNING - Creating zone company.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone company.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone company.com create view public
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone company.com delete view default

# Yes, we should think about replacing all occurences of "group" in the grammar
# with "user-group"

$ ndcli create user-group DNS-ITO1
$ ndcli create user-group DNS-ITO2

$ ndcli modify user-group DNS-ITO1 grant create_rr example.com
$ ndcli modify user-group DNS-ITO1 grant create_rr company.com view internal
$ ndcli modify user-group DNS-ITO1 grant delete_rr example.com
$ ndcli modify user-group DNS-ITO1 grant delete_rr company.com view internal

$ ndcli modify user-group DNS-ITO2 grant delete_rr company.com view public
$ ndcli modify user-group DNS-ITO2 grant delete_rr company.com view internal
$ ndcli modify user-group DNS-ITO2 grant delete_rr example.com

$ ndcli list user-group DNS-ITO1 rights
action    object
create_rr company.com view internal
delete_rr company.com view internal
create_rr example.com
delete_rr example.com

$ ndcli list zone example.com rights
action    object group
create_rr example.com DNS-ITO1
delete_rr example.com DNS-ITO1
delete_rr example.com DNS-ITO2

$ ndcli list zone company.com view internal rights
action    object                 group
create_rr company.com view internal DNS-ITO1
delete_rr company.com view internal DNS-ITO1
delete_rr company.com view internal DNS-ITO2

$ ndcli list zone company.com view public rights
action    object               group
delete_rr company.com view public DNS-ITO2

$ ndcli list zone company.com rights
action    object                 group
create_rr company.com view internal DNS-ITO1
delete_rr company.com view internal DNS-ITO1
delete_rr company.com view internal DNS-ITO2
delete_rr company.com view public   DNS-ITO2

$ ndcli modify zone company.com delete view internal
$ ndcli delete zone company.com
$ ndcli delete zone example.com
