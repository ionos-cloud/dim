# DNS character-strings must be filtered to contain only printable US-ASCII
# characters.
# a-zA-Z0-9,.-;:_#+*~!"$%&/()=?\^<>|{[]}'`@
# or simpler characters from (decimal) 32 to 126.

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli create pool apool vlan 300

$ ndcli modify pool apool add subnet 10.1.64.0/25 gw 10.1.64.127
INFO - Created subnet 10.1.64.0/25 in layer3domain default
WARNING - Creating zone 64.1.10.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

# HINFO Records take exactly 2 Strings
# if only one string is specified -> ERROR
# if a string is oversized -> ERROR
# if more than two Strings -> ERROR

# Impossible to implement, help printed instead
# $ ndcli create rr h1.a.de. hinfo "Dell/i386/E5405"
# ERROR - HINFO Records must have exactly two character-strings

# Impossible to implement, help printed instead
# $ ndcli create rr h1.a.de. hinfo "Dell/i386/E5405" "Dell/i386/E5405" "Dell/i386/E5405"
# ERROR - HINFO Records must have exactly two character-strings

$ ndcli create rr h1.a.de. hinfo "Dell/i386/E5405" "Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars Very long string with more than 255 chars"
ERROR - Invalid os: character string too long

# a complete example as found in the live system
$ ndcli create rr god031.a.de. a 10.1.64.51
INFO - Marked IP 10.1.64.51 from layer3domain default as static
INFO - Creating RR god031 A 10.1.64.51 in zone a.de
INFO - Creating RR 51 PTR god031.a.de. in zone 64.1.10.in-addr.arpa

$ ndcli create rr god031.a.de. hinfo "Dell/i386/E5405" "Linux/debGMX/sarge"
INFO - Creating RR god031 HINFO "Dell/i386/E5405" "Linux/debGMX/sarge" in zone a.de

$ ndcli create rr god031.a.de. txt "X-Status:" "active"
INFO - Creating RR god031 TXT "X-Status:" "active" in zone a.de

$ ndcli create rr god031.a.de. txt "X-Class:" "god"
INFO - Creating RR god031 TXT "X-Class:" "god" in zone a.de
WARNING - The name god031.a.de. already existed, creating round robin record

$ ndcli create rr god031.a.de. txt "X-Loc:" "DE/KA/B7-C-S02-20"
INFO - Creating RR god031 TXT "X-Loc:" "DE/KA/B7-C-S02-20" in zone a.de
WARNING - The name god031.a.de. already existed, creating round robin record

$ ndcli list zone a.de
record zone ttl   type value
@      a.de 86400 SOA   localhost. hostmaster.a.de. 2013010306 14400 3600 605000 86400
god031 a.de       A    10.1.64.51
god031 a.de       TXT  "X-Status:" "active"
god031 a.de       TXT  "X-Class:" "god"
god031 a.de       TXT  "X-Loc:" "DE/KA/B7-C-S02-20"
god031 a.de       HINFO "Dell/i386/E5405" "Linux/debGMX/sarge"

$ ndcli delete rr god031.a.de. txt
ERROR - god031.a.de. TXT is ambiguous

$ ndcli delete rr god031.a.de. hinfo
INFO - Deleting RR god031 HINFO "Dell/i386/E5405" "Linux/debGMX/sarge" from zone a.de

$ ndcli delete rr god031.a.de. a
INFO - Deleting RR 51 PTR god031.a.de. from zone 64.1.10.in-addr.arpa
INFO - Deleting RR god031 A 10.1.64.51 from zone a.de
INFO - Freeing IP 10.1.64.51 from layer3domain default

$ ndcli delete rr god031.a.de. txt "X-Status:" "active"
INFO - Deleting RR god031 TXT "X-Status:" "active" from zone a.de

$ ndcli delete zone a.de -q --cleanup
# FIXME: need to be completed
$ ndcli delete zone 64.1.10.in-addr.arpa -q --cleanup
$ ndcli modify pool apool remove subnet 10.1.64.0/25
$ ndcli delete pool apool
$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default
