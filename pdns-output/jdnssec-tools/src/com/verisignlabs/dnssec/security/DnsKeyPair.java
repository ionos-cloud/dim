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
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

package com.verisignlabs.dnssec.security;

import java.security.*;
import java.security.interfaces.*;
import java.util.logging.Logger;

import org.xbill.DNS.*;

/**
 * This class forms the basis for representing public/private key pairs in a
 * DNSSEC context. It is possible to get a JCA public and private key from this
 * object, as well as a DNSKEYRecord encoding of the public key. This class is
 * implemented as a UNION of all the functionality needed for handing native
 * java, BIND, and possibly other underlying DNSKEY engines.
 * 
 * JCA == Java Cryptography Architecture.
 * 
 * @author David Blacka (orig)
 * @author $Author$ (latest)
 * @version $Revision$
 */

// NOTE: this class is designed to do "lazy" evaluation of it's
// various cached objects and format conversions, so methods should
// avoid direct access to the member variables.
public class DnsKeyPair
{
  /** This is the real (base) encoding of the public key. */
  protected DNSKEYRecord    mPublicKeyRecord;

  /**
   * This is a pre-calculated cache of the DNSKEYRecord converted into a JCA
   * public key.
   */
  private PublicKey         mPublicKey;

  /**
   * The private key in Base64 encoded format. This version is presumed to be
   * opaque, so no attempts will be made to convert it to a JCA private key.
   */
  protected String          mPrivateKeyString;

  /**
   * The private key in JCA format. This is the base encoding for instances where
   * JCA private keys are used.
   */
  protected PrivateKey      mPrivateKey;

  /** The local key converter. */
  protected DnsKeyConverter mKeyConverter;

  /**
   * a cached Signature used for signing (initialized with the private key)
   */
  protected Signature       mSigner;

  /**
   * a caches Signature used for verifying (initialized with the public key)
   */
  protected Signature       mVerifier;

  private Logger            log;

  public DnsKeyPair()
  {
    log = Logger.getLogger(this.getClass().toString());
  }

  public DnsKeyPair(DNSKEYRecord keyRecord, PrivateKey privateKey)
  {
    this();

    setDNSKEYRecord(keyRecord);
    setPrivate(privateKey);
  }

  public DnsKeyPair(DNSKEYRecord keyRecord, String privateKeyString)
  {
    this();

    setDNSKEYRecord(keyRecord);
    setPrivateKeyString(privateKeyString);
  }

  public DnsKeyPair(DNSKEYRecord keyRecord)
  {
    this();
    setDNSKEYRecord(keyRecord);
    setPrivateKeyString(null);
  }

  public DnsKeyPair(Name keyName, int algorithm, PublicKey publicKey,
      PrivateKey privateKey)
  {
    this();

    DnsKeyConverter conv = new DnsKeyConverter();
    DNSKEYRecord keyrec = conv.generateDNSKEYRecord(keyName, DClass.IN, 0, 0,
                                                    algorithm, publicKey);
    setDNSKEYRecord(keyrec);
    setPrivate(privateKey);
  }

  public DnsKeyPair(DnsKeyPair pair)
  {
    this();

    setDNSKEYRecord(pair.getDNSKEYRecord());
    setPrivate(pair.getPrivate());
    setPrivateKeyString(pair.getPrivateKeyString());
  }

  /** @return cached DnsKeyConverter object. */
  protected DnsKeyConverter getKeyConverter()
  {
    if (mKeyConverter == null)
    {
      mKeyConverter = new DnsKeyConverter();
    }

    return mKeyConverter;
  }

  /** @return the appropriate Signature object for this keypair. */
  protected Signature getSignature()
  {
    DnsKeyAlgorithm algorithms = DnsKeyAlgorithm.getInstance();
    return algorithms.getSignature(getDNSKEYAlgorithm());
  }

  /**
   * @return the public key, translated from the KEYRecord, if necessary.
   */
  public PublicKey getPublic()
  {
    if (mPublicKey == null && getDNSKEYRecord() != null)
    {
      try
      {
        DnsKeyConverter conv = getKeyConverter();
        setPublic(conv.parseDNSKEYRecord(getDNSKEYRecord()));
      }
      catch (NoSuchAlgorithmException e)
      {
        log.severe(e.toString());
        return null;
      }
    }

    return mPublicKey;
  }

  /**
   * sets the public key. This method is generally not used directly.
   */
  protected void setPublic(PublicKey k)
  {
    mPublicKey = k;
  }

  /** @return the private key. */
  public PrivateKey getPrivate()
  {
    // attempt to convert the private key string format into a JCA
    // private key.
    if (mPrivateKey == null && mPrivateKeyString != null)
    {
      mPrivateKey = BINDKeyUtils.convertPrivateKeyString(mPrivateKeyString);
    }

    return mPrivateKey;
  }

  /** sets the private key */
  public void setPrivate(PrivateKey k)
  {
    mPrivateKey = k;
  }

  /**
   * @return the opaque private key string, null if one doesn't exist.
   * @throws NoSuchAlgorithmException
   */
  public String getPrivateKeyString()
  {
    if (mPrivateKeyString == null && mPrivateKey != null)
    {
      PublicKey pub = getPublic();
      mPrivateKeyString = BINDKeyUtils.convertPrivateKey(mPrivateKey, pub,
                                                         getDNSKEYAlgorithm());
    }

    return mPrivateKeyString;
  }

  /** sets the opaque private key string. */
  public void setPrivateKeyString(String p)
  {
    mPrivateKeyString = p;
  }

  /** @return the private key in an encoded form (normally PKCS#8). */
  public byte[] getEncodedPrivate()
  {
    PrivateKey priv = getPrivate();
    if (priv != null) return priv.getEncoded();
    return null;
  }

  /**
   * Sets the private key from the encoded form (PKCS#8). This routine requires
   * that the public key already be assigned. Currently it can only handle DSA
   * and RSA keys.
   */
  public void setEncodedPrivate(byte[] encoded)
  {
    int alg = getDNSKEYAlgorithm();

    if (alg >= 0)
    {
      DnsKeyConverter conv = getKeyConverter();
      setPrivate(conv.convertEncodedPrivateKey(encoded, alg));
    }
  }

  /** @return the public DNSKEY record */
  public DNSKEYRecord getDNSKEYRecord()
  {
    return mPublicKeyRecord;
  }

  /**
   * @return a Signature object initialized for signing, or null if this key
   *         pair does not have a valid private key.
   */
  public Signature getSigner()
  {
    if (mSigner == null)
    {
      mSigner = getSignature();
      PrivateKey priv = getPrivate();
      if (mSigner != null && priv != null)
      {
        try
        {
          mSigner.initSign(priv);
        }
        catch (InvalidKeyException e)
        {
          log.severe("Signature error: " + e);
        }
      }
      else
      {
        // do not return an uninitialized signer.
        return null;
      }
    }

    return mSigner;
  }

  /**
   * @return a Signature object initialized for verifying, or null if this key
   *         pair does not have a valid public key.
   * @throws NoSuchAlgorithmException
   */
  public Signature getVerifier()
  {
    if (mVerifier == null)
    {
      mVerifier = getSignature();
      PublicKey pk = getPublic();
      if (mVerifier != null && pk != null)
      {
        try
        {
          mVerifier.initVerify(pk);
        }
        catch (InvalidKeyException e)
        {
        }
      }
      else
      {
        // do not return an uninitialized verifier
        return null;
      }
    }

    return mVerifier;
  }

  /** sets the public key record */
  public void setDNSKEYRecord(DNSKEYRecord r)
  {
    mPublicKeyRecord = r;
    // force the conversion to PublicKey:
    mPublicKey = null;
  }

  public Name getDNSKEYName()
  {
    DNSKEYRecord kr = getDNSKEYRecord();
    if (kr != null) return kr.getName();
    return null;
  }

  public int getDNSKEYAlgorithm()
  {
    DNSKEYRecord kr = getDNSKEYRecord();
    if (kr != null) return kr.getAlgorithm();

    PublicKey pk = getPublic();
    if (pk != null)
    {
      // currently, alg 5 is the default over alg 1 (RSASHA1).
      if (pk instanceof RSAPublicKey) return DNSSEC.Algorithm.RSASHA1;
      if (pk instanceof DSAPublicKey) return DNSSEC.Algorithm.DSA;
    }

    PrivateKey priv = getPrivate();
    if (priv != null)
    {
      if (priv instanceof RSAPrivateKey) return DNSSEC.Algorithm.RSASHA1;
      if (priv instanceof DSAPrivateKey) return DNSSEC.Algorithm.DSA;
    }

    return -1;
  }

  public int getDNSKEYFootprint()
  {
    DNSKEYRecord kr = getDNSKEYRecord();
    if (kr != null) return kr.getFootprint();
    return -1;
  }
}
