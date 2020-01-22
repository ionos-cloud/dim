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

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.text.NumberFormat;

import org.xbill.DNS.DNSKEYRecord;
import org.xbill.DNS.Master;
import org.xbill.DNS.Name;
import org.xbill.DNS.RRset;
import org.xbill.DNS.Record;
import org.xbill.DNS.Type;
import org.xbill.DNS.utils.base64;

/**
 * This class contains a series of static methods used for manipulating BIND
 * 9.x.x-style DNSSEC key files.
 * 
 * In this class, the "base" key path or name is the file name without the
 * trailing ".key" or ".private".
 * 
 * @author David Blacka (original)
 * @author $Author$
 * @version $Revision$
 */
public class BINDKeyUtils
{
  // formatters used to generated the BIND key file names
  private static NumberFormat mAlgNumberFormatter;
  private static NumberFormat mKeyIdNumberFormatter;

  /**
   * Calculate the BIND9 key file base name (i.e., without the ".key" or
   * ".private" extensions)
   */
  private static String getKeyFileBase(Name signer, int algorithm, int keyid)
  {
    if (mAlgNumberFormatter == null)
    {
      mAlgNumberFormatter = NumberFormat.getNumberInstance();
      mAlgNumberFormatter.setMaximumIntegerDigits(3);
      mAlgNumberFormatter.setMinimumIntegerDigits(3);
    }
    if (mKeyIdNumberFormatter == null)
    {
      mKeyIdNumberFormatter = NumberFormat.getNumberInstance();
      mKeyIdNumberFormatter.setMaximumIntegerDigits(5);
      mKeyIdNumberFormatter.setMinimumIntegerDigits(5);
      mKeyIdNumberFormatter.setGroupingUsed(false);

    }

    keyid &= 0xFFFF;

    String fn = "K" + signer + "+" + mAlgNumberFormatter.format(algorithm)
        + "+" + mKeyIdNumberFormatter.format(keyid);

    return fn;
  }

  /** Reads in the DNSKEYRecord from the public key file */
  private static DNSKEYRecord loadPublicKeyFile(File publicKeyFile)
      throws IOException
  {
    Master m = new Master(publicKeyFile.getAbsolutePath(), null, 600);

    Record r;
    DNSKEYRecord result = null;

    while ((r = m.nextRecord()) != null)
    {
      if (r.getType() == Type.DNSKEY)
      {
        result = (DNSKEYRecord) r;
      }
    }

    return result;
  }

  /** Reads in the private key verbatim from the private key file */
  private static String loadPrivateKeyFile(File privateKeyFile)
      throws IOException
  {
    BufferedReader in = new BufferedReader(new FileReader(privateKeyFile));
    StringBuffer key_buf = new StringBuffer();

    String line;

    while ((line = in.readLine()) != null)
    {
      key_buf.append(line);
      key_buf.append('\n');
    }
    in.close();

    return key_buf.toString().trim();
  }

  /**
   * Given an actual path for one of the key files, return the base name
   */
  private static String fixKeyFileBasePath(String basePath)
  {
    if (basePath == null) throw new IllegalArgumentException();
    if (basePath.endsWith(".key") || basePath.endsWith(".private"))
    {
      basePath = basePath.substring(0, basePath.lastIndexOf("."));
    }

    return basePath;
  }

  /**
   * Given the information necessary to construct the path to a BIND9 generated
   * key pair, load the key pair.
   * 
   * @param signer
   *          the DNS name of the key.
   * @param algorithm
   *          the DNSSEC algorithm of the key.
   * @param keyid
   *          the DNSSEC key footprint.
   * @param inDirectory
   *          the directory to look for the files (may be null).
   * @return the loaded key pair.
   * @throws IOException
   *           if there was a problem reading the BIND9 files.
   */
  public static DnsKeyPair loadKeyPair(Name signer, int algorithm, int keyid,
                                       File inDirectory) throws IOException
  {
    String keyFileBase = getKeyFileBase(signer, algorithm, keyid);

    return loadKeyPair(keyFileBase, inDirectory);
  }

  /**
   * Given a base path to a BIND9 key pair, load the key pair.
   * 
   * @param keyFileBasePath
   *          the base filename (or real filename for either the public or
   *          private key) of the key.
   * @param inDirectory
   *          the directory to look in, if the keyFileBasePath is relative.
   * @return the loaded key pair.
   * @throws IOException
   *           if there was a problem reading the files
   */
  public static DnsKeyPair loadKeyPair(String keyFileBasePath, File inDirectory)
      throws IOException
  {
    keyFileBasePath = fixKeyFileBasePath(keyFileBasePath);
    // FIXME: should we throw the IOException when one of the files
    // cannot be found, or just when both cannot be found?
    File publicKeyFile = new File(inDirectory, keyFileBasePath + ".key");
    File privateKeyFile = new File(inDirectory, keyFileBasePath + ".private");

    DnsKeyPair kp = new DnsKeyPair();

    DNSKEYRecord kr = loadPublicKeyFile(publicKeyFile);
    kp.setDNSKEYRecord(kr);

    String pk = loadPrivateKeyFile(privateKeyFile);
    kp.setPrivateKeyString(pk);

    return kp;
  }

  /**
   * Given a base path to a BIND9 key pair, load the public part (only) of the
   * key pair
   * 
   * @param keyFileBasePath
   *          the base or real path to the public part of a key pair.
   * @param inDirectory
   *          the directory to look in if the path is relative (may be null).
   * @return a {@link DnsKeyPair} containing just the public key information.
   * @throws IOException
   *           if there was a problem reading the public key file.
   */
  public static DnsKeyPair loadKey(String keyFileBasePath, File inDirectory)
      throws IOException
  {
    keyFileBasePath = fixKeyFileBasePath(keyFileBasePath);
    File publicKeyFile = new File(inDirectory, keyFileBasePath + ".key");

    DnsKeyPair kp = new DnsKeyPair();

    DNSKEYRecord kr = loadPublicKeyFile(publicKeyFile);
    kp.setDNSKEYRecord(kr);

    return kp;
  }

  /**
   * Load a BIND keyset file. The BIND 9 dnssec tools typically call these files
   * "keyset-[signer]." where [signer] is the DNS owner name of the key. The
   * keyset may be signed, but doesn't have to be.
   * 
   * @param keysetFileName
   *          the name of the keyset file.
   * @param inDirectory
   *          the directory to look in if the path is relative (may be null,
   *          defaults to the current working directory).
   * @return a RRset contain the KEY records and any associated SIG records.
   * @throws IOException
   *           if there was a problem reading the keyset file.
   */
  public static RRset loadKeySet(String keysetFileName, File inDirectory)
      throws IOException
  {
    File keysetFile = new File(inDirectory, keysetFileName);

    Master m = new Master(keysetFile.getAbsolutePath());

    Record r;
    RRset keyset = new RRset();
    while ((r = m.nextRecord()) != null)
    {
      keyset.addRR(r);
    }

    return keyset;
  }

  /**
   * Calculate the key file base for this key pair.
   * 
   * @param pair
   *          the {@link DnsKeyPair} to work from. It only needs a public key.
   * @return the base name of the key files.
   */
  public static String keyFileBase(DnsKeyPair pair)
  {
    DNSKEYRecord keyrec = pair.getDNSKEYRecord();
    if (keyrec == null) return null;

    return getKeyFileBase(keyrec.getName(), keyrec.getAlgorithm(),
                          keyrec.getFootprint());
  }

  /**
   * @return a {@link java.io.File} object representing the BIND9 public key
   *         file.
   */
  public static File getPublicKeyFile(DnsKeyPair pair, File inDirectory)
  {
    String keyfilebase = keyFileBase(pair);
    if (keyfilebase == null) return null;

    return new File(inDirectory, keyfilebase + ".key");
  }

  /**
   * @return a {@link java.io.File} object representing the BIND9 private key
   *         file
   */
  public static File getPrivateKeyFile(DnsKeyPair pair, File inDirectory)
  {
    String keyfilebase = keyFileBase(pair);
    if (keyfilebase == null) return null;

    return new File(inDirectory, keyfilebase + ".private");
  }

  /**
   * Given a the contents of a BIND9 private key file, convert it into a native
   * {@link java.security.PrivateKey} object.
   * 
   * @param privateKeyString
   *          the contents of a BIND9 key file in string form.
   * @return a {@link java.security.PrivateKey}
   */
  public static PrivateKey convertPrivateKeyString(String privateKeyString)
  {
    if (privateKeyString == null) return null;

    // FIXME: should this swallow exceptions or actually propagate
    // them?
    try
    {
      DnsKeyConverter conv = new DnsKeyConverter();
      return conv.parsePrivateKeyString(privateKeyString);
    }
    catch (IOException e)
    {
      e.printStackTrace();
    }
    catch (NoSuchAlgorithmException e)
    {
      e.printStackTrace();
    }

    return null;
  }

  /**
   * Given a native private key, convert it into a BIND9 private key file
   * format.
   * 
   * @param priv
   *          the private key to convert.
   * @param pub
   *          the private key's corresponding public key. Some algorithms
   *          require information from both.
   * @return a string containing the contents of a BIND9 private key file.
   */
  public static String convertPrivateKey(PrivateKey priv, PublicKey pub, int alg)
  {
    if (priv != null)
    {
      DnsKeyConverter keyconv = new DnsKeyConverter();
      String priv_string = keyconv.generatePrivateKeyString(priv, pub, alg);

      return priv_string;
    }

    return null;
  }

  /**
   * Convert the KEY record to the exact string format that the dnssec-*
   * routines need. Currently, the DNSJAVA package uses a multiline mode for its
   * record formatting. The BIND9 tools require everything on a single line.
   */
  private static String DNSKEYtoString(DNSKEYRecord rec)
  {
    StringBuffer buf = new StringBuffer();

    buf.append(rec.getName());
    buf.append(" IN DNSKEY ");
    buf.append(rec.getFlags() & 0xFFFF);
    buf.append(" ");
    buf.append(rec.getProtocol());
    buf.append(" ");
    buf.append(rec.getAlgorithm());
    buf.append(" ");
    buf.append(base64.toString(rec.getKey()));

    return buf.toString();
  }

  /**
   * This routine will write out the BIND9 dnssec-* tool compatible files.
   * 
   * @param baseFileName
   *          use this base file name. If null, the standard BIND9 base file
   *          name will be computed.
   * @param pair
   *          the keypair in question.
   * @param inDirectory
   *          the directory to write to (may be null).
   * @throws IOException
   *           if there is a problem writing the files.
   */
  public static void writeKeyFiles(String baseFileName, DnsKeyPair pair,
                                   File inDirectory) throws IOException
  {
    DNSKEYRecord pub = pair.getDNSKEYRecord();
    String priv = pair.getPrivateKeyString();

    if (priv == null)
    {
      priv = convertPrivateKey(pair.getPrivate(), pair.getPublic(),
                               pair.getDNSKEYAlgorithm());
    }

    if (pub == null || priv == null) return;

    // Write the public key file
    File pubkeyfile = new File(inDirectory, baseFileName + ".key");
    PrintWriter out = new PrintWriter(new FileWriter(pubkeyfile));
    out.println(DNSKEYtoString(pub));
    out.close();

    // Write the private key file
    File privkeyfile = new File(inDirectory, baseFileName + ".private");
    out = new PrintWriter(new FileWriter(privkeyfile));
    out.print(priv);
    out.close();

  }

  /**
   * This routine will write out the BIND9 dnssec-* tool compatible files to the
   * standard file names.
   * 
   * @param pair
   *          the key pair in question.
   * @param inDirectory
   *          the directory to write to (may be null).
   */
  public static void writeKeyFiles(DnsKeyPair pair, File inDirectory)
      throws IOException
  {
    String base = keyFileBase(pair);
    writeKeyFiles(base, pair, inDirectory);
  }

}
