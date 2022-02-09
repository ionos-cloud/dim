# Check edge cases related to quoting

$ ndcli create zone a.de -q
$ ndcli create rr t.a.de. txt '"'
ERROR - Unescaped quote at position 0 in: "
$ ndcli create rr t.a.de. txt '\"'
INFO - Creating RR t TXT "\"" in zone a.de
$ ndcli create rr t.a.de. txt '\"\\\223'
WARNING - The name t.a.de. already existed, creating round robin record
INFO - Creating RR t TXT "\"\\\223" in zone a.de
$ ndcli create rr t.a.de. txt a
WARNING - The name t.a.de. already existed, creating round robin record
INFO - Creating RR t TXT "a" in zone a.de
$ ndcli list rrs t.a.de.
INFO - Result for list rrs t.a.de.
record zone view    ttl type value
t      a.de default     TXT  "\""
t      a.de default     TXT  "\"\\\223"
t      a.de default     TXT  "a"
$ ndcli delete rr t.a.de. txt '"'
ERROR - Expected " at the end of: "
$ ndcli delete rr t.a.de. txt '\"'
INFO - Deleting RR t TXT "\"" from zone a.de
$ ndcli list rrs t.a.de.
INFO - Result for list rrs t.a.de.
record zone view    ttl type value
t      a.de default     TXT  "\"\\\223"
t      a.de default     TXT  "a"
