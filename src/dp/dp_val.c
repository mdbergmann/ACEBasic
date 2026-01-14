/* 
** Three functions which extract a double-precision numeric value 
** from a string.
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

** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
   
   -- void dp_val(double *,char *) --

   Since Sozobon C doesn't support doubles, we use an array of
   2 long values instead.

   Converts a string into a double-precision floating point value. 

   The string must contain a number of the following format:

	[+|-][.]nnn[.nnn][e|E[+|-]nnn]

	eg: 	1234
		12.25
		-.12
		1.5e+10	

   In other words, any legal AmigaBASIC integer or single-precision literal.

   This source was based upon code for VAL (see dates prior to October 1996).
 
   -------------------------------
   Author: David J Benn
     Date: 19th,24th January 1993,
	   14th,16th February 1993,
	   23rd January 1994,
	   5th June 1994,
	   17th,18th October 1996
   -------------------------------
*/

#define BOOL 	short
#define BYTE 	char

#define TRUE 	(1L)
#define FALSE 	(0L)
#define EOS	'\0'

/* global variables */
char 	ch;	
long	cc;

/* IEEE DP math library bases */
extern	long 	MathIeeeDoubBaseBase;
extern	long 	MathIeeeDoubTransBase;

/* IEEE DP math functions */
void	dp_longint_to_double();
void	dp_add();
void	dp_div();
void	dp_mul();
void	dp_pow();

/* functions */
void nextch(str)
char *str;
{
 /* retrieve next character from string. */

	ch = str[cc++];
}

void dp_val(doubleval,str)
long	doubleval[2];
char 	*str;
{
long 	i;
long 	n[2];
long 	index;
long 	periods;
long	placecount;
long 	places;
long	ex;
long 	ex_sign;
BOOL	period;
long 	sign;
long	a[2],b[2],c[2],d[2],e[2];

  /* zero double value */
  doubleval[0] = doubleval[1] = 0;

  /* start of string */
  cc=0;

  /* convert str to double */
  nextch(str);
  while (ch <= ' ' && ch != EOS) nextch(str);  /* skip leading whitespace */

  /* + | - */
  switch(ch)
  {
   case '-' : 	sign = -1; nextch(str); 
		break;
  
   case '+' :	sign = 1; nextch(str);
		break;

   default  :	sign = 1; 
  }

  if ((ch >= '0' && ch <= '9') || ch == '.')
  {
   n[0]=n[1]=0;
   index=0;
   period=FALSE;
   periods=0;
   placecount=0;
   
   /* is first char '.'? */
   if (ch == '.')
   {
    period=TRUE;
    placecount=0;
    index=1;
    periods++;
   }

   /* get the value */
   if (!period) n[0]=10*n[0]+(ch-'0');

   do
   {
    nextch(str);
    if (ch >= '0' && ch <= '9') n[index]=10*n[index]+(ch-'0');
    if ((ch >= '0' && ch <= '9') && period) placecount++;
    if (ch == '.') periods++;
    if ((ch == '.') && (!period))
    {
     period=TRUE;
     placecount=0;
     index=1;
    }
   }
   while (((ch >= '0' && ch <= '9') || ch == '.') && (periods <= 1));

   /* integer or real? */
   if (period && periods == 1)
   {
    /* make DP */
    places=1;
    for (i=1;i<=placecount;i++) places *= 10;

    /* integer component */
    dp_longint_to_double(a,n[0]);

    /* fractional component */	
    dp_longint_to_double(b,n[1]);
    dp_longint_to_double(c,places);
    dp_div(d,b,c);

    /* DP value */
    dp_add(doubleval,a,d);
   }  
   else 
  	dp_longint_to_double(doubleval,n[0]);

   /* is it a real in exponential form? */
   if (ch == 'E' || ch == 'e')
   {
    ex=0;
    ex_sign=1;

    nextch(str);

    if (ch == '+') { ex_sign=1; nextch(str); }
    else
    if (ch == '-') { ex_sign=-1; nextch(str); }
    
    /* expected a digit so just return 0 */ 
    if (ch < '0' || ch > '9') { doubleval[0] = doubleval[1] = 0; return; }

    /* get digits */
    while (ch >= '0' && ch <= '9') { ex = 10*ex+(ch-'0'); nextch(str); }
    ex *= ex_sign;

    /* convert to DP */
    if (ex >= -308 && ex <= 307)    /* IEEE DP exponent limits as per RKM: Libraries */
    {
     /* if exponent is zero then doubleval=doubleval*1 since 10^0 = 1 */
     if (ex != 0) 
     {
	 /* n * 10^ex */
	 dp_longint_to_double(a,10);
	 dp_longint_to_double(b,ex);
	 dp_pow(c,a,b);
	 dp_mul(d,c,doubleval);
	 doubleval[0] = d[0]; doubleval[1] = d[1]; 
     }
    }
    else
	 doubleval[0] = doubleval[1] = 0;
   }
  }
  else
	doubleval[0] = doubleval[1] = 0;

  /* positive or negative? */
  if (sign == -1)
  {
	dp_neg(b,doubleval);
  	doubleval[0] = b[0]; doubleval[1] = b[1];
  }
} 
