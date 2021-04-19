# ndcli delete rr <name> <typ> [<value>] [[[-R|--recursive]|--force] [--keep-ip-reservation]|[-n]]
# Delete records referenced from more than one view or zone
# All cross zone recursive deletes are allowed.
#
# Sorry guys, I just have added "if the view being modfied is named other than 'default'
# print its name"

$ ndcli create container 9.9.0.0/16 rir:ripe
INFO - Creating container 9.9.0.0/16 in layer3domain default
$ ndcli create container 8.8.0.0/16 rir:arin
INFO - Creating container 8.8.0.0/16 in layer3domain default

$ ndcli create pool example-pub-eu vlan 301
$ ndcli modify pool example-pub-eu add subnet 9.9.101.128/25 gw 9.9.101.129
INFO - Created subnet 9.9.101.128/25 in layer3domain default
WARNING - Creating zone 101.9.9.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create pool example-pub-us vlan 576
$ ndcli modify pool example-pub-us add subnet 8.8.3.64/26 gw 8.8.3.65
INFO - Created subnet 8.8.3.64/26 in layer3domain default
WARNING - Creating zone 3.8.8.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone example.com create view us
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli create rr www.example.com. a 8.8.3.67 view us
INFO - Marked IP 8.8.3.67 from layer3domain default as static
INFO - Creating RR www A 8.8.3.67 in zone example.com view us
INFO - Creating RR 67 PTR www.example.com. in zone 3.8.8.in-addr.arpa

$ ndcli create rr w3.example.com. a 8.8.3.69 view us
INFO - Marked IP 8.8.3.69 from layer3domain default as static
INFO - Creating RR w3 A 8.8.3.69 in zone example.com view us
INFO - Creating RR 69 PTR w3.example.com. in zone 3.8.8.in-addr.arpa

$ ndcli create rr www.example.com. a 9.9.101.140 view default
INFO - Marked IP 9.9.101.140 from layer3domain default as static
INFO - Creating RR www A 9.9.101.140 in zone example.com view default
INFO - Creating RR 140 PTR www.example.com. in zone 101.9.9.in-addr.arpa

$ ndcli modify zone example.com rename view default to eu

$ ndcli create rr w3.example.com. a 8.8.3.69 view eu
INFO - Creating RR w3 A 8.8.3.69 in zone example.com view eu
INFO - 69.3.8.8.in-addr.arpa. PTR w3.example.com. already exists

$ ndcli create rr web.example.com. cname www view eu
INFO - Creating RR web CNAME www in zone example.com view eu

$ ndcli delete rr w3.example.com.
ERROR - A view must be selected from: eu us

$ ndcli delete rr w3.example.com. a 8.8.3.69
ERROR - A view must be selected from: eu us

$ ndcli delete rr w3.example.com. view us -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR w3 A 8.8.3.69 from zone example.com view us

$ ndcli delete rr w3.example.com. a 8.8.3.69 view us
INFO - Deleting RR w3 A 8.8.3.69 from zone example.com view us

$ ndcli delete rr w3.example.com. view eu -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR w3 A 8.8.3.69 from zone example.com view eu
INFO - Deleting RR 69 PTR w3.example.com. from zone 3.8.8.in-addr.arpa
INFO - Freeing IP 8.8.3.69 from layer3domain default

$ ndcli delete rr www.example.com. view us -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR www A 8.8.3.67 from zone example.com view us
INFO - Deleting RR 67 PTR www.example.com. from zone 3.8.8.in-addr.arpa
INFO - Freeing IP 8.8.3.67 from layer3domain default

$ ndcli delete rr www.example.com. a 8.8.3.67 view us -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR www A 8.8.3.67 from zone example.com view us
INFO - Deleting RR 67 PTR www.example.com. from zone 3.8.8.in-addr.arpa
INFO - Freeing IP 8.8.3.67 from layer3domain default

$ ndcli delete rr www.example.com. view eu -n -R
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR www A 9.9.101.140 from zone example.com view eu
INFO - Deleting RR web CNAME www from zone example.com view eu
INFO - Deleting RR 140 PTR www.example.com. from zone 101.9.9.in-addr.arpa
INFO - Freeing IP 9.9.101.140 from layer3domain default

$ ndcli delete rr www.example.com. a 9.9.101.140 view eu -n -R
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR www A 9.9.101.140 from zone example.com view eu
INFO - Deleting RR web CNAME www from zone example.com view eu
INFO - Deleting RR 140 PTR www.example.com. from zone 101.9.9.in-addr.arpa
INFO - Freeing IP 9.9.101.140 from layer3domain default

$ ndcli create zone noview.com
WARNING - Creating zone noview.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr www.noview.com. cname www.example.com.
INFO - Creating RR www CNAME www.example.com. in zone noview.com

$ ndcli delete rr www.example.com. view eu -R
INFO - Deleting RR www A 9.9.101.140 from zone example.com view eu
INFO - Deleting RR web CNAME www from zone example.com view eu
INFO - Deleting RR www CNAME www.example.com. from zone noview.com
INFO - Deleting RR 140 PTR www.example.com. from zone 101.9.9.in-addr.arpa
INFO - Freeing IP 9.9.101.140 from layer3domain default

$ ndcli create zone view.com
WARNING - Creating zone view.com without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli modify zone view.com create view one
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create rr www.view.com. cname www.example.com.
ERROR - A view must be selected from: default one
$ ndcli create rr www.view.com. cname w3.example.com. view default
INFO - Creating RR www CNAME w3.example.com. in zone view.com view default
$ ndcli create rr www.view.com. cname w3.example.com. view one
INFO - Creating RR www CNAME w3.example.com. in zone view.com view one

$ ndcli delete rr w3.example.com. view eu -R
INFO - Deleting RR w3 A 8.8.3.69 from zone example.com view eu
INFO - Deleting RR www CNAME w3.example.com. from zone view.com view default
INFO - Deleting RR www CNAME w3.example.com. from zone view.com view one
INFO - Deleting RR 69 PTR w3.example.com. from zone 3.8.8.in-addr.arpa
INFO - Freeing IP 8.8.3.69 from layer3domain default

$ ndcli delete zone noview.com -q --cleanup

$ ndcli modify zone view.com delete view default --cleanup -q
$ ndcli delete zone view.com --cleanup -q

$ ndcli modify zone example.com delete view eu -q --cleanup
$ ndcli delete zone example.com --cleanup -q

$ ndcli modify pool example-pub-us remove subnet 8.8.3.64/26
INFO - Deleting zone 3.8.8.in-addr.arpa
$ ndcli delete pool example-pub-us

$ ndcli modify pool example-pub-eu remove subnet 9.9.101.128/25
INFO - Deleting zone 101.9.9.in-addr.arpa
$ ndcli delete pool example-pub-eu

$ ndcli delete container 8.8.0.0/16
INFO - Deleting container 8.8.0.0/16 from layer3domain default
$ ndcli delete container 9.9.0.0/16
INFO - Deleting container 9.9.0.0/16 from layer3domain default
