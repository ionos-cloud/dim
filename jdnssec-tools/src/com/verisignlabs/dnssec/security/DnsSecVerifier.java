// $Id$
//
// Copyright (C) 2001-2003 VeriSign, Inc.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA

package com.verisignlabs.dnssec.security;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

import org.xbill.DNS.*;

/**
 * A class for performing basic DNSSEC verification. The DNSJAVA package
 * contains a similar class. This differs (for the moment, anyway) by allowing
 * timing "fudge" factors and logging more specifically why an RRset did not
 * validate.
 * 
 * @author David Blacka (original)
 * @author $Author$
 * @version $Revision$
 */
public class DnsSecVerifier
{

  private class TrustedKeyStore
  {
    // for now, this is implemented as a hash table of lists of
    // DnsKeyPair objects (obviously, all of them will not have
    // private keys).
    private HashMap<String, List<DnsKeyPair>> mKeyMap;

    public TrustedKeyStore()
    {
      mKeyMap = new HashMap<String, List<DnsKeyPair>>();
    }

    public void add(DnsKeyPair pair)
    {
      String n = pair.getDNSKEYName().toString().toLowerCase();
      List<DnsKeyPair> l = mKeyMap.get(n);
      if (l == null)
      {
        l = new ArrayList<DnsKeyPair>();
        mKeyMap.put(n, l);
      }

      l.add(pair);
    }

    public void add(DNSKEYRecord keyrec)
    {
      DnsKeyPair pair = new DnsKeyPair(keyrec, (PrivateKey) null);
      add(pair);
    }

    public void add(Name name, int algorithm, PublicKey key)
    {
      DnsKeyPair pair = new DnsKeyPair(name, algorithm, key, null);
      add(pair);
    }

    public DnsKeyPair find(Name name, int algorithm, int keyid)
    {
      String n = name.toString().toLowerCase();
      List<DnsKeyPair> l = mKeyMap.get(n);
      if (l == null) return null;

      // FIXME: this algorithm assumes that name+alg+footprint is
      // unique, which isn't necessarily true.
      for (DnsKeyPair p : l)
      {
        if (p.getDNSKEYAlgorithm() == algorithm && p.getDNSKEYFootprint() == keyid)
        {
          return p;
        }
      }
      return null;
    }
  }

  private TrustedKeyStore mKeyStore;
  private int             mStartFudge    = 0;
  private int             mExpireFudge   = 0;
  private boolean         mVerifyAllSigs = false;
  private boolean         mIgnoreTime    = false;

  private Logger          log;

  public DnsSecVerifier()
  {
    log = Logger.getLogger(this.getClass().toString());

    mKeyStore = new TrustedKeyStore();
  }

  public void addTrustedKey(DNSKEYRecord keyrec)
  {
    mKeyStore.add(keyrec);
  }

  public void addTrustedKey(DnsKeyPair pair)
  {
    mKeyStore.add(pair);
  }

  public void addTrustedKey(Name name, int algorithm, PublicKey key)
  {
    mKeyStore.add(name, algorithm, key);
  }

  public void addTrustedKey(Name name, PublicKey key)
  {
    mKeyStore.add(name, 0, key);
  }

  public void setExpireFudge(int fudge)
  {
    mExpireFudge = fudge;
  }

  public void setStartFudge(int fudge)
  {
    mStartFudge = fudge;
  }

  public void setVerifyAllSigs(boolean v)
  {
    mVerifyAllSigs = v;
  }

  public void setIgnoreTime(boolean v)
  {
    mIgnoreTime = v;
  }

  private DnsKeyPair findKey(Name name, int algorithm, int footprint)
  {
    return mKeyStore.find(name, algorithm, footprint);
  }

  private boolean validateSignature(RRset rrset, RRSIGRecord sigrec, List<String> reasons)
  {
    if (rrset == null || sigrec == null) return false;
    if (!rrset.getName().equals(sigrec.getName()))
    {
      log.fine("Signature name does not match RRset name");
      if (reasons != null) reasons.add("Signature name does not match RRset name");
      return false;
    }
    if (rrset.getType() != sigrec.getTypeCovered())
    {
      log.fine("Signature type does not match RRset type");
      if (reasons != null) reasons.add("Signature type does not match RRset type");
    }

    if (mIgnoreTime) return true;

    Date now = new Date();
    Date start = sigrec.getTimeSigned();
    Date expire = sigrec.getExpire();

    if (mStartFudge >= 0)
    {
      if (mStartFudge > 0)
      {
        start = new Date(start.getTime() - ((long) mStartFudge * 1000));
      }
      if (now.before(start))
      {
        log.fine("Signature is not yet valid");
        if (reasons != null) reasons.add("Signature not yet valid");
        return false;
      }
    }

    if (mExpireFudge >= 0)
    {
      if (mExpireFudge > 0)
      {
        expire = new Date(expire.getTime() + ((long) mExpireFudge * 1000));
      }
      if (now.after(expire))
      {
        log.fine("Signature has expired (now = " + now + ", sig expires = " + expire);
        if (reasons != null) reasons.add("Signature has expired.");
        return false;
      }
    }

    if (rrset.getTTL() > sigrec.getOrigTTL())
    {
      log.fine("RRset's TTL is greater than the Signature's orignal TTL");
      if (reasons != null) reasons.add("RRset TTL greater than RRSIG origTTL");
      return false;
    }

    return true;
  }

  public boolean verifySignature(RRset rrset, RRSIGRecord sigrec)
  {
    return verifySignature(rrset, sigrec, null);
  }

  /**
   * Verify an RRset against a particular signature.
   * 
   * @return true if the signature verified, false if it did
   *         not verify (for any reason, including not finding the DNSKEY.)
   */
  public boolean verifySignature(RRset rrset, RRSIGRecord sigrec, List<String> reasons)
  {
    boolean result = validateSignature(rrset, sigrec, reasons);
    if (!result) return result;

    DnsKeyPair keypair = findKey(sigrec.getSigner(), sigrec.getAlgorithm(),
                                 sigrec.getFootprint());

    if (keypair == null)
    {
      if (reasons != null) reasons.add("Could not find matching trusted key");
      log.fine("could not find matching trusted key");
      return false;
    }

    try
    {
      byte[] data = SignUtils.generateSigData(rrset, sigrec);

      DnsKeyAlgorithm algs = DnsKeyAlgorithm.getInstance();

      Signature signer = keypair.getVerifier();
      signer.update(data);

      byte[] sig = sigrec.getSignature();

      if (algs.baseType(sigrec.getAlgorithm()) == DnsKeyAlgorithm.DSA)
      {
        sig = SignUtils.convertDSASignature(sig);
      }

      if (sigrec.getAlgorithm() == DNSSEC.Algorithm.ECDSAP256SHA256 || 
          sigrec.getAlgorithm() == DNSSEC.Algorithm.ECDSAP384SHA384) 
      {
        sig = SignUtils.convertECDSASignature(sig);
      }

      if (!signer.verify(sig))
      {
        if (reasons != null) reasons.add("Signature failed to verify cryptographically");
        log.fine("Signature failed to verify cryptographically");
        return false;
      }

      return true;
    }
    catch (IOException e)
    {
      log.severe("I/O error: " + e);
    }
    catch (GeneralSecurityException e)
    {
      log.severe("Security error: " + e);
    }
    if (reasons != null) reasons.add("Signature failed to verify due to exception");
    log.fine("Signature failed to verify due to exception");
    return false;
  }

  /**
   * Verifies an RRset. This routine does not modify the RRset.
   * 
   * @return true if the set verified, false if it did not.
   */
  public boolean verify(RRset rrset)
  {
    boolean result = mVerifyAllSigs ? true : false;

    Iterator i = rrset.sigs();

    if (!i.hasNext())
    {
      log.fine("RRset failed to verify due to lack of signatures");
      return false;
    }

    while (i.hasNext())
    {
      RRSIGRecord sigrec = (RRSIGRecord) i.next();

      boolean res = verifySignature(rrset, sigrec);

      // If not requiring all signature to validate, then any successful validation is sufficient.
      if (!mVerifyAllSigs && res) return res;

      // Otherwise, note if a signature failed to validate.
      if (mVerifyAllSigs && !res)
      {
        result = res;
      }
    }

    return result;
  }
}
