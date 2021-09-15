
The differences between this version of DNSJava and the official version are:

1. The build.xml has been modified to compile to the build/classes directory.

2. org.xbill.DNS.Message.toString() has been modified to create an
   "OPT PSEUDOSECTION" section rather than attempt to render the OPT
   record in the additional section.

3. org.xbill.DNS.NSEC3Record has a "comment" field that can be
   specified in an alternate constructor.  If specified, the
   toString() method will append the comment.  This feature exists so
   that the jdnssec-signzone tool can add the original ownername as a
   comment.

4. A base32 test driver exists.  Unfortunately, this was left out of
   the patch submission that added the base32 class to DNSJava.

5. The testcase, org.xbill.DNS.DNSSECWithLunaDriverTest has been
   disabled (by renaming it to
   DNSSECWithLunaDriverTest.java.disabled), as it won't compile
   without the Luna API present.

6. TSIG.HMAC_MD5_STR has been downcased to solve some interop problems.

7. The SMIMEA record type has been added.