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

import java.util.Comparator;
import java.util.logging.Logger;

/**
 * This class implements a basic comparator for byte arrays. It is primarily
 * useful for comparing RDATA portions of DNS records in doing DNSSEC canonical
 * ordering.
 * 
 * @author David Blacka (original)
 * @author $Author$
 * @version $Revision$
 */
public class ByteArrayComparator implements Comparator<byte[]>
{
  private int     mOffset = 0;
  private boolean mDebug  = false;
  private Logger log;

  public ByteArrayComparator()
  {
  }

  public ByteArrayComparator(int offset, boolean debug)
  {
    mOffset = offset;
    mDebug = debug;
  }

  public int compare(byte[] b1, byte[] b2)
  {
    for (int i = mOffset; i < b1.length && i < b2.length; i++)
    {
      if (b1[i] != b2[i])
      {
        if (mDebug)
        {
          log.info("offset " + i + " differs (this is "
              + (i - mOffset) + " bytes in from our offset.)");
        }
        return (b1[i] & 0xFF) - (b2[i] & 0xFF);
      }
    }

    return b1.length - b2.length;
  }
}
