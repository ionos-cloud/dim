$ ndcli login -u admin -p p
$ ndcli create user-group usergroup
$ ndcli modify user-group usergroup grant dns_update_agent

$ ndcli create pool pool
$ ndcli modify user-group usergroup grant allocate pool

$ ndcli create zone test.com -q
$ ndcli modify zone test.com create view new -q
$ ndcli modify user-group usergroup grant create_rr test.com view default new
$ ndcli modify user-group usergroup grant delete_rr test.com view new

$ ndcli list user-group usergroup rights
action               object
allocate             pool
create_rr            test.com view default
create_rr            test.com view new
delete_rr            test.com view new
dns_update_agent     all
