# This is an overview of the planed concept, no use case.
#
# The proposed "retire zone" feature will be discarded, an
# implementation with differentiated rights is desired.
#
# The DNS reverse zone need to be editable for every authenticated user
# because it is foreseeable that there will be no clear concept for
# ".web.de" rev entries will only go into this reverse zone and ".schlund.de"
# go only into that reverse zone.
#
# Creation of reverse Zones also needs special handling, because reverse
# zones are automatically created when the network administrators add subnets
# to pools.
#
# In an ideal world we would replace the allocate right with allocate and free
# and could emulate the "retire" also for pools. This probably needs some
# communication with the network department.
#
# The role network admin can
# - do the pool and container management stuff as before
# - create reverse zones (because they will refuse to delete reverse
#   zones, they won't get the right)
#
# The role dns admin can
# - create/delete reverse zones
# - create/delete forward zones
# - create/delete zone views
# - create/delete zone groups
# - create/delete RRs in every zone
# - create/delete outputs
#
# It feels strange to call these two roles, but I don't want to mix up
# rights and roles
#
# The role dns_create_rr can
# - create RRs in the zones for which the right is valid
#
# The role dns_delete_rr can
# - delete RRs in the zones for which the right is valid
#
# So if there is no group all_authenticated_users, how to I grant
# everyone the right to delete records from e.g. schlund.de view internal?
#
