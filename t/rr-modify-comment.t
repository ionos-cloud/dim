# To be able to modify the comment of RR,
# ndcli modify rr is introduced

$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr a.de. mx 10 m.a.de.
INFO - Creating RR @ MX 10 m.a.de. in zone a.de
WARNING - m.a.de. does not exist.

$ ndcli modify rr a.de. -c "some comment"
created:2012-11-14 11:03:02
created_by:user
modified:2012-11-14 11:03:03
modified_by:user
comment:some comment
rr:@ MX 10 m.a.de.
zone:a.de

$ ndcli create rr a.de. a 1.2.3.4
INFO - Marked IP 1.2.3.4 from layer3domain default as static
INFO - Creating RR @ A 1.2.3.4 in zone a.de
INFO - No zone found for 4.3.2.1.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli modify rr a.de. -c "a comment"
ERROR - a.de. is ambiguous

$ ndcli modify rr a.de. a -c "comments are fully utf8 enabled فارسی درى"
created:2012-11-14 11:03:03
created_by:user
modified:2012-11-14 11:03:04
modified_by:user
comment:comments are fully utf8 enabled فارسی درى
zone:a.de
rr:@ A 1.2.3.4

$ ndcli modify rr a.de. a 1.2.3.4 -c "another comment"
created:2012-11-14 11:03:03
created_by:user
modified:2012-11-14 11:03:05
modified_by:user
comment:another comment
zone:a.de
rr:@ A 1.2.3.4

$ ndcli delete zone a.de -q --cleanup

