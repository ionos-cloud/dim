$ ndcli create zone company.com
WARNING - Creating zone company.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone company.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone company.com create view public
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli modify zone company.com rename view default to customer-internal


$ ndcli create zone-group internal
$ ndcli modify zone-group internal add zone company.com view internal

$ ndcli create zone-group public
$ ndcli modify zone-group public add zone company.com view public

$ ndcli create zone-group customer-internal
$ ndcli modify zone-group customer-internal add zone company.com view customer-internal


$ ndcli show zone company.com
created:<some timestamp>
created_by:<some user>
modified:<some timestamp>
modified_by:<some user>
name:company.com
views:3
zone_groups:3

$ ndcli list zone company.com zone-groups
zone-group        view
customer-internal customer-internal
internal          internal
public            public

$ ndcli delete zone-group internal
$ ndcli delete zone-group customer-internal
$ ndcli delete zone-group public

$ ndcli modify zone company.com delete view internal
$ ndcli modify zone company.com delete view public
$ ndcli delete zone company.com
