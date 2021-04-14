$ ndcli create container 10.0.0.0/8
INFO - Creating container 10.0.0.0/8 in layer3domain default

$ ndcli create rr foo.local.lan. a 10.0.0.2
INFO - Marked IP 10.0.0.2 from layer3domain default as static
INFO - No zone found for foo.local.lan.
INFO - No zone found for 2.0.0.10.in-addr.arpa.
WARNING - No record was created because no forward or reverse zone found.

$ ndcli list ips 10.0.0.0/24 status all
INFO - Result for list ips 10.0.0.0/24
WARNING - More results available
ip       status    ptr_target comment
10.0.0.0 Available
10.0.0.1 Available
10.0.0.2 Static
10.0.0.3 Available
10.0.0.4 Available
10.0.0.5 Available
10.0.0.6 Available
10.0.0.7 Available
10.0.0.8 Available
10.0.0.9 Available
