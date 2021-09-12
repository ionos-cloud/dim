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

import java.io.FileWriter;
import java.io.PrintWriter;

import org.apache.commons.cli.*;
import org.xbill.DNS.DLVRecord;
import org.xbill.DNS.DNSKEYRecord;
import org.xbill.DNS.DSRecord;
import org.xbill.DNS.Record;

import com.verisignlabs.dnssec.security.*;

/**
 * This class forms the command line implementation of a DNSSEC DS/DLV generator
 * 
 * @author David Blacka
 */
public class DSTool extends CLBase
{
  private CLIState state;

  /**
   * This is a small inner class used to hold all of the command line option
   * state.
   */
  protected static class CLIState extends CLIStateBase
  {
    public boolean createDLV  = false;
    public String  outputfile = null;
    public String  keyname    = null;
    public int     digest_id  = DSRecord.SHA1_DIGEST_ID;

    public CLIState()
    {
      super("jdnssec-dstool [..options..] keyfile");
    }

    /**
     * Set up the command line options.
     * 
     * @return a set of command line options.
     */
    protected void setupOptions(Options opts)
    {
      OptionBuilder.withLongOpt("dlv");
      OptionBuilder.withDescription("Generate a DLV record instead.");
      opts.addOption(OptionBuilder.create());

      OptionBuilder.hasArg();
      OptionBuilder.withLongOpt("digest");
      OptionBuilder.withArgName("id");
      OptionBuilder.withDescription("The Digest ID to use (numerically): either 1 for SHA1 or 2 for SHA256");
      opts.addOption(OptionBuilder.create('d'));
    }

    protected void processOptions(CommandLine cli)
        throws org.apache.commons.cli.ParseException
    {
      outputfile = cli.getOptionValue('f');
      createDLV = cli.hasOption("dlv");
      String optstr = cli.getOptionValue('d');
      if (optstr != null) digest_id = parseInt(optstr, digest_id);

      String[] cl_args = cli.getArgs();

      if (cl_args.length < 1)
      {
        System.err.println("error: missing key file ");
        usage();
      }

      keyname = cl_args[0];
    }

  }

  public void execute() throws Exception
  {
    DnsKeyPair key = BINDKeyUtils.loadKey(state.keyname, null);
    DNSKEYRecord dnskey = key.getDNSKEYRecord();

    if ((dnskey.getFlags() & DNSKEYRecord.Flags.SEP_KEY) == 0)
    {
      log.warning("DNSKEY is not an SEP-flagged key.");
    }

    DSRecord ds = SignUtils.calculateDSRecord(dnskey, state.digest_id, dnskey.getTTL());
    Record res = ds;

    if (state.createDLV)
    {
      log.fine("creating DLV.");
      DLVRecord dlv = new DLVRecord(ds.getName(), ds.getDClass(), ds.getTTL(),
                                    ds.getFootprint(), ds.getAlgorithm(),
                                    ds.getDigestID(), ds.getDigest());
      res = dlv;
    }

    if (state.outputfile != null)
    {
      PrintWriter out = new PrintWriter(new FileWriter(state.outputfile));
      out.println(res);
      out.close();
    }
    else
    {
      System.out.println(res);
    }
  }

  public static void main(String[] args)
  {
    DSTool tool = new DSTool();
    tool.state = new CLIState();

    tool.run(tool.state, args);
  }
}
