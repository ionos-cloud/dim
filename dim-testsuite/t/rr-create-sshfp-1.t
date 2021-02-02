# RFC4255
# algorithm 'fp type' fingerprint
#
# see also Section 3.1
#
# algorithm 0-255
# 'fp type' 0-255
# fingerprint max 64k string

$ ndcli create rr server.a.de. sshfp 1 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
INFO - No zone found for server.a.de.
$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli create rr s.a.de. sshfp 1 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
WARNING - No A or AAAA found for s.a.de.
INFO - Creating RR s SSHFP 1 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

$ ndcli create rr s.a.de. a 1.2.34.5
INFO - Marked IP 1.2.34.5 from layer3domain default as static
WARNING - No reverse zone found. Only creating forward entry.
INFO - No zone found for 5.34.2.1.in-addr.arpa.
INFO - Creating RR s A 1.2.34.5 in zone a.de

$ ndcli create rr s.a.de. sshfp 0 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid algorithm: 0

$ ndcli create rr s.a.de. sshfp 2 0 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid fingerprint_type: 0

# would print usage
# $ ndcli create rr s.a.de. sshfp 1 1 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - SSHFP Records have exactly 3 fields

# would print usage
# $ ndcli create rr s.a.de. sshfp 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
# ERROR - SSHFP Records have exactly 3 fields

$ ndcli create rr s.a.de. sshfp 256 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid algorithm: 256

$ ndcli create rr s.a.de. sshfp 2 256 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
ERROR - Invalid fingerprint_type: 256

#          Value    Algorithm name
#          -----    --------------
#          0        reserved
#          1        RSA
#          2        DSS
# RFC6594
#          3        ECDSA
#
#          Value    Fingerprint type
#          -----    ----------------
#          0        reserved
#          1        SHA-1
# RFC6594
#          2        SHA-256

# As a user I want to be able to use the abbreviations defined in RFC4255 and RFC6594

$ ndcli create rr s.a.de. sshfp dss sha-256 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
WARNING - The name s.a.de. already existed, creating round robin record
INFO - Creating RR s SSHFP 2 2 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

# As a user I want to be warned if I used undefined algorithms and/or fingerprints
#
$ ndcli create rr s.a.de. sshfp 4 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
WARNING - algorithm value 4 is unassigned
WARNING - The name s.a.de. already existed, creating round robin record
INFO - Creating RR s SSHFP 4 1 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

$ ndcli create rr s.a.de. sshfp 1 3 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1
WARNING - fingerprint_type value 3 is unassigned
WARNING - The name s.a.de. already existed, creating round robin record
INFO - Creating RR s SSHFP 1 3 8cb0fc6c527506a053f4f14c8464bebbd6dede2738d11468dd953d7d6a3021f1 in zone a.de

$ ndcli delete zone a.de -q -c