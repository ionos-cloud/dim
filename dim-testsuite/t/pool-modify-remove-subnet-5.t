$ ndcli create zone-profile internal primary ins01.example.com. mail dnsadmin@example.com
$ ndcli  modify zone-profile internal create rr @ NS ins01.example.com.
INFO - Creating RR @ NS ins01.example.com. in zone profile internal
WARNING - ins01.example.com. does not exist.

$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default
$ ndcli modify container 10.0.0.0/8 set attrs reverse_dns_profile:internal

$ ndcli create pool testpol

$ ndcli modify pool testpol add subnet 10.0.0.0/24
INFO - Created subnet 10.0.0.0/24 in layer3domain default
INFO - Creating zone 0.0.10.in-addr.arpa with profile internal

$ ndcli modify pool testpol remove subnet 10.0.0.0/24 -n
INFO - Dryrun mode, no data will be modified
INFO - Deleting RR @ NS ins01.example.com. from zone 0.0.10.in-addr.arpa
INFO - Deleting zone 0.0.10.in-addr.arpa

$ ndcli modify pool testpol remove subnet 10.0.0.0/24 -f
# The reverse zone is left intact.

$ ndcli delete pool testpol

$ ndcli delete container 10.0.0.0/8
INFO - Deleting container 10.0.0.0/8 from layer3domain default

$ ndcli delete zone-profile internal
