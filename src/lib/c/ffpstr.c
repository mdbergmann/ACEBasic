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

   This function converts a single-precision (FFP) floating point
   number into a string of fixed-point or exponential format.

   Uses fpa() to give a string of the form: +|-.nnnnnnnn+|-Enn

   Author: David J Benn
     Date: 16th,18th February 1993
*/

static char 	fnumbuf[40];	/* final buffer for transformed fnum */

/* external references */
extern	long 	MathBase; 	/* FFP math library base */
extern	long	decimal_places;	/* number of places to round to -- default=8 */

/* FFP math functions */
long 	SPTst();
float	afp();

/* strsingle() */
char 	*strsingle(fnum)
float 	fnum;
{
static 	char 	fpabuf[15];
static	char	ex_buf[3];
char 	*src,*dest,*tmp;
long	ex,nonzero,i,j;

 /* convert fnum to ASCII format */
 ex=fpa(fnum,fpabuf);

 /* round? (see _fix in ffp.s) */
 if (decimal_places != 8) 
 {
  arnd(decimal_places,ex,fpabuf);
  fnum=afp(fpabuf);
 }

 src=fpabuf;
 dest=fnumbuf;

 if (SPTst(fnum) == 0) 
 { 
  *dest++=' ';
  *dest++='0';
  *dest='\0';
  return(fnumbuf); 
 }
 else
 {
  /* find last non-zero digit */
  for (nonzero=9;src[nonzero]=='0';--nonzero);

  /* leading minus or space */
  if (src[0] == '-') *dest++ = '-'; else *dest++ = ' ';

  /* if exponent is < 0 -> need leading zeros */
  if (ex <= 0) 
  {
   if (ex >= -6)
   {
    /* fixed-point format */
    *dest++='0'; 
    *dest++='.';
    for (i=1;i<=-ex;i++) *dest++='0';
    for (i=2;i<=nonzero;i++) *dest++=src[i];
   }
   else
   {
    /* exponential format */
    /* mantissa */
    *dest++=src[2];  /* first digit */
    *dest++='.';
    if (nonzero > 2) 
       for (i=3;i<=nonzero;i++) *dest++=src[i];
    else
       *dest++='0';  /* no fractional part after first digit */

    /* include exponent */
    *dest++='E';
    *dest++=src[11]; /* sign of exponent */
    sprintf(ex_buf,"%ld",-ex+1); /* exponent */
    *dest++=ex_buf[0];
    *dest++=ex_buf[1];
   }
  }
  else
  /* id exponent is > 0 -> print digits until last non-zero digit */
  if (ex <= 7)
  { 
   /* fixed-point format */
   for (i=2;i<=ex+1;i++) *dest++=src[i];
   if (i <= nonzero) *dest++='.';  /* if nonzero=i -> integer */ 
   for (j=i;j<=nonzero;j++) *dest++=src[j];
  }
  else
  {
   /* exponential format */
   /* mantissa */
   *dest++=src[2];  /* first digit */
   *dest++='.';
   if (nonzero > 2) 
      for (i=3;i<=nonzero;i++) *dest++=src[i];
   else
      *dest++='0';  /* no fractional part after first digit */

   /* include exponent */
   *dest++='E';
   *dest++=src[11]; /* sign of exponent */
   sprintf(ex_buf,"%ld",ex-1); /* exponent */
   *dest++=ex_buf[0];
   *dest++=ex_buf[1];
  }
 }  

 *dest='\0';
 return(fnumbuf);
}
