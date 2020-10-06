# TXT records cannot have "-c" as a string

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr a.a.de. txt cannot have -c as a string in records
INFO - Creating RR a TXT "cannot" "have" "a" "string" "in" "records" comment as in zone a.de

$ ndcli show rr a.a.de.
comment:as
created:2013-01-17 20:01:19
created_by:admin
modified:2013-01-17 20:01:19
modified_by:admin
rr:a TXT "cannot" "have" "a" "string" "in" "records"
zone:a.de

$ ndcli modify zone a.de create view v
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli create rr a.a.de. txt things will happen view v -c "some comment"
INFO - Creating RR a TXT "things" "will" "happen" comment some comment in zone a.de view v

$ ndcli show rr a.a.de. view v
comment:some comment
created:2013-01-17 20:01:19
created_by:admin
modified:2013-01-17 20:01:19
modified_by:admin
rr:a TXT "things" "will" "happen"
view:v
zone:a.de

$ ndcli create rr b.a.de. txt things will happen view v -c some comment view v
INFO - Creating RR b TXT "things" "will" "happen" "view" "v" "comment" comment some in zone a.de view v
$ ndcli show rr b.a.de. view v
comment:some
created:2013-01-17 20:01:19
created_by:admin
modified:2013-01-17 20:01:19
modified_by:admin
rr:b TXT "things" "will" "happen" "view" "v" "comment"
view:v
zone:a.de

$ ndcli modify zone a.de delete view v --cleanup -q
$ ndcli delete zone a.de --cleanup -q
