package dim;

import com.verisignlabs.dnssec.security.DnsKeyPair;
import org.xbill.DNS.Type;

import java.util.*;
import java.util.stream.Collectors;

class ZoneSignParameters {
    public final List<DnsKeyPair> kskpairs, zskpairs;
    public final Date begin, end;
    public final NSECParameters nsecParameters;

    public ZoneSignParameters(List<DnsKeyPair> kskpairs, List<DnsKeyPair> zskpairs, Date begin, Date end,
                              NSECParameters nsecParameters) {
        this.kskpairs = kskpairs;
        this.zskpairs = zskpairs;
        this.begin = begin;
        this.end = end;
        this.nsecParameters = nsecParameters;
    }

    public ZoneSignParameters withNSECParameters(NSECParameters nsecParameters) {
        return new ZoneSignParameters(kskpairs, zskpairs, begin, end, nsecParameters);
    }

    public ZoneSignParameters withKeys(List<DnsKeyPair> kskpairs, List<DnsKeyPair> zskpairs) {
        return new ZoneSignParameters(kskpairs, zskpairs, begin, end, nsecParameters);
    }

    public int nsecType() {
        return nsecParameters.nsecMode == NSECParameters.NSECMode.NSEC_MODE ? Type.NSEC : Type.NSEC3;
    }

    public boolean isNSEC3() {
        return !(nsecParameters.nsecMode == NSECParameters.NSECMode.NSEC_MODE);
    }

    public String toString() {
        assert begin != null;
        assert end != null;
        ArrayList<String> elements = new ArrayList<>();
        elements.add(nsecParameters != null ? nsecParameters.toString() : "");
        elements.add(begin.toString());
        elements.add(end.toString());
        ArrayList<String> keys = new ArrayList<>();
        for (DnsKeyPair kp : kskpairs)
            keys.add(kp.getDNSKEYRecord().toString());
        for (DnsKeyPair kp : zskpairs)
            keys.add(kp.getDNSKEYRecord().toString());
        Collections.sort(keys);
        elements.addAll(keys);
        return String.join("|", elements);
    }
}
