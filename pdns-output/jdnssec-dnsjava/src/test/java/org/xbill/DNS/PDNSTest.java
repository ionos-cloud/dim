package org.xbill.DNS;

import junit.framework.TestCase;

import java.io.IOException;

public class PDNSTest extends TestCase {
    private static String pdnsContent(int type, String rdata) throws IOException {
        return Record.fromString(new Name("."), type, DClass.IN, 0, rdata, new Name(".")).pdnsContent();
    }

    public void test_pdnsContent() throws IOException {
        // pdnsContent should be equal to rdataToString for these
        assertEquals("1.2.3.4", pdnsContent(Type.A, "1.2.3.4"));
        assertEquals("1:0:0:0:0:0:0:2", pdnsContent(Type.AAAA, "1::2"));
        assertEquals("\"quotes \\\\ \\195\\131\\194\\182\"", pdnsContent(Type.TXT, "\"quotes \\\\ ö\""));
        assertEquals("\"v=spf1\" \"ip4:82.165.0.0/16\" \"~all\"", pdnsContent(Type.SPF, "v=spf1 ip4:82.165.0.0/16 ~all"));
        assertEquals("1 4242 8 YQo=", pdnsContent(Type.CERT, "1 4242 8 YQo="));
        assertEquals("3 0 1 8ACF", pdnsContent(Type.TLSA, "3 0 1 8acf"));
        assertEquals("1 1 8CB0", pdnsContent(Type.SSHFP, "1 1 8cb0"));
        assertEquals("12345 3 1 ABCD", pdnsContent(Type.DS, "12345 3 1 abcd"));

        // no trailing dots for the rest
        // MX and SRV must omit priority from content
        assertEquals("a.com", pdnsContent(Type.MX, "10 a.com."));
        assertEquals("100 389 a.com", pdnsContent(Type.SRV, "0 100 389 a.com."));

        assertEquals("a.com", pdnsContent(Type.PTR, "a.com."));
        assertEquals("a.com", pdnsContent(Type.CNAME, "a.com."));
        assertEquals("a.com", pdnsContent(Type.NS, "a.com."));
        assertEquals("p.a.com a.com", pdnsContent(Type.RP, "p.a.com. a.com."));
        assertEquals("100 50 \"s\" \"z3950+I2L+I2C\" \"\" _z3950._tcp.gatech.edu",
                pdnsContent(Type.NAPTR, "100 50 \"s\" \"z3950+I2L+I2C\" \"\" _z3950._tcp.gatech.edu."));
    }
}
