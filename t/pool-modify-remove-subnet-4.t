# When a subnet should be removed and there are objects left inside
# fail with an error

$ ndcli create zone-profile internal primary ins01.example.com. mail dnsadmin@example.com
$ ndcli  modify zone-profile internal create rr @ NS ins01.example.com.
INFO - Creating RR @ NS ins01.example.com. in zone profile internal
WARNING - ins01.example.com. does not exist.
$ ndcli modify zone-profile internal create rr @ NS ins02.example.com.
WARNING - The name internal. already existed, creating round robin record
INFO - Creating RR @ NS ins02.example.com. in zone profile internal
WARNING - ins02.example.com. does not exist.

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify container 10.0.0.0/8 set attrs reverse_dns_profile:internal

$ ndcli create pool testpol

$ ndcli modify pool testpol add subnet 10.18.0.128/25
INFO - Created subnet 10.18.0.128/25 in layer3domain default
INFO - Creating zone 0.18.10.in-addr.arpa with profile internal

$ ndcli create rr test.foo.bla. a 10.18.0.131
INFO - Marked IP 10.18.0.131 from layer3domain default as static
INFO - No zone found for test.foo.bla.
INFO - Creating RR 131 PTR test.foo.bla. in zone 0.18.10.in-addr.arpa
WARNING - No forward zone found. Only creating reverse entry.

$ ndcli modify pool testpol remove subnet 10.18.0.128/25 
ERROR - Subnet 10.18.0.128/25 from layer3domain default still contains objects

$ ndcli modify pool testpol remove subnet 10.18.0.128/25 -f -c
INFO - Deleting RR 131 PTR test.foo.bla. from zone 0.18.10.in-addr.arpa
INFO - Freeing IP 10.18.0.131 from layer3domain default
INFO - Deleting RR @ NS ins01.example.com. from zone 0.18.10.in-addr.arpa
INFO - Deleting RR @ NS ins02.example.com. from zone 0.18.10.in-addr.arpa
INFO - Deleting zone 0.18.10.in-addr.arpa

$ ndcli delete pool testpol

$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default

$ ndcli delete zone-profile internal

