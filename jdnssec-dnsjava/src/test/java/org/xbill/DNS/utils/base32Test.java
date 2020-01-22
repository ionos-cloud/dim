// -*- Java -*-
//
// Copyright (c) 2005, Matthew J. Rutherford <rutherfo@cs.colorado.edu>
// Copyright (c) 2005, University of Colorado at Boulder
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// 
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// 
// * Neither the name of the University of Colorado at Boulder nor the
//   names of its contributors may be used to endorse or promote
//   products derived from this software without specific prior written
//   permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

package org.xbill.DNS.utils;

import junit.framework.TestCase;

public class base32Test extends TestCase
{

  private static final base32 b32padding = new base32(base32.Alphabet.BASE32, true, false);
  private static final base32 b32nopadding = new base32(base32.Alphabet.BASE32, false, false);
  private static final base32 b32hexpadding = new base32(base32.Alphabet.BASE32HEX, true, false);
  private static final base32 b32hexnopadding = new base32(base32.Alphabet.BASE32HEX, false, false);
  
  public base32Test(String name)
  {
    super(name);
  }

  public void test_toString_empty()
  {
    byte[] data = new byte[0];
    String out = b32hexpadding.toString(data);
    assertEquals("", out);
  }

  public void test_toString_basic1()
  {
    byte[] data = {0};
    String out = b32hexpadding.toString(data);
    assertEquals("00======", out);
    out = b32hexnopadding.toString(data);
    assertEquals("00", out);
  }

  public void test_toString_basic2()
  {
    byte[] data = {0, 0};
    String out = b32hexpadding.toString(data);
    assertEquals("0000====", out);
    out = b32hexnopadding.toString(data);
    assertEquals("0000", out);
  }

  public void test_toString_basic3()
  {
    byte[] data = {0, 0, 1};
    String out = b32hexpadding.toString(data);
    assertEquals("00002===", out);
    out = b32hexnopadding.toString(data);
    assertEquals("00002", out);
  }

  public void test_toString_basic4()
  {
    byte[] data = {(byte) 0xFC, 0, 0};
    String out = b32hexpadding.toString(data);
    assertEquals("VG000===", out);
  }

  public void test_toString_basic5()
  {
    byte[] data = {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
    String out = b32hexpadding.toString(data);
    assertEquals("VVVVU===", out);
  }

  public void test_toString_basic6()
  {
    byte[] data = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    String out = b32hexpadding.toString(data);
    assertEquals("041061050O3GG28=", out);
  }

  private void assertEquals(byte[] exp, byte[] act)
  {
    assertEquals(exp.length, act.length);
    for (int i = 0; i < exp.length; ++i)
    {
      assertEquals(exp[i], act[i]);
    }
  }

  public void test_fromString_empty1()
  {
    byte[] out = b32hexpadding.fromString("");
    assertTrue(out == null || out.length == 0);
  }

  public void test_fromString_basic1()
  {
    byte[] exp = {0x53};
    byte[] out = b32hexnopadding.fromString("AC");
    assertEquals(exp, out);
  }

  public void test_fromString_basic1_lc()
  {
    byte[] exp = {0x53};
    byte[] out = b32hexnopadding.fromString("ac");
    assertEquals(exp, out);
  }
  
  public void test_fromString_basic1_padded()
  {
    byte[] exp = {0x53};
    byte[] out = b32hexpadding.fromString("AC======");
    assertEquals(exp, out);
  }
  public void test_fromString_basic2()
  {
    byte[] exp = {0x54, 0x57};
    byte[] out = b32hexnopadding.fromString("AHBG");
    assertEquals(exp, out);
    out = b32hexnopadding.fromString("ahbg");
    assertEquals(exp, out);
    out = b32hexpadding.fromString("ahbg====");
    assertEquals(exp, out);
  }

  public void test_fromString_basic3()
  {
    byte[] exp = {0x64, 0x65, 0x66};
    byte[] out = b32hexnopadding.fromString("CHIMC");
    assertEquals(exp, out);
    out = b32hexnopadding.fromString("chImC");
    assertEquals(exp, out);
    out = b32hexpadding.fromString("chimc===");
    assertEquals(exp, out);
  }

  public void test_fromString_basic4()
  {
    byte[] exp = {(byte) 0xFC, 0, 0};
    byte[] out = b32hexnopadding.fromString("vg000");
    assertEquals(exp, out);
    out = b32hexpadding.fromString("VG000===");
    assertEquals(exp, out);
  }

  public void test_fromString_basic5()
  {
    byte[] exp = {(byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
    byte[] out = b32hexnopadding.fromString("VVVVU");
    assertEquals(out, exp);
  }

  public void test_fromString_basic6()
  {
    byte[] exp = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    byte[] out = b32hexnopadding.fromString("041061050O3GG28");
    assertEquals(out, exp);
    out = b32hexpadding.fromString("041061050O3GG28=");
    assertEquals(out, exp);
  }

  public void test_fromString_invalid1()
  {
    byte[] out = b32hexnopadding.fromString("000");
    assertNull(out);
  }

  public void test_fromString_invalid2()
  {
    byte[] out = b32hexnopadding.fromString("000000");
    assertNull(out);
  }

  public void test_fromString_invalid3()
  {
    byte[] out = b32hexnopadding.fromString("0");
    assertNull(out);
  }

  public void test_fromString_invalid4()
  {
    byte[] out = b32hexnopadding.fromString("WX");
    assertNull(out);
  }

  public void test_fromString_invalid5()
  {
    byte[] out = b32hexpadding.fromString("00=");
    assertNull(out);
  }

}
