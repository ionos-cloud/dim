# Maybe this sounds megalomaniac to you but I think that being able
# to manage a derivative of the root zone can save a lot of work
# when one also has to manage recursor with a long forward.zones

$ ndcli create zone .
WARNING - Creating zone . without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create zone-group internal
$ ndcli modify zone-group internal add zone .

$ ndcli create output nsia plugin pdns-db db-uri "mysql://user:password@localhost:3306/netdot?unix_socket=/tmp/mysql-3306.sock"

$ ndcli modify output nsia add zone-group internal

# This is the offical part of the root zone
$ ndcli create rr . ttl 518400 ns a.root-servers.net.
INFO - Creating RR @ 518400 NS a.root-servers.net. in zone .
WARNING - a.root-servers.net. does not exist.

$ ndcli create rr . ttl 518400 a 198.41.0.4
INFO - Marked IP 198.41.0.4 from layer3domain default as static
INFO - Creating RR @ 518400 A 198.41.0.4 in zone .
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr . ttl 518400 aaaa 2001:503:ba3e:0:0:0:2:30
INFO - Marked IP 2001:503:ba3e::2:30 from layer3domain default as static
INFO - Creating RR @ 518400 AAAA 2001:503:ba3e::2:30 in zone .
WARNING - No reverse zone found. Only creating forward entry.

# This is the stuff that simplifies recursor management
$ ndcli create rr 17.172.in-addr.arpa. ttl 86400 NS webdc01.company.local.
INFO - Creating RR 17.172.in-addr.arpa 86400 NS webdc01.company.local. in zone .
WARNING - webdc01.company.local. does not exist.

# The data in mysql://localhost:3306/netdot should be
# domains
# name type
# ""   NATIVE   <- "" is an empty string, but NOT Null
#
# records
# name                ttl    type content
# ""                  518400 NS   a.root-servers.net.
# ""                  518400 A    198.41.0.4
# ""                  518400 AAAA 2001:503:ba3e:0:0:0:2:30
# 17.172.in-addr.arpa 86400  NS   webdc01.company.local.

$ ndcli delete output nsia

$ ndcli delete zone-group internal

$ ndcli delete zone . -q --cleanup
