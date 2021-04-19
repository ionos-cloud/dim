$ ndcli create zone a.de -q

$ ndcli create rr a.de. txt '\"'
INFO - Creating RR @ TXT "\"" in zone a.de
$ ndcli delete rr -n a.de. txt '\"'
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ TXT "\"" from zone a.de
$ ndcli delete rr -n a.de. txt "\\\""
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ TXT "\"" from zone a.de
$ ndcli delete rr -n a.de. txt \"\\\"\"
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ TXT "\"" from zone a.de


$ ndcli create rr a.de. txt '\" \"'
WARNING - The name a.de. already existed, creating round robin record
INFO - Creating RR @ TXT "\" \"" in zone a.de
$ ndcli delete rr -n a.de. txt '\" \"'
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ TXT "\" \"" from zone a.de
$ ndcli delete rr -n a.de. txt "\\\" \\\""
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ TXT "\" \"" from zone a.de
$ ndcli delete rr -n a.de. txt \"\\\"\ \\\"\"
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ TXT "\" \"" from zone a.de
