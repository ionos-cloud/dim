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

import java.security.interfaces.DSAPublicKey;
import java.security.interfaces.RSAPublicKey;

import org.apache.commons.cli.*;
import org.xbill.DNS.DNSKEYRecord;

import com.verisignlabs.dnssec.security.*;

/**
 * This class forms the command line implementation of a key introspection tool.
 * 
 * @author David Blacka
 */
public class KeyInfoTool extends CLBase
{
  private CLIState state;

  /**
   * This is a small inner class used to hold all of the command line option
   * state.
   */
  protected static class CLIState extends CLIStateBase
  {
    public String[] keynames = null;

    public CLIState()
    {
      super("jdnssec-keyinfo [..options..] keyfile");
    }

    /**
     * Set up the command line options.
     */
    protected void setupOptions(Options opts)
    {
      // no special options at the moment.
    }

    protected void processOptions(CommandLine cli) throws ParseException
    {
      keynames = cli.getArgs();

      if (keynames.length < 1)
      {
        System.err.println("error: missing key file ");
        usage();
      }
    }
  }

  public void execute() throws Exception
  {
    for (int i = 0; i < state.keynames.length; ++i)
    {
      String keyname = state.keynames[i];
      DnsKeyPair key = BINDKeyUtils.loadKey(keyname, null);
      DNSKEYRecord dnskey = key.getDNSKEYRecord();
      DnsKeyAlgorithm dnskeyalg = DnsKeyAlgorithm.getInstance();

      boolean isSEP = (dnskey.getFlags() & DNSKEYRecord.Flags.SEP_KEY) != 0;

      System.out.println(keyname + ":");
      System.out.println("Name: " + dnskey.getName());
      System.out.println("SEP: " + isSEP);

      System.out.println("Algorithm: " + dnskeyalg.algToString(dnskey.getAlgorithm())
          + " (" + dnskey.getAlgorithm() + ")");
      System.out.println("ID: " + dnskey.getFootprint());
      System.out.println("KeyFileBase: " + BINDKeyUtils.keyFileBase(key));
      int basetype = dnskeyalg.baseType(dnskey.getAlgorithm());
      switch (basetype)
      {
        case DnsKeyAlgorithm.RSA: {
          RSAPublicKey pub = (RSAPublicKey) key.getPublic();
          System.out.println("RSA Public Exponent: " + pub.getPublicExponent());
          System.out.println("RSA Modulus: " + pub.getModulus());
          break;
        }
        case DnsKeyAlgorithm.DSA: {
          DSAPublicKey pub = (DSAPublicKey) key.getPublic();
          System.out.println("DSA base (G): " + pub.getParams().getG());
          System.out.println("DSA prime (P): " + pub.getParams().getP());
          System.out.println("DSA subprime (Q): " + pub.getParams().getQ());
          System.out.println("DSA public (Y): " + pub.getY());
          break;
        }
      }
      if (state.keynames.length - i > 1)
      {
        System.out.println();
      }
    }
  }

  public static void main(String[] args)
  {
    KeyInfoTool tool = new KeyInfoTool();
    tool.state = new CLIState();

    tool.run(tool.state, args);
  }
}
