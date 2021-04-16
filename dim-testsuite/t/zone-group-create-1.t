# Introducing zone-groups. A zone-group bundles many zones to
# make the configuration output-plugins easier.
#
# Zone-groups only hold zones. No nesting of zone-groups is
# desired.
#
# A zone can be in many zone-groups.
#
# A zone-group can only contain one view of zone.
#
# Zone-group names are unique

$ ndcli create zone-group internal

$ ndcli create zone-group internal
ERROR - A zone-group named 'internal' already exists

$ ndcli create zone internal.test
WARNING - Creating zone internal.test without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone company.com
WARNING - Creating zone company.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone company.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone company.com rename view default to public

$ ndcli modify zone-group internal add zone internal.test

$ ndcli modify zone-group internal add zone company.com
ERROR - A view must be selected from: internal public

$ ndcli modify zone-group internal add zone company.com view internal

$ ndcli show zone-group internal
created:2012-11-14 11:03:02
created_by:admin
modified:2012-11-14 11:03:03
modified_by:admin

# Comments would be useful
# and yes, I think modify is enough...
$ ndcli modify zone-group internal set comment "Zone group for all internal zones except DataCenter local Zones"

$ ndcli show zone-group internal
comment:Zone group for all internal zones except DataCenter local Zones
created:2012-11-14 11:03:02
created_by:admin
modified:2012-11-14 11:03:04
modified_by:admin

$ ndcli list zone-group internal
zone       view
company.com   internal
internal.test default

$ ndcli list zone-group internal -H
company.com	internal
internal.test	default

# This should only work if the zone-group is not connected to any output-plugin
$ ndcli delete zone-group internal

$ ndcli delete zone internal.test
$ ndcli modify zone company.com delete view public
$ ndcli delete zone company.com
