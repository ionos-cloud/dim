# rfc 3403
# at the moment I dont want to put effort in testing out rfc3403 limits
#
# Format in short:
# ORDER PREFERENCE FLAGS SERVICES REGEXP REPLACEMENT
# 
# ORDER      16-bit unsigned int
# PREFERENCE 16-bit unsigned int
# FLAGS      character-string
# SERVICES   character-string
# REGEXP     character-string

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.


# When the strings are written into the powerdns db, we probably need
# to check if there are still enough \ and !

$ ndcli create rr 4.0.4.4.4.7.3.1.9.1.2.7.4.9.enum.a.de. naptr 100 10 "u" "E2U+voice:sip" "!^[+\\*]*(492222948[[:digit:]]{6})!sip:00\\1@sip.web.de!"
ERROR - Invalid escape sequence: \*]*

$ ndcli create rr 4.0.4.4.4.7.3.1.9.1.2.7.4.9.enum.a.de. naptr 100 10 "u" "E2U+voice:sip" "!^[+\\\\.*]*(492222948[[:digit:]]{6})!sip:00\\\\1@sip.web.de!"
INFO - Creating RR 4.0.4.4.4.7.3.1.9.1.2.7.4.9.enum NAPTR 100 10 "u" "E2U+voice:sip" "!^[+\\.*]*(492222948[[:digit:]]{6})!sip:00\\1@sip.web.de!" . in zone a.de

# Wohow our first wildcard record! ;-)
# The shell will not mess with our \ characters if we use ' instead of "
$ ndcli create rr '*.4.7.3.1.9.1.2.7.4.9.enum.a.de.' naptr 100 10 "" "E2U+voice:sip" '!^[+\\.*]*(4912123[[:digit:]]{6})!sip:00\\1@sip.web.de!'
INFO - Creating RR *.4.7.3.1.9.1.2.7.4.9.enum NAPTR 100 10 "" "E2U+voice:sip" "!^[+\\.*]*(4912123[[:digit:]]{6})!sip:00\\1@sip.web.de!" . in zone a.de

$ ndcli delete zone a.de --cleanup -q
