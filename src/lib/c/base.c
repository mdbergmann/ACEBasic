/* ACE linked library module: BIN$, OCT$ 
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

   Author: David J Benn
     Date: 29th June 1993
*/

char *base(n,buf,radexp)
long n;
char *buf;
long radexp;
{
long q,r,i,cc=-1;
static char tmp[32];
/* convert a long integer to a 
   string of base 2^radexp */

 if (n == 0L) 
    { buf[0] = '0'; buf[1] = '\0'; }
 else
 {
  while (n != 0)
  {
   q = n >> radexp;		/* quotient = number div 2 */
   r = n - (q << radexp); 	/* remainder = quotient mod 2 */
   n >>= radexp;			/* number = number div 2 */
   tmp[++cc] = '0'+r; 
  }
  /* reverse digits */
  for (i=cc;i>=0;i--) buf[cc-i] = tmp[i];
  buf[cc+1] = '\0';
 }           

 return(buf);
}
