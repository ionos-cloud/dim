# The idea is to extend the list rrs command to be able
# to see records and be able to select them by type
#
# ndcli list rrs example.com    # shall list all @ records in example.com
# ndcli list rrs example.com ns # shall list all @ ns records in example.com
# ndcli list rrs w*.example.com # shall list all records matching w*.example.com

$ ndcli create zone example.com
WARNING - Creating zone example.com without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify zone example.com create view internal
WARNING - You created a view without specifing a profile, your view is totally empty.

$ ndcli modify zone example.com rename view default to public

$ ndcli create rr example.com. NS ns.example.com. view public
INFO - Creating RR @ NS ns.example.com. in zone example.com view public
WARNING - ns.example.com. does not exist.

$ ndcli create rr example.com. NS ins01.internal.test. view internal
INFO - Creating RR @ NS ins01.internal.test. in zone example.com view internal
WARNING - ins01.internal.test. does not exist.

$ ndcli create rr example.com. NS ns2.example.com. view public
WARNING - The name example.com. already existed, creating round robin record
INFO - Creating RR @ NS ns2.example.com. in zone example.com view public
WARNING - ns2.example.com. does not exist.

$ ndcli create rr example.com. A 212.217.2.3 view public
INFO - Marked IP 212.217.2.3 from layer3domain default as static
INFO - Creating RR @ A 212.217.2.3 in zone example.com view public
INFO - No zone found for 3.2.217.212.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr www.example.com. A 212.217.2.3 view public
INFO - Creating RR www A 212.217.2.3 in zone example.com view public
INFO - No zone found for 3.2.217.212.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr example.com. A 172.19.0.2 view internal
INFO - Marked IP 172.19.0.2 from layer3domain default as static
INFO - Creating RR @ A 172.19.0.2 in zone example.com view internal
INFO - No zone found for 2.0.19.172.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr www.example.com. A 172.19.0.2 view internal
INFO - Creating RR www A 172.19.0.2 in zone example.com view internal
INFO - No zone found for 2.0.19.172.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli list rrs example.com NS
INFO - Result for list rrs example.com
record zone        view     ttl type value
@      example.com internal     NS   ins01.internal.test.
@      example.com public       NS   ns.example.com.
@      example.com public       NS   ns2.example.com.

$ ndcli list rrs example.com
INFO - Result for list rrs example.com
record zone       view     ttl   type value
@      example.com internal 86400 SOA  localhost. hostmaster.example.com. 2013040904 14400 3600 605000 86400
@      example.com internal       NS   ins01.internal.test.
@      example.com internal       A    172.19.0.2
@      example.com public   86400 SOA  localhost. hostmaster.example.com. 2013040905 14400 3600 605000 86400
@      example.com public         NS   ns.example.com.
@      example.com public         NS   ns2.example.com.
@      example.com public         A    212.217.2.3

$ ndcli list rrs w*.example.com
INFO - Result for list rrs w*.example.com
record zone       view     ttl type value
www    example.com internal     A    172.19.0.2
www    example.com public       A    212.217.2.3

$ ndcli modify zone example.com delete view internal -q --cleanup
$ ndcli delete zone example.com -q --cleanup
