# DNS character-strings must be filtered to contain only printable US-ASCII
# characters.
# a-zA-Z0-9,.-;:_#+*~!"$%&/()=?\^<>|{[]}'`@ or
# simpler characters from (decimal) 32 to 126.

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool apool vlan 300

$ ndcli modify pool apool add subnet 10.1.64.0/20 gw 10.1.127.254
INFO - Created subnet 10.1.64.0/20 in layer3domain default
WARNING - Creating zone 64.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 65.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 66.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 67.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 68.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 69.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 70.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 71.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 72.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 73.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 74.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 75.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 76.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 77.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 78.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.
WARNING - Creating zone 79.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

# There can be many TXTs per name
$ ndcli create rr txt.a.de. txt string
INFO - Creating RR txt TXT "string" in zone a.de
$ ndcli create rr txt.a.de. txt "this is a string"
WARNING - The name txt.a.de. already existed, creating round robin record
INFO - Creating RR txt TXT "this is a string" in zone a.de
$ ndcli create rr txt.a.de. txt fuß
ERROR - Invalid character at position 2 in: fuß
$ ndcli create rr txt.a.de. txt 'Quoted " Text'
ERROR - Unescaped quote at position 7 in: Quoted " Text
# fails because of shell escaping
$ ndcli create rr txt.a.de. txt "this is a string with a quote\""
ERROR - Unescaped quote at position 29 in: this is a string with a quote"
$ ndcli create rr txt.a.de. txt 'this is a string with a quote\"'
WARNING - The name txt.a.de. already existed, creating round robin record
INFO - Creating RR txt TXT "this is a string with a quote\"" in zone a.de

# A TXT Record can contain many strings
$ ndcli create rr txt2.a.de. txt "one string" "next string"
INFO - Creating RR txt2 TXT "one string" "next string" in zone a.de

# Can this generate a warning? 
$ ndcli create rr txt3.a.de. txt a text without quotes which probably should have some
INFO - Creating RR txt3 TXT "a" "text" "without" "quotes" "which" "probably" "should" "have" "some" in zone a.de
$ ndcli create rr txt4.a.de. txt 1.2.3.4 a string can also be an ip address
INFO - Creating RR txt4 TXT "1.2.3.4" "a" "string" "can" "also" "be" "an" "ip" "address" in zone a.de

# a strings maximum length is 255 char
# rfc4408 (section 3.1.3), rfc1035
# strings are automatically chopped (with warning)

$ ndcli create rr vl1.a.de. txt "Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars"
WARNING - A TXT record string was longer than 255 characters, it was automatically divided.
INFO - Creating RR vl1 TXT "Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Ver" "y long string with more than 255 chars" in zone a.de

# Some real world examples
$ ndcli create rr a.de. txt google-site-verification=J0NZ2F6kdhXzsguHSKZTm3CWujnrImftkDG3zhz14g0
INFO - Creating RR @ TXT "google-site-verification=J0NZ2F6kdhXzsguHSKZTm3CWujnrImftkDG3zhz14g0" in zone a.de

$ ndcli create rr a.de. txt "v=spf1 ip4:82.165.0.0/16 ip4:195.20.224.0/19 ip4:212.227.0.0/16 ip4:87.106.0.0/16 ip4:217.160.0.0/16 ip4:213.165.64.0/19 ip4:217.72.192.0/20 ip4:74.208.0.0/17 ip4:74.208.128.0/18 ip4:66.236.18.66 ip4:67.88.206.40 ip4:67.88.206.48 ~all"
INFO - Creating RR @ TXT "v=spf1 ip4:82.165.0.0/16 ip4:195.20.224.0/19 ip4:212.227.0.0/16 ip4:87.106.0.0/16 ip4:217.160.0.0/16 ip4:213.165.64.0/19 ip4:217.72.192.0/20 ip4:74.208.0.0/17 ip4:74.208.128.0/18 ip4:66.236.18.66 ip4:67.88.206.40 ip4:67.88.206.48 ~all" in zone a.de
WARNING - The name a.de. already existed, creating round robin record

$ ndcli create rr god031.a.de. a 10.1.73.51
INFO - Marked IP 10.1.73.51 from layer3domain default as static
INFO - Creating RR god031 A 10.1.73.51 in zone a.de
INFO - Creating RR 51 PTR god031.a.de. in zone 73.1.10.in-addr.arpa

$ ndcli create rr god031.a.de. txt "X-Status:" "active"
INFO - Creating RR god031 TXT "X-Status:" "active" in zone a.de

$ ndcli create rr god031.a.de. txt "X-Class:" "god"
INFO - Creating RR god031 TXT "X-Class:" "god" in zone a.de
WARNING - The name god031.a.de. already existed, creating round robin record

$ ndcli create rr god031.a.de. txt "X-Loc:" "DE/KA/B7-C-S02-20"
INFO - Creating RR god031 TXT "X-Loc:" "DE/KA/B7-C-S02-20" in zone a.de
WARNING - The name god031.a.de. already existed, creating round robin record

# FIXME: SOA probablay incomplete
$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA  localhost. hostmaster.a.de. 2012122113 14400 3600 605000 86400
txt    a.de       TXT  "string"
txt    a.de       TXT  "this is a string"
txt2   a.de       TXT  "one string" "next string"
txt3   a.de       TXT  "a" "text" "without" "quotes" "which" "probably" "should" "have" "some"
txt4   a.de       TXT  "1.2.3.4" "a" "string" "can" "also" "be" "an" "ip" "address"
vl1    a.de       TXT  "Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Ver" "y long string with more than 255 chars"
@      a.de       TXT  "google-site-verification=J0NZ2F6kdhXzsguHSKZTm3CWujnrImftkDG3zhz14g0"
@      a.de       TXT  "v=spf1 ip4:82.165.0.0/16 ip4:195.20.224.0/19 ip4:212.227.0.0/16 ip4:87.106.0.0/16 ip4:217.160.0.0/16 ip4:213.165.64.0/19 ip4:217.72.192.0/20 ip4:74.208.0.0/17 ip4:74.208.128.0/18 ip4:66.236.18.66 ip4:67.88.206.40 ip4:67.88.206.48 ~all"
txt    a.de       TXT  "this is a string with a quote\""
god031 a.de       A    10.1.73.51
god031 a.de       TXT  "X-Status:" "active"
god031 a.de       TXT  "X-Class:" "god"
god031 a.de       TXT  "X-Loc:" "DE/KA/B7-C-S02-20"

# deleteing txt records is somewhat aweful
$ ndcli delete rr god031.a.de. txt
ERROR - god031.a.de. TXT is ambiguous
$ ndcli delete rr god031.a.de. a
INFO - Deleting RR god031 A 10.1.73.51 from zone a.de
INFO - Deleting RR 51 PTR god031.a.de. from zone 73.1.10.in-addr.arpa
INFO - Freeing IP 10.1.73.51 from layer3domain default

$ ndcli delete rr god031.a.de. txt "X-Status:" "active"
INFO - Deleting RR god031 TXT "X-Status:" "active" from zone a.de

$ ndcli modify zone a.de create view bla
WARNING - You created a view without specifing a profile, your view is totally empty.
$ ndcli create rr god031.a.de. txt test view view bla fasel view default
WARNING - The name god031.a.de. already existed, creating round robin record
INFO - Creating RR god031 TXT "test" "view" "view" "bla" "fasel" in zone a.de view default

$ ndcli modify zone a.de delete view bla
$ ndcli delete zone a.de -q --cleanup
$ ndcli delete zone 64.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 65.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 66.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 67.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 68.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 69.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 70.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 71.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 72.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 73.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 74.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 75.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 76.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 77.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 78.1.10.in-addr.arpa -q --cleanup
$ ndcli delete zone 79.1.10.in-addr.arpa -q --cleanup
$ ndcli modify pool apool remove subnet 10.1.64.0/20
$ ndcli delete pool apool
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
