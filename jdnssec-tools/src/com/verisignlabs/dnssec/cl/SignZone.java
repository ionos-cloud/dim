// Copyright (C) 2001-2003, 2011 VeriSign, Inc.
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

package com.verisignlabs.dnssec.cl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

import org.xbill.DNS.DNSKEYRecord;
import org.xbill.DNS.DSRecord;
import org.xbill.DNS.Name;
import org.xbill.DNS.RRset;
import org.xbill.DNS.Record;
import org.xbill.DNS.TextParseException;
import org.xbill.DNS.Type;
import org.xbill.DNS.utils.base16;

import com.verisignlabs.dnssec.security.BINDKeyUtils;
import com.verisignlabs.dnssec.security.DnsKeyPair;
import com.verisignlabs.dnssec.security.DnsSecVerifier;
import com.verisignlabs.dnssec.security.DnsSecSigner;
import com.verisignlabs.dnssec.security.JCEDnsSecSigner;
import com.verisignlabs.dnssec.security.JCEDnsSecParallelSigner;
import com.verisignlabs.dnssec.security.SignUtils;
import com.verisignlabs.dnssec.security.ZoneUtils;

/**
 * This class forms the command line implementation of a DNSSEC zone signer.
 * 
 * @author David Blacka
 */
public class SignZone extends CLBase
{
  private CLIState state;

  /**
   * This is an inner class used to hold all of the command line option state.
   */
  private static class CLIState extends CLIStateBase
  {
    public File       keyDirectory    = null;
    public File       keysetDirectory = null;
    public String[]   kskFiles        = null;
    public String[]   keyFiles        = null;
    public String     zonefile        = null;
    public Date       start           = null;
    public Date       expire          = null;
    public String     outputfile      = null;
    public boolean    verifySigs      = false;
    public boolean    parallel        = false;
    public boolean    useOptOut       = false;
    public boolean    fullySignKeyset = false;
    public List<Name> includeNames    = null;
    public boolean    useNsec3        = false;
    public byte[]     salt            = null;
    public int        iterations      = 0;
    public int        digest_id       = DSRecord.SHA1_DIGEST_ID;
    public long       nsec3paramttl   = -1;
    public boolean    verboseSigning  = false;

    public CLIState()
    {
      super("jdnssec-signzone [..options..] zone_file [key_file ...]");
    }

    protected void setupOptions(Options opts)
    {
      // boolean options
      opts.addOption("a", "verify", false, "verify generated signatures>");
      opts.addOption("p", "parallel", false, "parallel signing");
      opts.addOption("F", "fully-sign-keyset", false,
                     "sign the zone apex keyset with all available keys.");
      opts.addOption("V", "verbose-signing", false, "Display verbose signing activity.");

      // Argument options
      OptionBuilder.hasArg();
      OptionBuilder.withArgName("dir");
      OptionBuilder.withLongOpt("keyset-directory");
      OptionBuilder.withDescription("directory to find keyset files (default '.').");
      opts.addOption(OptionBuilder.create('d'));

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("dir");
      OptionBuilder.withLongOpt("key-directory");
      OptionBuilder.withDescription("directory to find key files (default '.').");
      opts.addOption(OptionBuilder.create('D'));

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("time/offset");
      OptionBuilder.withLongOpt("start-time");
      OptionBuilder.withDescription("signature starting time (default is now - 1 hour)");
      opts.addOption(OptionBuilder.create('s'));

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("time/offset");
      OptionBuilder.withLongOpt("expire-time");
      OptionBuilder.withDescription("signature expiration time (default is start-time + 30 days).");
      opts.addOption(OptionBuilder.create('e'));

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("outfile");
      OptionBuilder.withDescription("file the signed zone is written to (default is <origin>.signed).");
      opts.addOption(OptionBuilder.create('f'));

      OptionBuilder.hasArgs();
      OptionBuilder.withArgName("KSK file");
      OptionBuilder.withLongOpt("ksk-file");
      OptionBuilder.withDescription("this key is a key signing key (may repeat).");
      opts.addOption(OptionBuilder.create('k'));

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("file");
      OptionBuilder.withLongOpt("include-file");
      OptionBuilder.withDescription("include names in this file in the NSEC/NSEC3 chain.");
      opts.addOption(OptionBuilder.create('I'));

      // NSEC3 options
      opts.addOption("3", "use-nsec3", false, "use NSEC3 instead of NSEC");
      opts.addOption("O", "use-opt-out", false,
                     "generate a fully Opt-Out zone (only valid with NSEC3).");

      OptionBuilder.hasArg();
      OptionBuilder.withLongOpt("salt");
      OptionBuilder.withArgName("hex value");
      OptionBuilder.withDescription("supply a salt value.");
      opts.addOption(OptionBuilder.create('S'));

      OptionBuilder.hasArg();
      OptionBuilder.withLongOpt("random-salt");
      OptionBuilder.withArgName("length");
      OptionBuilder.withDescription("generate a random salt.");
      opts.addOption(OptionBuilder.create('R'));

      OptionBuilder.hasArg();
      OptionBuilder.withLongOpt("iterations");
      OptionBuilder.withArgName("value");
      OptionBuilder.withDescription("use this value for the iterations in NSEC3.");
      opts.addOption(OptionBuilder.create());

      OptionBuilder.hasArg();
      OptionBuilder.withLongOpt("nsec3paramttl");
      OptionBuilder.withArgName("ttl");
      OptionBuilder.withDescription("use this value for the NSEC3PARAM RR ttl");
      opts.addOption(OptionBuilder.create());

      OptionBuilder.hasArg();
      OptionBuilder.withArgName("id");
      OptionBuilder.withLongOpt("ds-digest");
      OptionBuilder.withDescription("Digest algorithm to use for generated DSs");
      opts.addOption(OptionBuilder.create());
    }

    protected void processOptions(CommandLine cli) throws ParseException
    {
      String optstr = null;

      if (cli.hasOption('a')) verifySigs = true;
      if (cli.hasOption('p')) parallel = true;
      if (cli.hasOption('3')) useNsec3 = true;
      if (cli.hasOption('O')) useOptOut = true;
      if (cli.hasOption('V')) verboseSigning = true;

      if (useOptOut && !useNsec3)
      {
        System.err.println("Opt-Out not supported without NSEC3 -- ignored.");
        useOptOut = false;
      }

      if (cli.hasOption('F')) fullySignKeyset = true;

      if ((optstr = cli.getOptionValue('d')) != null)
      {
        keysetDirectory = new File(optstr);
        if (!keysetDirectory.isDirectory())
        {
          System.err.println("error: " + optstr + " is not a directory");
          usage();

        }
      }

      if ((optstr = cli.getOptionValue('D')) != null)
      {
        keyDirectory = new File(optstr);
        if (!keyDirectory.isDirectory())
        {
          System.err.println("error: " + optstr + " is not a directory");
          usage();
        }
      }

      if ((optstr = cli.getOptionValue('s')) != null)
      {
        start = CLBase.convertDuration(null, optstr);
      }
      else
      {
        // default is now - 1 hour.
        start = new Date(System.currentTimeMillis() - (3600 * 1000));
      }

      if ((optstr = cli.getOptionValue('e')) != null)
      {
        expire = CLBase.convertDuration(start, optstr);
      }
      else
      {
        expire = CLBase.convertDuration(start, "+2592000"); // 30 days
      }

      outputfile = cli.getOptionValue('f');

      kskFiles = cli.getOptionValues('k');

      if ((optstr = cli.getOptionValue('I')) != null)
      {
        File includeNamesFile = new File(optstr);
        try
        {
          includeNames = getNameList(includeNamesFile);
        }
        catch (IOException e)
        {
          throw new ParseException(e.getMessage());
        }
      }

      if ((optstr = cli.getOptionValue('S')) != null)
      {
        salt = base16.fromString(optstr);
        if (salt == null && !optstr.equals("-"))
        {
          System.err.println("error: salt is not valid hexidecimal.");
          usage();
        }
      }

      if ((optstr = cli.getOptionValue('R')) != null)
      {
        int length = parseInt(optstr, 0);
        if (length > 0 && length <= 255)
        {
          Random random = new Random();
          salt = new byte[length];
          random.nextBytes(salt);
        }
      }

      if ((optstr = cli.getOptionValue("iterations")) != null)
      {
        iterations = parseInt(optstr, iterations);
        if (iterations < 0 || iterations > 8388607)
        {
          System.err.println("error: iterations value is invalid");
          usage();
        }
      }

      if ((optstr = cli.getOptionValue("ds-digest")) != null)
      {
        digest_id = parseInt(optstr, -1);
        if (digest_id < 0)
        {
          System.err.println("error: DS digest ID is not a valid identifier");
          usage();
        }
      }

      if ((optstr = cli.getOptionValue("nsec3paramttl")) != null)
      {
        nsec3paramttl = parseInt(optstr, -1);
      }

      String[] files = cli.getArgs();

      if (files.length < 1)
      {
        System.err.println("error: missing zone file and/or key files");
        usage();
      }

      zonefile = files[0];
      if (files.length > 1)
      {
        keyFiles = new String[files.length - 1];
        System.arraycopy(files, 1, keyFiles, 0, files.length - 1);
      }
    }
  }

  /**
   * Verify the generated signatures.
   * 
   * @param zonename
   *          the origin name of the zone.
   * @param records
   *          a list of {@link org.xbill.DNS.Record}s.
   * @param keypairs
   *          a list of keypairs used the sign the zone.
   * @return true if all of the signatures validated.
   */
  private static boolean verifyZoneSigs(Name zonename, List<Record> records,
                                        List<DnsKeyPair> keypairs)
  {
    boolean secure = true;

    DnsSecVerifier verifier = new DnsSecVerifier();

    for (DnsKeyPair pair : keypairs)
    {
      verifier.addTrustedKey(pair);
    }

    verifier.setVerifyAllSigs(true);

    List<RRset> rrsets = SignUtils.assembleIntoRRsets(records);

    for (RRset rrset : rrsets)
    {
      // skip unsigned rrsets.
      if (!rrset.sigs().hasNext()) continue;

      boolean result = verifier.verify(rrset);

      if (!result)
      {
        log.fine("Signatures did not verify for RRset: " + rrset);
        secure = false;
      }
    }

    return secure;
  }

  /**
   * Load the key pairs from the key files.
   * 
   * @param keyfiles
   *          a string array containing the base names or paths of the keys to
   *          be loaded.
   * @param start_index
   *          the starting index of keyfiles string array to use. This allows
   *          us
   *          to use the straight command line argument array.
   * @param inDirectory
   *          the directory to look in (may be null).
   * @return a list of keypair objects.
   */
  private static List<DnsKeyPair> getKeys(String[] keyfiles, int start_index,
                                          File inDirectory) throws IOException
  {
    if (keyfiles == null) return null;

    int len = keyfiles.length - start_index;
    if (len <= 0) return null;

    ArrayList<DnsKeyPair> keys = new ArrayList<DnsKeyPair>(len);

    for (int i = start_index; i < keyfiles.length; i++)
    {
      DnsKeyPair k = BINDKeyUtils.loadKeyPair(keyfiles[i], inDirectory);
      if (k != null) keys.add(k);
    }

    return keys;
  }

  private static List<DnsKeyPair> getKeys(List<Record> dnskeyrrs, File inDirectory)
      throws IOException
  {
    List<DnsKeyPair> res = new ArrayList<DnsKeyPair>();
    for (Record r : dnskeyrrs)
    {
      if (r.getType() != Type.DNSKEY) continue;

      // Construct a public-key-only DnsKeyPair just so we can calculate the
      // base name.
      DnsKeyPair pub = new DnsKeyPair((DNSKEYRecord) r);
      DnsKeyPair pair = BINDKeyUtils.loadKeyPair(BINDKeyUtils.keyFileBase(pub),
                                                 inDirectory);
      if (pair != null)
      {
        res.add(pair);
      }
    }

    if (res.size() > 0) return res;
    return null;
  }

  private static class KeyFileFilter implements FileFilter
  {
    private String prefix;

    public KeyFileFilter(Name origin)
    {
      prefix = "K" + origin.toString();
    }

    public boolean accept(File pathname)
    {
      if (!pathname.isFile()) return false;
      String name = pathname.getName();
      if (name.startsWith(prefix) && name.endsWith(".private")) return true;
      return false;
    }
  }

  private static List<DnsKeyPair> findZoneKeys(File inDirectory, Name zonename)
      throws IOException
  {
    if (inDirectory == null)
    {
      inDirectory = new File(".");
    }

    // get the list of "K<zone>.*.private files.
    FileFilter filter = new KeyFileFilter(zonename);
    File[] files = inDirectory.listFiles(filter);

    // read in all of the records
    ArrayList<DnsKeyPair> keys = new ArrayList<DnsKeyPair>();
    for (int i = 0; i < files.length; i++)
    {
      DnsKeyPair p = BINDKeyUtils.loadKeyPair(files[i].getName(), inDirectory);
      keys.add(p);
    }

    if (keys.size() > 0) return keys;
    return null;
  }

  /**
   * This is an implementation of a file filter used for finding BIND 9-style
   * keyset-* files.
   */
  private static class KeysetFileFilter implements FileFilter
  {
    public boolean accept(File pathname)
    {
      if (!pathname.isFile()) return false;
      String name = pathname.getName();
      if (name.startsWith("keyset-")) return true;
      return false;
    }
  }

  /**
   * Load keysets (which contain delegation point security info).
   * 
   * @param inDirectory
   *          the directory to look for the keyset files (may be null, in
   *          which
   *          case it defaults to looking in the current working directory).
   * @param zonename
   *          the name of the zone we are signing, so we can ignore keysets
   *          that
   *          do not belong in the zone.
   * @return a list of {@link org.xbill.DNS.Record}s found in the keyset
   *         files.
   */
  private static List<Record> getKeysets(File inDirectory, Name zonename)
      throws IOException
  {
    if (inDirectory == null)
    {
      inDirectory = new File(".");
    }

    // get the list of "keyset-" files.
    FileFilter filter = new KeysetFileFilter();
    File[] files = inDirectory.listFiles(filter);

    // read in all of the records
    ArrayList<Record> keysetRecords = new ArrayList<Record>();
    for (int i = 0; i < files.length; i++)
    {
      List<Record> l = ZoneUtils.readZoneFile(files[i].getAbsolutePath(), zonename);
      keysetRecords.addAll(l);
    }

    // discard records that do not belong to the zone in question.
    for (Iterator<Record> i = keysetRecords.iterator(); i.hasNext();)
    {
      Record r = i.next();
      if (!r.getName().subdomain(zonename))
      {
        i.remove();
      }
    }

    return keysetRecords;
  }

  /**
   * Load a list of DNS names from a file.
   * 
   * @param nameListFile
   *          the path of a file containing a bare list of DNS names.
   * @return a list of {@link org.xbill.DNS.Name} objects.
   */
  private static List<Name> getNameList(File nameListFile) throws IOException
  {
    BufferedReader br = new BufferedReader(new FileReader(nameListFile));
    List<Name> res = new ArrayList<Name>();

    String line = null;
    while ((line = br.readLine()) != null)
    {
      try
      {
        Name n = Name.fromString(line);
        // force the name to be absolute.
        // FIXME: we should probably get some fancy logic here to
        // detect if the name needs the origin appended, or just the
        // root.
        if (!n.isAbsolute()) n = Name.concatenate(n, Name.root);

        res.add(n);
      }
      catch (TextParseException e)
      {
        log.severe("DNS Name parsing error:" + e);
      }
    }

    br.close();
    if (res.size() == 0) return null;
    return res;
  }

  /**
   * Determine if the given keypairs can be used to sign the zone.
   * 
   * @param zonename
   *          the zone origin.
   * @param keypairs
   *          a list of {@link DnsKeyPair} objects that will be used to sign
   *          the
   *          zone.
   * @return true if the keypairs valid.
   */
  private static boolean keyPairsValidForZone(Name zonename, List<DnsKeyPair> keypairs)
  {
    if (keypairs == null) return true; // technically true, I guess.

    for (DnsKeyPair kp : keypairs)
    {
      Name keyname = kp.getDNSKEYRecord().getName();
      if (!keyname.equals(zonename))
      {
        return false;
      }
    }

    return true;
  }

  public void execute() throws Exception
  {
    // Read in the zone
    List<Record> records = ZoneUtils.readZoneFile(state.zonefile, null);
    if (records == null || records.size() == 0)
    {
      System.err.println("error: empty zone file");
      state.usage();
    }

    // calculate the zone name.
    Name zonename = ZoneUtils.findZoneName(records);
    if (zonename == null)
    {
      System.err.println("error: invalid zone file - no SOA");
      state.usage();
    }

    // Load the key pairs.

    List<DnsKeyPair> keypairs = getKeys(state.keyFiles, 0, state.keyDirectory);
    List<DnsKeyPair> kskpairs = getKeys(state.kskFiles, 0, state.keyDirectory);

    // If we didn't get any keys on the command line, look at the zone apex for
    // any public keys.
    if (keypairs == null && kskpairs == null)
    {
      List<Record> dnskeys = ZoneUtils.findRRs(records, zonename, Type.DNSKEY);
      keypairs = getKeys(dnskeys, state.keyDirectory);
    }

    // If we *still* don't have any key pairs, look for keys the key directory
    // that match
    if (keypairs == null && kskpairs == null)
    {
      keypairs = findZoneKeys(state.keyDirectory, zonename);
    }

    // If we don't have any KSKs, but we do have more than one zone
    // signing key (presumably), presume that the zone signing keys
    // are just not differentiated and try to figure out which keys
    // are actually ksks by looking at the SEP flag.
    if ((kskpairs == null || kskpairs.size() == 0) && keypairs != null
        && keypairs.size() > 1)
    {
      for (Iterator<DnsKeyPair> i = keypairs.iterator(); i.hasNext();)
      {
        DnsKeyPair pair = i.next();
        DNSKEYRecord kr = pair.getDNSKEYRecord();
        if ((kr.getFlags() & DNSKEYRecord.Flags.SEP_KEY) != 0)
        {
          if (kskpairs == null) kskpairs = new ArrayList<DnsKeyPair>();
          kskpairs.add(pair);
          i.remove();
        }
      }
    }

    // If there are no ZSKs defined at this point (yet there are KSKs
    // provided), all KSKs will be treated as ZSKs, as well.
    if (keypairs == null || keypairs.size() == 0)
    {
      keypairs = kskpairs;
    }

    // If there *still* aren't any ZSKs defined, bail.
    if (keypairs == null || keypairs.size() == 0)
    {
      System.err.println("No zone signing keys could be determined.");
      state.usage();
    }

    // default the output file, if not set.
    if (state.outputfile == null && !state.zonefile.equals("-"))
    {
      if (zonename.isAbsolute())
      {
        state.outputfile = zonename + "signed";
      }
      else
      {
        state.outputfile = zonename + ".signed";
      }
    }

    // Verify that the keys can be in the zone.
    if (!keyPairsValidForZone(zonename, keypairs)
        || !keyPairsValidForZone(zonename, kskpairs))
    {
      System.err.println("error: specified keypairs are not valid for the zone.");
      state.usage();
    }

    // We force the signing keys to be in the zone by just appending
    // them to the zone here. Currently JCEDnsSecSigner.signZone
    // removes duplicate records.
    if (kskpairs != null)
    {
      for (DnsKeyPair pair : kskpairs)
      {
        records.add(pair.getDNSKEYRecord());
      }
    }
    if (keypairs != null)
    {
      for (DnsKeyPair pair : keypairs)
      {
        records.add(pair.getDNSKEYRecord());
      }
    }

    // read in the keysets, if any.
    List<Record> keysetrecs = getKeysets(state.keysetDirectory, zonename);
    if (keysetrecs != null)
    {
      records.addAll(keysetrecs);
    }

    DnsSecSigner signer;
    if (state.parallel)
      signer = new JCEDnsSecParallelSigner(state.verboseSigning);
    else
      signer = new JCEDnsSecSigner(state.verboseSigning);

    // Sign the zone.
    List<Record> signed_records;

    if (state.useNsec3)
    {
      signed_records = signer.signZoneNSEC3(zonename, records, kskpairs, keypairs,
                                            state.start, state.expire,
                                            state.fullySignKeyset, state.useOptOut,
                                            state.includeNames, state.salt,
                                            state.iterations, state.digest_id,
                                            state.nsec3paramttl);
    }
    else
    {
      signed_records = signer.signZone(zonename, records, kskpairs, keypairs,
                                       state.start, state.expire, state.fullySignKeyset,
                                       state.digest_id);
    }

    // write out the signed zone
    ZoneUtils.writeZoneFile(signed_records, state.outputfile);

    if (state.verifySigs)
    {
      // FIXME: ugh.
      if (kskpairs != null)
      {
        keypairs.addAll(kskpairs);
      }

      log.fine("verifying generated signatures");
      boolean res = verifyZoneSigs(zonename, signed_records, keypairs);

      if (res)
      {
        System.out.println("Generated signatures verified");
        // log.info("Generated signatures verified");
      }
      else
      {
        System.out.println("Generated signatures did not verify.");
        // log.warn("Generated signatures did not verify.");
      }
    }

  }

  public static void main(String[] args)
  {
    SignZone tool = new SignZone();
    tool.state = new CLIState();

    tool.run(tool.state, args);
  }
}
