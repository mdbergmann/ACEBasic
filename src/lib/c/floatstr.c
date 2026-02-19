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

   -- char *strsingle(float) --

   This function converts a single-precision (IEEE 754) floating point
   number into a string of fixed-point or exponential format.

   Uses sprintf for formatting.

   Author: David J Benn
     Date: 16th,18th February 1993
   Modified: 2026 — rewritten for IEEE 754 (sprintf-based)
*/

#include "lib_protos.h"

static char 	fnumbuf[40];	/* final buffer for transformed fnum */

/* external references */
extern	long	decimal_places;	/* number of places to round to -- default=8 */

/* strsingle() */
char 	*strsingle(fnum)
float 	fnum;
{
 if (fnum == 0.0f)
 {
  fnumbuf[0] = ' ';
  fnumbuf[1] = '0';
  fnumbuf[2] = '\0';
  return fnumbuf;
 }

 if (decimal_places != 8)
 {
  /* FIX format: fixed number of decimal places */
  if (fnum < 0.0f)
   sprintf(fnumbuf, "%.*f", (int)decimal_places, (double)fnum);
  else
   sprintf(fnumbuf, " %.*f", (int)decimal_places, (double)fnum);
 }
 else
 {
  /* default: up to 7 significant digits, auto-select format */
  if (fnum < 0.0f)
   sprintf(fnumbuf, "%.7G", (double)fnum);
  else
   sprintf(fnumbuf, " %.7G", (double)fnum);
 }

 return fnumbuf;
}
