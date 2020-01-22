// $Id$
//
// Copyright (C) 2003 VeriSign, Inc.
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

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.xbill.DNS.Master;
import org.xbill.DNS.Name;
import org.xbill.DNS.RRset;
import org.xbill.DNS.Record;
import org.xbill.DNS.Type;

/**
 * This class contains a bunch of utility methods that are generally useful in
 * manipulating zones.
 * 
 * @author David Blacka (original)
 * @author $Author$
 * @version $Revision$
 */

public class ZoneUtils
{
  /**
   * Load a zone file.
   * 
   * @param zonefile
   *          the filename/path of the zonefile to read.
   * @param origin
   *          the origin to use for the zonefile (may be null if the origin is
   *          specified in the zone file itself).
   * @return a {@link java.util.List} of {@link org.xbill.DNS.Record} objects.
   * @throws IOException
   *           if something goes wrong reading the zone file.
   */
  public static List<Record> readZoneFile(String zonefile, Name origin) throws IOException
  {
    ArrayList<Record> records = new ArrayList<Record>();
    Master m;
    if (zonefile.equals("-"))
    {
      m = new Master(System.in);
    }
    else
    {
      m = new Master(zonefile, origin);
    }

    Record r = null;

    while ((r = m.nextRecord()) != null)
    {
      records.add(r);
    }

    return records;
  }

  /**
   * Write the records out into a zone file.
   * 
   * @param records
   *          a {@link java.util.List} of {@link org.xbill.DNS.Record} objects
   *          forming a zone.
   * @param zonefile
   *          the file to write to. If null or equal to "-", System.out is used.
   */
  public static void writeZoneFile(List<Record> records, String zonefile) throws IOException
  {
    PrintWriter out = null;

    if (zonefile == null || zonefile.equals("-"))
    {
      out = new PrintWriter(System.out);
    }
    else
    {
      out = new PrintWriter(new BufferedWriter(new FileWriter(zonefile)));
    }

    for (Record r : records)
    {
      out.println(r);
    }

    out.close();
  }

  /**
   * Given just the list of records, determine the zone name (origin).
   * 
   * @param records
   *          a list of {@link org.xbill.DNS.Record} objects.
   * @return the zone name, if found. null if one couldn't be found.
   */
  public static Name findZoneName(List<Record> records)
  {
    for (Record r : records)
    {
      int type = r.getType();

      if (type == Type.SOA) return r.getName(); 
    }

    return null;
  }

  public static List<Record> findRRs(List<Record> records, Name name, int type)
  {
    List<Record> res = new ArrayList<Record>();
    for (Record r : records)
    {
      if (r.getName().equals(name) && r.getType() == type)
      {
        res.add(r);
      }
    }

    return res;
  }

  /** This is an alternate way to format an RRset into a string */
  @SuppressWarnings("unchecked")
  public static String rrsetToString(RRset rrset, boolean includeSigs)
  {
    StringBuilder out = new StringBuilder();

    for (Iterator<Record> i = rrset.rrs(false); i.hasNext();)
    {
      Record r = i.next();
      out.append(r.toString());
      out.append("\n");
    }

    if (includeSigs)
    {
      for (Iterator<Record> i = rrset.sigs(); i.hasNext();)
      {
        Record r = i.next();
        out.append(r.toString());
        out.append("\n");
      }
    }
    return out.toString();
  }
}
