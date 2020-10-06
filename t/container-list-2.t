# list containers should not mix IP versions
$ ndcli create container 0.0.0.0/8 comment:reserved reverse_dns_profile:internal source:RFC5735
INFO - Creating container 0.0.0.0/8 in layer3domain default
$ ndcli create rr localhost.server.lan. aaaa ::1
INFO - Marked IP ::1 from layer3domain default as static
INFO - No zone found for localhost.server.lan.
INFO - No zone found for 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa.
WARNING - No record was created because no forward or reverse zone found.
$ ndcli list containers 0.0.0.0/8
0.0.0.0/8 (Container) comment:reserved reverse_dns_profile:internal source:RFC5735
  0.0.0.0/8 (Available)
