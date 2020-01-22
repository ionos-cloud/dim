# jdnssec-tools

* http://www.verisignlabs.com/jdnssec-tools/
* https://github.com/dblacka/jdnssec-tools/wiki

Author: David Blacka (davidb@verisign.com)

This is a collection of DNSSEC tools written in Java.  They are intended to be an addition or replacement for the DNSSEC tools that are part of BIND 9.

These tools depend upon DNSjava (http://www.xbill.org/dnsjava), the Jakarta Commons CLI and Logging libraries (https://commons.apache.org/proper/commons-cli), and Sun's Java Cryptography extensions.  A copy of each of these libraries is included in the distribution.  Currently, these tools use a custom version of the DNSjava library with minor modifications, which is provided.

See the "licenses" directory for the licensing information of this package and the other packages that are distributed with it.

Getting started:

1. Unpack the binary distribution:

        tar zxvf java-dnssec-tools-x.x.x.tar.gz

2. Run the various tools from their unpacked location:

        cd java-dnssec-tools-x.x.x
        ./bin/jdnssec-signzone -h


Building from source:

1. Unpack the source distribution, preferably into the same directory that the binary distribution was unpacked.

        tar zxvf java-dnssec-tools-x.x.x-src.tar.gz

2. Edit the build.properties file to suit your environment.
3. Run Ant (see http://ant.apache.org for information about the Ant build tool).

        ant

4. You can build the distribution tarballs with 'ant dist'.  You can run the tools directly from the build area (without building the jdnssec-tools.jar file) by using the ./bin/_jdnssec_* wrappers.


The source for this project is available in git on github: https://github.com/dblacka/jdnssec-tools

Source for the modified DNSjava library can be found on github as well: https://github.com/dblacka/jdnssec-dnsjava

---

Questions or comments may be directed to the author (mailto:davidb@verisign.com) or sent to the dnssec@verisignlabs.com mailing list (https://lists.verisignlabs.com/mailman/listinfo/dnssec).
