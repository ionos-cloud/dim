$ ndcli create zone-profile internal primary ins01.internal.test. mail dnsadmin@company.com
$ ndcli modify zone-profile internal create rr @ NS ins01.internal.test.
INFO - Creating RR @ NS ins01.internal.test. in zone profile internal
WARNING - ins01.internal.test. does not exist.
$ ndcli modify zone-profile internal create rr @ NS ins02.internal.test.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.internal.test. in zone profile internal
WARNING - ins02.internal.test. does not exist.
$ ndcli delete zone-profile internal
