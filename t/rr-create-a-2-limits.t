$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create rr a..a.de. a 1.2.3.4
ERROR - Invalid name: a..a.de.
$ ndcli create rr abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklmn.a.de. a 1.2.3.4
ERROR - Invalid name: abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklmn.a.de.
$ ndcli create rr abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.a.de. a 1.2.3.4 -q
$ ndcli create rr abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdabc.a.de. a 1.2.3.5
ERROR - Field name exceeds maximum length 254
$ ndcli create rr bcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefg.a.de. a 1.2.3.5 -q
$ ndcli list zone a.de
record                                                             zone ttl   type value
@                                                                  a.de 86400 SOA  localhost. hostmaster.a.de. 2012111402 14400 3600 605000 86400
abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm    a.de       A     1.2.3.4
bcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefg a.de       A    1.2.3.5

$ ndcli delete rr bcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefg.a.de. a 1.2.3.5 -q
$ ndcli delete rr abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvxyzabcdefghijklm.a.de. a 1.2.3.4 -q
$ ndcli delete zone a.de --cleanup -q
