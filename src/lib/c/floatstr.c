/* ACE floating point to string conversion.
** Copyright (C) 1998 David Benn
**
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public License
** as published by the Free Software Foundation; either version 2
** of the License, or (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

   -- char *strsingle(long) --

   This function converts a single-precision (IEEE 754) floating point
   number into a string of fixed-point or exponential format.

   Parameter is the IEEE 754 bit pattern passed as a long integer.
   Digit extraction uses C float arithmetic; output formatting is manual
   (AmigaDOS sprintf does not support %f/%G formats).

   Author: David J Benn
     Date: 16th,18th February 1993
   Modified: 2026 — rewritten for IEEE 754 with manual formatting
*/

#include <exec/types.h>

static char 	fnumbuf[40];

/* external references */
extern	long	decimal_places;

/* helper: extract integer digit from float in [0, 10) range */
static long extract_digit(fval)
float fval;
{
 long d;

 d = 0;
 if (fval >= 1.0f) d = 1;
 if (fval >= 2.0f) d = 2;
 if (fval >= 3.0f) d = 3;
 if (fval >= 4.0f) d = 4;
 if (fval >= 5.0f) d = 5;
 if (fval >= 6.0f) d = 6;
 if (fval >= 7.0f) d = 7;
 if (fval >= 8.0f) d = 8;
 if (fval >= 9.0f) d = 9;
 return d;
}

/* strsingle: convert IEEE SP float (as long bits) to string */
char *strsingle(fbits)
long fbits;
{
 union { long l; float f; } u;
 float fnum;
 long negative, exp, i, d, lastdig, carry;
 long ndigits;
 char digits[9];
 char *dest;

 u.l = fbits;
 fnum = u.f;

 /* zero */
 if (fnum == 0.0f)
 {
  fnumbuf[0] = ' ';
  fnumbuf[1] = '0';
  fnumbuf[2] = '\0';
  return fnumbuf;
 }

 /* sign */
 negative = 0;
 if (fnum < 0.0f) { negative = 1; fnum = -fnum; }

 /* normalize to [1.0, 10.0) and find decimal exponent */
 exp = 0;
 while (fnum >= 10.0f) { fnum /= 10.0f; exp++; }
 while (fnum < 1.0f)   { fnum *= 10.0f; exp--; }

 /* extract 8 significant digits */
 ndigits = 8;
 for (i = 0; i < ndigits; i++)
 {
  d = extract_digit(fnum);
  digits[i] = (char)('0' + d);
  fnum = (fnum - (float)d) * 10.0f;
 }

 /* round using 8th digit */
 if (digits[7] >= '5')
 {
  carry = 1;
  for (i = 6; i >= 0 && carry; i--)
  {
   digits[i] += 1;
   if (digits[i] > '9') { digits[i] = '0'; }
   else carry = 0;
  }
  if (carry)
  {
   /* overflow: e.g. 9.999999 rounded up to 10 */
   digits[0] = '1';
   for (i = 1; i < 7; i++) digits[i] = '0';
   exp++;
  }
 }

 /* find last non-zero digit among first 7 */
 lastdig = 0;
 for (i = 0; i < 7; i++)
 {
  if (digits[i] != '0') lastdig = i;
 }

 dest = fnumbuf;

 if (decimal_places != 8)
 {
  /* FIX format: fixed number of decimal places */
  long dp, round_pos, int_digs;

  dp = decimal_places;
  if (dp < 0) dp = 0;
  if (dp > 7) dp = 7;

  /* round_pos = number of significant digits needed */
  round_pos = exp + 1 + dp;

  /* re-round at the appropriate position if needed */
  if (round_pos >= 0 && round_pos < 7)
  {
   if (digits[round_pos] >= '5')
   {
    carry = 1;
    for (i = round_pos - 1; i >= 0 && carry; i--)
    {
     digits[i] += 1;
     if (digits[i] > '9') { digits[i] = '0'; }
     else carry = 0;
    }
    if (carry)
    {
     digits[0] = '1';
     for (i = 1; i < 7; i++) digits[i] = '0';
     exp++;
     round_pos = exp + 1 + dp;
    }
   }
   /* zero out digits beyond round_pos */
   for (i = round_pos; i < 7; i++) digits[i] = '0';
  }

  /* leading sign */
  *dest++ = negative ? '-' : ' ';

  /* integer part */
  int_digs = exp + 1;
  if (int_digs <= 0)
  {
   *dest++ = '0';
  }
  else
  {
   for (i = 0; i < int_digs && i < 7; i++)
    *dest++ = digits[i];
   /* pad with zeros if integer part extends beyond our digits */
   for (; i < int_digs; i++)
    *dest++ = '0';
  }

  /* decimal point and fractional digits */
  if (dp > 0)
  {
   *dest++ = '.';
   if (int_digs < 0)
   {
    /* leading zeros after decimal point */
    long lead_zeros = -int_digs;
    if (lead_zeros > dp) lead_zeros = dp;
    for (i = 0; i < lead_zeros; i++) *dest++ = '0';
    dp -= lead_zeros;
   }
   /* fractional digits from our digit array */
   for (i = 0; i < dp; i++)
   {
    long idx = (exp + 1) + i;
    if (idx < 0)
     *dest++ = '0';
    else if (idx < 7)
     *dest++ = digits[idx];
    else
     *dest++ = '0';
   }
  }
 }
 else
 {
  /* Default: up to 7 significant digits, auto fixed/exponential */
  *dest++ = negative ? '-' : ' ';

  if (exp >= -6 && exp <= 6)
  {
   /* Fixed-point format */
   if (exp >= 0)
   {
    /* digits before decimal point */
    for (i = 0; i <= exp; i++)
    {
     *dest++ = (i < 7) ? digits[i] : '0';
    }
    /* fractional digits (if any non-zero remain) */
    if (exp < lastdig)
    {
     *dest++ = '.';
     for (i = exp + 1; i <= lastdig; i++)
      *dest++ = digits[i];
    }
   }
   else
   {
    /* 0.00...digits (exp is negative) */
    *dest++ = '0';
    *dest++ = '.';
    for (i = 0; i < -(exp + 1); i++) *dest++ = '0';
    for (i = 0; i <= lastdig; i++) *dest++ = digits[i];
   }
  }
  else
  {
   /* Exponential format: d.ddddddEsnn */
   long absexp;
   *dest++ = digits[0];
   if (lastdig > 0)
   {
    *dest++ = '.';
    for (i = 1; i <= lastdig; i++) *dest++ = digits[i];
   }
   *dest++ = 'E';
   if (exp >= 0)
    *dest++ = '+';
   else
   {
    *dest++ = '-';
    exp = -exp;
   }
   absexp = exp;
   if (absexp >= 10) *dest++ = '0' + (char)(absexp / 10);
   *dest++ = '0' + (char)(absexp % 10);
  }
 }

 *dest = '\0';
 return fnumbuf;
}
