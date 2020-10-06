# zone-group modify must take care of overlapping Zone.
#
# It must not be possible to add zone a view a and
# a view b of the same zone.
#

$ ndcli create zone-group internal

$ ndcli create zone company.com
WARNING - Creating zone company.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone company.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone company.com rename view default to public

$ ndcli modify zone-group internal add zone company.com view internal

$ ndcli modify zone-group internal add zone company.com view public
ERROR - company.com view internal already in zone-group internal

$ ndcli list zone-group internal
zone       view
company.com   internal

$ ndcli delete zone-group internal

$ ndcli modify zone company.com delete view public
$ ndcli delete zone company.com
