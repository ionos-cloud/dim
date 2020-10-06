# If a subnet is removed from a pool with cleanup then PTR,
# PTR referenced A Records, CNAMEs and NS Records should be deleted.

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

$ ndcli modify pool testpol add subnet 10.109.128.0/22
INFO - Created subnet 10.109.128.0/22 in layer3domain default
INFO - Creating zone 128.109.10.in-addr.arpa with profile internal
INFO - Creating zone 129.109.10.in-addr.arpa with profile internal
INFO - Creating zone 130.109.10.in-addr.arpa with profile internal
INFO - Creating zone 131.109.10.in-addr.arpa with profile internal

$ ndcli modify pool testpol remove subnet 10.109.128.0/22 -c -f
INFO - Deleting RR @ NS ins01.example.com. from zone 128.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins02.example.com. from zone 128.109.10.in-addr.arpa
INFO - Deleting zone 128.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins01.example.com. from zone 129.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins02.example.com. from zone 129.109.10.in-addr.arpa
INFO - Deleting zone 129.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins01.example.com. from zone 130.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins02.example.com. from zone 130.109.10.in-addr.arpa
INFO - Deleting zone 130.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins01.example.com. from zone 131.109.10.in-addr.arpa
INFO - Deleting RR @ NS ins02.example.com. from zone 131.109.10.in-addr.arpa
INFO - Deleting zone 131.109.10.in-addr.arpa

$ ndcli delete pool testpol

$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default

$ ndcli delete zone-profile internal

