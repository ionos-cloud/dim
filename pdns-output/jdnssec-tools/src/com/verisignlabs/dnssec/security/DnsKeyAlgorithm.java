/*
 * $Id$
 * 
 * Copyright (c) 2006 VeriSign. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer. 2. Redistributions in
 * binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other
 * materials provided with the distribution. 3. The name of the author may not
 * be used to endorse or promote products derived from this software without
 * specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
 * NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *  
 */

package com.verisignlabs.dnssec.security;

import java.math.BigInteger;
import java.security.*;
import java.security.spec.*;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Set;
import java.util.logging.Logger;

import org.xbill.DNS.DNSSEC;

/**
 * This class handles translating DNS signing algorithm identifiers into various
 * usable java implementations.
 * 
 * Besides centralizing the logic surrounding matching a DNSKEY algorithm
 * identifier with various crypto implementations, it also handles algorithm
 * aliasing -- that is, defining a new algorithm identifier to be equivalent to
 * an existing identifier.
 * 
 * @author David Blacka (orig)
 * @author $Author: davidb $ (latest)
 * @version $Revision: 2098 $
 */
public class DnsKeyAlgorithm
{

  // Our base algorithm numbers. This is a normalization of the DNSSEC
  // algorithms (which are really signature algorithms). Thus RSASHA1,
  // RSASHA256, etc. all boil down to 'RSA' here.
  public static final int UNKNOWN    = -1;
  public static final int RSA        = 1;
  public static final int DH         = 2;
  public static final int DSA        = 3;
  public static final int ECC_GOST   = 4;
  public static final int ECDSA      = 5;

  private static class AlgEntry
  {
    public int    dnssecAlgorithm;
    public String sigName;
    public int    baseType;

    public AlgEntry(int algorithm, String sigName, int baseType)
    {
      this.dnssecAlgorithm = algorithm;
      this.sigName         = sigName;
      this.baseType        = baseType;
    }
  }

  private static class ECAlgEntry extends AlgEntry
  {
    public ECParameterSpec ec_spec;

    public ECAlgEntry(int algorithm, String sigName, int baseType, ECParameterSpec spec)
    {
      super(algorithm, sigName, baseType);
      this.ec_spec = spec;
    }
  }

  /**
   * This is a mapping of algorithm identifier to Entry. The Entry contains the
   * data needed to map the algorithm to the various crypto implementations.
   */
  private HashMap<Integer, AlgEntry>  mAlgorithmMap;
  /**
   * This is a mapping of algorithm mnemonics to algorithm identifiers.
   */
  private HashMap<String, Integer> mMnemonicToIdMap;
  /**
   * This is a mapping of identifiers to preferred mnemonic -- the preferred one
   * is the first defined one
   */
  private HashMap<Integer, String> mIdToMnemonicMap;

  /** This is a cached key pair generator for RSA keys. */
  private KeyPairGenerator         mRSAKeyGenerator;
  /** This is a cached key pair generator for DSA keys. */
  private KeyPairGenerator         mDSAKeyGenerator;
  /** This is a cached key pair generator for ECC GOST keys. */
  private KeyPairGenerator         mECGOSTKeyGenerator;
  /** This is a cached key pair generator for ECDSA_P256 keys. */
  private KeyPairGenerator         mECKeyGenerator;

  private Logger                   log = Logger.getLogger(this.getClass().toString());

  /** This is the global instance for this class. */
  private static DnsKeyAlgorithm   mInstance = null;

  public DnsKeyAlgorithm()
  {
    // Attempt to add the bouncycastle provider.
    // This is so we can use this provider if it is available, but not require
    // the user to add it as one of the java.security providers.
    try
    {
      Class<?> bc_provider_class = Class.forName("org.bouncycastle.jce.provider.BouncyCastleProvider");
      Provider bc_provider = (Provider) bc_provider_class.newInstance();
      Security.addProvider(bc_provider);
    }
    catch (ReflectiveOperationException e) { }

    initialize();
  }

  private void initialize()
  {
    mAlgorithmMap    = new HashMap<Integer, AlgEntry>();
    mMnemonicToIdMap = new HashMap<String, Integer>();
    mIdToMnemonicMap = new HashMap<Integer, String>();

    // Load the standard DNSSEC algorithms.
    addAlgorithm(DNSSEC.Algorithm.RSAMD5, "MD5withRSA", RSA);
    addMnemonic("RSAMD5", DNSSEC.Algorithm.RSAMD5);

    addAlgorithm(DNSSEC.Algorithm.DH, "", DH);
    addMnemonic("DH", DNSSEC.Algorithm.DH);

    addAlgorithm(DNSSEC.Algorithm.DSA, "SHA1withDSA", DSA);
    addMnemonic("DSA", DNSSEC.Algorithm.DSA);

    addAlgorithm(DNSSEC.Algorithm.RSASHA1, "SHA1withRSA", RSA);
    addMnemonic("RSASHA1", DNSSEC.Algorithm.RSASHA1);
    addMnemonic("RSA", DNSSEC.Algorithm.RSASHA1);

    // Load the (now) standard aliases
    addAlias(DNSSEC.Algorithm.DSA_NSEC3_SHA1, "DSA-NSEC3-SHA1", DNSSEC.Algorithm.DSA);
    addAlias(DNSSEC.Algorithm.RSA_NSEC3_SHA1, "RSA-NSEC3-SHA1", DNSSEC.Algorithm.RSASHA1);
    // Also recognize the BIND 9.6 mnemonics
    addMnemonic("NSEC3DSA", DNSSEC.Algorithm.DSA_NSEC3_SHA1);
    addMnemonic("NSEC3RSASHA1", DNSSEC.Algorithm.RSA_NSEC3_SHA1);

    // Algorithms added by RFC 5702.
    addAlgorithm(DNSSEC.Algorithm.RSASHA256, "SHA256withRSA", RSA);
    addMnemonic("RSASHA256", DNSSEC.Algorithm.RSASHA256);

    addAlgorithm(DNSSEC.Algorithm.RSASHA512, "SHA512withRSA", RSA);
    addMnemonic("RSASHA512", DNSSEC.Algorithm.RSASHA512);

    // ECC-GOST is not supported by Java 1.8's Sun crypto provider. The
    // bouncycastle.org provider, however, does.
    // GostR3410-2001-CryptoPro-A is the named curve in the BC provider, but we
    // will get the parameters directly.
    addAlgorithm(DNSSEC.Algorithm.ECC_GOST, "GOST3411withECGOST3410", ECC_GOST, null);
    addMnemonic("ECCGOST", DNSSEC.Algorithm.ECC_GOST);
    addMnemonic("ECC-GOST", DNSSEC.Algorithm.ECC_GOST);

    addAlgorithm(DNSSEC.Algorithm.ECDSAP256SHA256, "SHA256withECDSA", ECDSA, "secp256r1");
    addMnemonic("ECDSAP256SHA256", DNSSEC.Algorithm.ECDSAP256SHA256);
    addMnemonic("ECDSA-P256", DNSSEC.Algorithm.ECDSAP256SHA256);

    addAlgorithm(DNSSEC.Algorithm.ECDSAP384SHA384, "SHA384withECDSA", ECDSA, "secp384r1");
    addMnemonic("ECDSAP384SHA384", DNSSEC.Algorithm.ECDSAP384SHA384);
    addMnemonic("ECDSA-P384", DNSSEC.Algorithm.ECDSAP384SHA384);
  }

  private void addAlgorithm(int algorithm, String sigName, int baseType)
  {
    mAlgorithmMap.put(algorithm, new AlgEntry(algorithm, sigName, baseType));
  }

  private void addAlgorithm(int algorithm, String sigName, int baseType, String curveName)
  {
    ECParameterSpec ec_spec = ECSpecFromAlgorithm(algorithm);
    if (ec_spec == null) ec_spec = ECSpecFromName(curveName);
    if (ec_spec == null) return;
    // Check to see if we can get a Signature object for this algorithm.
    try {
      Signature.getInstance(sigName);
    } catch (NoSuchAlgorithmException e) {
      // If not, do not add the algorithm.
      return;
    }

    ECAlgEntry entry = new ECAlgEntry(algorithm, sigName, baseType, ec_spec);
    mAlgorithmMap.put(algorithm, entry);
  }

  private void addMnemonic(String m, int alg)
  {
    // Do not add mnemonics for algorithms that ended up not actually being supported.
    if (!mAlgorithmMap.containsKey(alg)) return;

    mMnemonicToIdMap.put(m.toUpperCase(), alg);
    if (!mIdToMnemonicMap.containsKey(alg))
    {
      mIdToMnemonicMap.put(alg, m);
    }
  }

  public void addAlias(int alias, String mnemonic, int original_algorithm)
  {
    if (mAlgorithmMap.containsKey(alias))
    {
      log.warning("Unable to alias algorithm " + alias + " because it already exists.");
      return;
    }

    if (!mAlgorithmMap.containsKey(original_algorithm))
    {
      log.warning("Unable to alias algorith " + alias
          + " to unknown algorithm identifier " + original_algorithm);
      return;
    }

    mAlgorithmMap.put(alias, mAlgorithmMap.get(original_algorithm));

    if (mnemonic != null)
    {
      addMnemonic(mnemonic, alias);
    }
  }

  private AlgEntry getEntry(int alg)
  {
    return mAlgorithmMap.get(alg);
  }

  // For curves where we don't (or can't) get the parameters from a standard
  // name, we can construct the parameters here. For now, we only do this for
  // the ECC-GOST curve.
  private ECParameterSpec ECSpecFromAlgorithm(int algorithm)
  {
    switch (algorithm)
    {
      case DNSSEC.Algorithm.ECC_GOST:
      {
        // From RFC 4357 Section 11.4
        BigInteger p  = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD97", 16);
        BigInteger a  = new BigInteger("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD94", 16);
        BigInteger b  = new BigInteger("A6", 16);
        BigInteger gx = new BigInteger("1", 16);
        BigInteger gy = new BigInteger("8D91E471E0989CDA27DF505A453F2B7635294F2DDF23E3B122ACC99C9E9F1E14", 16);
        BigInteger n  = new BigInteger( "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C611070995AD10045841B09B761B893", 16);

        EllipticCurve curve = new EllipticCurve(new ECFieldFp(p), a, b);
        return new ECParameterSpec(curve, new ECPoint(gx, gy), n, 1);
      }
      default:
        return null;
    }
  }

  // Fetch the curve parameters from a named curve.
  private ECParameterSpec ECSpecFromName(String stdName)
  {
    try
    {
      AlgorithmParameters ap = AlgorithmParameters.getInstance("EC");
      ECGenParameterSpec ecg_spec = new ECGenParameterSpec(stdName);
      ap.init(ecg_spec);
      return ap.getParameterSpec(ECParameterSpec.class);
    }
    catch (NoSuchAlgorithmException e) {
      log.info("Elliptic Curve not supported by any crypto provider: " + e.getMessage());
    }
    catch (InvalidParameterSpecException e) {
      log.info("Elliptic Curve " + stdName + " not supported");
    }
    return null;
  }

  public String[] supportedAlgMnemonics()
  {
    Set<Integer> keyset = mAlgorithmMap.keySet();
    Integer[] algs = keyset.toArray(new Integer[keyset.size()]);
    Arrays.sort(algs);

    String[] result = new String[algs.length];
    for (int i = 0; i < algs.length; i++)
    {
      result[i] = mIdToMnemonicMap.get(algs[i]);
    }

    return result;
  }
  /**
   * Return a Signature object for the specified DNSSEC algorithm.
   * @param algorithm The DNSSEC algorithm (by number).
   * @return a Signature object.
   */
  public Signature getSignature(int algorithm)
  {
    AlgEntry entry = getEntry(algorithm);
    if (entry == null) return null;

    Signature s = null;

    try
    {
      s = Signature.getInstance(entry.sigName);
    }
    catch (NoSuchAlgorithmException e)
    {
      log.severe("Unable to get signature implementation for algorithm " + algorithm
          + ": " + e);
    }

    return s;
  }

  /**
   * Given one of the ECDSA algorithms (ECDSAP256SHA256, etc.) return
   * the elliptic curve parameters.
   *
   * @param algorithm
   *          The DNSSEC algorithm number.
   * @return The calculated JCA ECParameterSpec for that DNSSEC algorithm, or
   *         null if not a recognized/supported EC algorithm.
   */
  public ECParameterSpec getEllipticCurveParams(int algorithm)
  {
    AlgEntry entry = getEntry(algorithm);
    if (entry == null) return null;
    if (!(entry instanceof ECAlgEntry)) return null;
    ECAlgEntry ec_entry = (ECAlgEntry) entry;

    return ec_entry.ec_spec;
  }

  /**
   * Translate a possible algorithm alias back to the original DNSSEC algorithm
   * number
   * 
   * @param algorithm
   *          a DNSSEC algorithm that may be an alias.
   * @return -1 if the algorithm isn't recognised, the orignal algorithm number
   *         if it is.
   */
  public int originalAlgorithm(int algorithm)
  {
    AlgEntry entry = getEntry(algorithm);
    if (entry == null) return -1;
    return entry.dnssecAlgorithm;
  }

  /**
   * Test if a given algorithm is supported.
   * 
   * @param algorithm The DNSSEC algorithm number.
   * @return true if the algorithm is a recognized and supported algorithm or alias.
   */
  public boolean supportedAlgorithm(int algorithm)
  {
    if (mAlgorithmMap.containsKey(algorithm)) return true;
    return false;
  }

  /**
   * Given an algorithm mnemonic, convert the mnemonic to a DNSSEC algorithm
   * number.
   * 
   * @param s
   *          The mnemonic string. This is case-insensitive.
   * @return -1 if the mnemonic isn't recognized or supported, the algorithm
   *         number if it is.
   */
  public int stringToAlgorithm(String s)
  {
    Integer alg = mMnemonicToIdMap.get(s.toUpperCase());
    if (alg != null) return alg.intValue();
    return -1;
  }

  /**
   * Given a DNSSEC algorithm number, return the "preferred" mnemonic.
   * 
   * @param algorithm
   *          A DNSSEC algorithm number.
   * @return The preferred mnemonic string, or null if not supported or
   *         recognized.
   */
  public String algToString(int algorithm)
  {
    return mIdToMnemonicMap.get(algorithm);
  }

  public int baseType(int algorithm)
  {
    AlgEntry entry = getEntry(algorithm);
    if (entry != null) return entry.baseType;
    return UNKNOWN;
  }

  public boolean isDSA(int algorithm)
  {
    return (baseType(algorithm) == DSA);
  }

  public KeyPair generateKeyPair(int algorithm, int keysize, boolean useLargeExp)
      throws NoSuchAlgorithmException
  {
    KeyPair pair = null;
    switch (baseType(algorithm))
    {
      case RSA:
      {
        if (mRSAKeyGenerator == null)
        {
          mRSAKeyGenerator = KeyPairGenerator.getInstance("RSA");
        }

        RSAKeyGenParameterSpec rsa_spec;
        if (useLargeExp)
        {
          rsa_spec = new RSAKeyGenParameterSpec(keysize, RSAKeyGenParameterSpec.F4);
        }
        else
        {
          rsa_spec = new RSAKeyGenParameterSpec(keysize, RSAKeyGenParameterSpec.F0);
        }
        try
        {
          mRSAKeyGenerator.initialize(rsa_spec);
        }
        catch (InvalidAlgorithmParameterException e)
        {
          // Fold the InvalidAlgorithmParameterException into our existing
          // thrown exception. Ugly, but requires less code change.
          throw new NoSuchAlgorithmException("invalid key parameter spec");
        }

        pair = mRSAKeyGenerator.generateKeyPair();
        break;
      }
      case DSA:
      {
        if (mDSAKeyGenerator == null)
        {
          mDSAKeyGenerator = KeyPairGenerator.getInstance("DSA");
        }
        mDSAKeyGenerator.initialize(keysize);
        pair = mDSAKeyGenerator.generateKeyPair();
        break;
      }
      case ECC_GOST:
      {
        if (mECGOSTKeyGenerator == null)
        {
          mECGOSTKeyGenerator = KeyPairGenerator.getInstance("ECGOST3410");
        }

        ECParameterSpec ec_spec = getEllipticCurveParams(algorithm);
        try
        {
          mECGOSTKeyGenerator.initialize(ec_spec);
        }
        catch (InvalidAlgorithmParameterException e)
        {
          // Fold the InvalidAlgorithmParameterException into our existing
          // thrown exception. Ugly, but requires less code change.
          throw new NoSuchAlgorithmException("invalid key parameter spec");
        }
        pair = mECGOSTKeyGenerator.generateKeyPair();
        break;
      }
      case ECDSA:
      {
        if (mECKeyGenerator == null)
        {
          mECKeyGenerator = KeyPairGenerator.getInstance("EC");
        }

        ECParameterSpec ec_spec = getEllipticCurveParams(algorithm);
        try
        {
          mECKeyGenerator.initialize(ec_spec);
        }
        catch (InvalidAlgorithmParameterException e)
        {
          // Fold the InvalidAlgorithmParameterException into our existing
          // thrown exception. Ugly, but requires less code change.
          throw new NoSuchAlgorithmException("invalid key parameter spec");
        }
        pair = mECKeyGenerator.generateKeyPair();
        break;
      }
      default:
        throw new NoSuchAlgorithmException("Alg " + algorithm);
    }

    return pair;
  }

  public KeyPair generateKeyPair(int algorithm, int keysize)
      throws NoSuchAlgorithmException
  {
    return generateKeyPair(algorithm, keysize, false);
  }

  public static DnsKeyAlgorithm getInstance()
  {
    if (mInstance == null) mInstance = new DnsKeyAlgorithm();
    return mInstance;
  }
}
