# It must not happen that a zone is present with different views
# multiple times through different zone-groups.
#

$ ndcli create output nsia plugin pdns-db db-uri "mysql://user:password@localhost:3306/netdot?unix_socket=/tmp/mysql-3306.sock" comment "generic internal zones with no site special information go here"

$ ndcli create zone-group internal

$ ndcli create zone-group public

$ ndcli create zone zone.de
WARNING - Creating zone zone.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone 2and2.de
WARNING - Creating zone 2and2.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone 2and2.de create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone 2and2.de rename view default to public

$ ndcli modify zone-group internal add zone 2and2.de view internal
$ ndcli modify zone-group internal add zone zone.de
$ ndcli modify zone-group public add zone zone.de

$ ndcli modify output nsia add zone-group internal

# This is OK, because web.de has the same view in all groups
$ ndcli modify output nsia add zone-group public

$ ndcli modify zone-group public add zone 2and2.de view public
ERROR - You can not add 2and2.de view public to the zone-group public because it breaks the output nsia.

# When deleteing a zone from a zone group, there is no need for
# specifing the view, because there can only be one.
$ ndcli modify zone-group internal remove zone 1und1.de

$ ndcli modify output nsia remove zone-group public

$ ndcli modify zone-group public add zone 2and2.de view public

$ ndcli modify zone-group internal add zone 2and2.de view internal

$ ndcli modify output nsia add zone-group public
ERROR - zone 2and2.de view internal already defined for output nsia.

$ ndcli modify output nsia remove zone-group public
$ ndcli modify output nsia remove zone-group internal
$ ndcli delete zone-group internal
$ ndcli delete zone-group public

$ ndcli delete output nsia

$ ndcli delete zone zone.de
$ ndcli modify zone 2and2.de delete view internal
$ ndcli delete zone 2and2.de

