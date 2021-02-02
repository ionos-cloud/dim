# Introducing an individual instace of an outputplugin
#
# the planed usage is to have only one output per database
#
# It takes many zone-groups so that the plugin can make
# sure that only one view of a zone is written to a
# database.
#
# The plugin code is inside the dim sever contrary to the
# bind plugin.
#
# The plugin works incrementally. That means, if one record
# changes in a 5 Mio Records Zone, only the SOA and the
# changed record are updated in the pdns database.
#
# Some sort of a queueing device with reliable ordering is needed.
# A quick and easy implementation would be a database table where
# pending changes are written to.
#
# Error Handling like incorrect db-uris, died Database Daemons,
# incorrect permissons on pdns db tables and so on must be
# carefully logged into the dim server log.
#
# Special care must be taken of the situation where a new zone is
# added to an output, but the zone already exists in the pdns database.
# In this situation the outputplugin should not modify the zone data,
# but write an errormessage to the log, indicating that administrtors
# intervention is needed.
#
# To ease the implementation of some of these features, it could be
# desireable to extend the "domains" table to store wether a zone
# has been created by dim or made its way somehow differently into the
# system.
# 
