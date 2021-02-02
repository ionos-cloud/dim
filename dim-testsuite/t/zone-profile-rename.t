$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@company.com

$ ndcli modify zone-profile internal create rr @ NS ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.

$ ndcli modify zone-profile internal create rr @ NS ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.

$ ndcli create zone-profile public primary ns-de.company.de. mail dnsadmin@company.com

$ ndcli modify zone-profile public create rr @ NS ns-de.company.de.
INFO - Creating RR @ NS ns-de.company.de. in zone profile public
WARNING - ns-de.company.de. does not exist.

$ ndcli list zone-profiles
name
internal
public

$ ndcli rename zone-profile internal to intern

$ ndcli list zone-profiles
name 
intern
public

$ ndcli rename zone-profile internal to intern
ERROR - Zone profile internal does not exist

$ ndcli rename zone-profile intern to public
ERROR - Zone profile public already exists

$ ndcli delete zone-profile intern
$ ndcli delete zone-profile public
