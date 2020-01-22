// $Id$
//
// Copyright (C) 2000-2003 Network Solutions, Inc.
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

import java.util.Comparator;

import org.xbill.DNS.RRSIGRecord;
import org.xbill.DNS.Record;
import org.xbill.DNS.Type;

/**
 * This class implements a comparison operator for {@link org.xbill.DNS.Record}
 * objects. It imposes a canonical order consistent with DNSSEC. It does not put
 * records within a RRset into canonical order: see {@link ByteArrayComparator}.
 * 
 * @author David Blacka (original)
 * @author $Author$
 * @version $Revision$
 */

public class RecordComparator implements Comparator<Record>
{
  public RecordComparator()
  {
  }

  /**
   * In general, types are compared numerically. However, SOA, NS, and DNAME are ordered
   * before the rest.
   */
  private int compareTypes(int a, int b)
  {
    if (a == b) return 0;
    if (a == Type.SOA) return -1;
    if (b == Type.SOA) return 1;

    if (a == Type.NS) return -1;
    if (b == Type.NS) return 1;

    if (a == Type.DNAME) return -1;
    if (b == Type.DNAME) return 1;
    
    if (a < b) return -1;

    return 1;
  }

  private int compareRDATA(Record a, Record b)
  {
    byte[] a_rdata = a.rdataToWireCanonical();
    byte[] b_rdata = b.rdataToWireCanonical();

    for (int i = 0; i < a_rdata.length && i < b_rdata.length; i++)
    {
      int n = (a_rdata[i] & 0xFF) - (b_rdata[i] & 0xFF);
      if (n != 0) return n;
    }
    return (a_rdata.length - b_rdata.length);
  }

  public int compare(Record a, Record b)
  {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    int res = a.getName().compareTo(b.getName());
    if (res != 0) return res;

    int a_type = a.getType();
    int b_type = b.getType();
    int sig_type = 0;

    if (a_type == Type.RRSIG)
    {
      a_type = ((RRSIGRecord) a).getTypeCovered();
      if (b_type != Type.RRSIG) sig_type = 1;
    }
    if (b_type == Type.RRSIG)
    {
      b_type = ((RRSIGRecord) b).getTypeCovered();
      if (a.getType() != Type.RRSIG) sig_type = -1;
    }

    res = compareTypes(a_type, b_type);
    if (res != 0) return res;

    if (sig_type != 0) return sig_type;

    return compareRDATA(a, b);
  }
}
