# Introducing an individual instace of an outputplugin
#
# the planed usage is to have only one output per database
#
# It takes many zone-groups so that the plugin can make
# sure that only one view of a zone is written to a
# database.
#
# as always, output names are unique
#

# Syntax error
# $ ndcli create output nsia-de.kae.bs plugin pdns-db comment "internal zone data with special information for de.kae.bs goes here" 
# ERROR - You must specify the db-uri to create an output

$ ndcli create output nsia-de.kae.bs plugin pdns-db db-uri "mysql://user:password@localhost:3306/netdot?unix_socket=/tmp/mysql-3306.sock" comment "internal zone data with special information for de.kae.bs goes here"

$ ndcli create output nsia plugin pdns-db db-uri "mysql://user:password@localhost:3306/nsia?unix_socket=/tmp/mysql-3306.sock"

$ ndcli create output nsia plugin pdns-db db-uri "mysql://user:password@localhost:3306/netdot?unix_socket=/tmp/mysql-3306.sock"
ERROR - An output named 'nsia' already exists

# the only thing that can be modified during runtime on an output is the comment
$ ndcli modify output nsia set comment "generic internal zones with no site special information go here"
# $ ndcli modify output nsia set db-uri -> syntax error

$ ndcli create zone-group internal

$ ndcli create zone-group internal-de

$ ndcli modify output nsia-de.kae.bs add zone-group internal

$ ndcli modify output nsia-de.kae.bs add zone-group internal-de

$ ndcli modify zone-group internal set comment "Zone group for all internal zones except DataCenter local Zones"

$ ndcli list outputs
name           plugin
nsia-de.kae.bs pdns-db
nsia           pdns-db

$ ndcli list outputs --status
name           plugin  pending_records last_run status
nsia           pdns-db               0          
nsia-de.kae.bs pdns-db               0          

# This output cannot be reproduced in runtest:
# name           plugin  pending_records last_run            status
# nsia-de.kae.bs pdns-db               0 2013-02-01 12:35:01 ok
# nsia           pdns-db             135                     

$ ndcli show output nsia
name:nsia
type:pdns-db
created:2012-11-14 11:03:02
db_uri:mysql://user:password@localhost:3306/nsia?unix_socket=/tmp/mysql-3306.sock
created_by:user
modified:2012-11-14 11:03:02
modified_by:user
comment:generic internal zones with no site special information go here

$ ndcli show output nsia-de.kae.bs
name:nsia-de.kae.bs
type:pdns-db
created:2012-11-14 11:03:02
db_uri:mysql://user:password@localhost:3306/netdot?unix_socket=/tmp/mysql-3306.sock
created_by:user
modified:2012-11-14 11:03:02
modified_by:user
comment:internal zone data with special information for de.kae.bs goes here
# This output cannot be reproduced in runtest:
# pending_changes:0
# last_run:2013-01-12 09:13:01
# last_run_status:

# last_run_status: Should be the status of the last run, for example "never run" or "5 records inserted, 3 deleted in 1 second", "could not connect to database"

$ ndcli list output nsia-de.kae.bs
zone-group  comment
internal    Zone group for all internal zones except DataCenter local Zones
internal-de

$ ndcli modify output nsia-de.kae.bs remove zone-group internal-de

$ ndcli modify output nsia-de.kae.bs remove zone-group internal

$ ndcli rename output nsia-de.kae.bs to nsia-de-kae-bs

$ ndcli delete zone-group internal

$ ndcli list output nsia-de-kae-bs
zone-group  comment

$ ndcli delete output nsia-de-kae-bs

$ ndcli delete output nsia
