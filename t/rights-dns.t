$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli login -u dnsadmin -p p
$ ndcli login -u networkadmin -p p
$ ndcli login -u admin -p p
$ ndcli create user-group dns-admins
$ ndcli modify user-group dns-admins grant dns_admin
$ ndcli modify user-group dns-admins add user dnsadmin
$ ndcli create user-group network-admins
$ ndcli modify user-group network-admins grant network_admin
$ ndcli modify user-group network-admins add user networkadmin

$ ndcli login -u networkadmin -p p
$ ndcli modify zone example.com set attrs comment:'test comment'
ERROR - Permission denied (can_manage_zone example.com)

$ ndcli login -u dnsadmin -p p
$ ndcli modify zone example.com set attrs comment:'test comment'

$ ndcli login -u admin -p p
$ ndcli delete zone example.com -q --cleanup
$ ndcli delete user-group dns-admins
$ ndcli delete user-group network-admins
