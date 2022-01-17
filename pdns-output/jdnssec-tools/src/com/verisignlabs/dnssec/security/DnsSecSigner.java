package com.verisignlabs.dnssec.security;

import org.xbill.DNS.Name;
import org.xbill.DNS.Record;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Date;
import java.util.List;

public interface DnsSecSigner {
    List<Record> signZoneNSEC3(Name zonename, List<Record> records,
                               List<DnsKeyPair> kskpairs, List<DnsKeyPair> zskpairs,
                               Date start, Date expire, boolean fullySignKeyset,
                               boolean useOptOut, List<Name> includedNames,
                               byte[] salt, int iterations, int ds_digest_alg,
                               long nsec3paramttl) throws IOException, GeneralSecurityException;

    List<Record> signZone(Name zonename, List<Record> records,
                          List<DnsKeyPair> kskpairs, List<DnsKeyPair> zskpairs,
                          Date start, Date expire, boolean fullySignKeyset,
                          int ds_digest_alg) throws IOException, GeneralSecurityException;
}
