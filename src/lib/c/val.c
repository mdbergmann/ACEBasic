/* Three functions which extract a numeric value from a string.
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

   -- float val(char *) --

   Converts a string into a floating point value (IEEE 754 single-precision).

   The string must contain a number of the following format:

	[+|-][.]nnn[.nnn][e|E[+|-]nnn]

	eg: 	1234
		12.25
		-.12
		1.5e+10

   In other words, any legal AmigaBASIC integer or single-precision literal.

   Moreover, if the number is preceded by &H or &O the digits which follow
   will be treated as hexadecimal and octal respectively.


   -- long long_from_string(char *) --

	          and

   -- short short_from_string(char *) --

   Both functions convert a string into an integer value. The first
   returns a long integer, the second returns a short integer.

   The string must contain a number of the following format:

	[+|-]nnn

   -------------------------------
   Author: David J Benn
     Date: 19th,24th January 1993,
	   14th,16th February 1993,
	   23rd January 1994,
	   5th June 1994
   Modified: 2026 — rewritten for native C float (IEEE 754)
   -------------------------------
*/

#define BOOL 	short
#define BYTE 	char

#define TRUE 	(1L)
#define FALSE 	(0L)
#define EOS	'\0'

#define DEC	(0L)
#define OCT	(1L)
#define HEX	(2L)

/* global variables */
char 	ch;
long	cc;

/* functions */
void nextch(str)
char *str;
{
 /* retrieve next character from string
    and convert to uppercase if necessary.
 */
 ch = str[cc++];
 if (ch >= 'a' && ch <= 'z') ch -= 32;
}

BOOL digit(radix)
long radix;
{
BOOL legal_digit=FALSE;

 /* test the legality of a digit */

 switch(radix)
 {
  case DEC : if (ch >= '0' && ch <= '9') legal_digit=TRUE; break;

  case OCT : if (ch >= '0' && ch <= '7') legal_digit=TRUE; break;

  case HEX : if ((ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'F'))
		legal_digit=TRUE; break;
 }

 return(legal_digit);
}

long digit_value(radix)
long radix;
{
long value=0;

 /* return the actual value of a digit (legality assumed) */

 switch(radix)
 {
  case DEC :
  case OCT :	value = ch-'0';
		break;

  case HEX :  	if (ch <= '9') value = ch-'0'; else value = 10+ch-'A';
		break;
 }

 return(value);
}

float val(char *str)
{
long	radix;
long 	base;
long 	i;
long 	n[2];
long 	index;
long 	periods;
long	placecount;
long 	places;
long	ex;
long 	ex_sign;
BOOL	period;
float 	sign;
float	singleval;

  /* start of string */
  cc=0;

  /* assume base 10 */
  radix=DEC;
  base=10;

  /* convert str to float */
  nextch(str);
  while (ch <= ' ' && ch != EOS) nextch(str);  /* skip leading whitespace */

  /* &H or &O? */
  if (ch == '&')
  {
   nextch(str);
   switch(ch)
   {
    case 'H' : radix=HEX; base=16; break;
    case 'O' : radix=OCT; base=8;  break;
    default  : return(0.0f);	/* unknown symbol */
   }
   nextch(str);
  }

  /* + | - */
  switch(ch)
  {
   case '-' : 	sign = -1.0f; nextch(str);
		break;

   case '+' :	sign = 1.0f; nextch(str);
		break;

   default  :	sign = 1.0f;
  }

  if (digit(radix) || (ch == '.'))
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
   if (!period) n[0]=base*n[0]+digit_value(radix);
   do
   {
    nextch(str);
    if (digit(radix)) n[index]=base*n[index]+digit_value(radix);
    if (digit(radix) && period) placecount++;
    if (ch == '.') periods++;
    if ((ch == '.') && (!period))
    {
     period=TRUE;
     placecount=0;
     index=1;
    }
   }
   while ((digit(radix) || ch == '.') && (periods <= 1));

   /* integer or real? */
   if (period && (periods == 1) && radix == DEC)
   {
    /* compute float value: integer_part + fractional_digits / 10^places */
    places=1;
    for (i=1;i<=placecount;i++) places *= base;
    singleval = (float)n[0] + (float)n[1] / (float)places;
   }
   else
       singleval = (float)n[0];

   if (radix != DEC) return(singleval);

   /* is it a real in exponential form? */
   if (ch == 'E')
   {
    ex=0;
    ex_sign=1;
    nextch(str);
    if (ch == '+') { ex_sign=1; nextch(str); }
    else
       if (ch == '-') { ex_sign=-1; nextch(str); }
    if (!digit(radix)) singleval = 0.0f;  /* expected a digit so just return 0 */
    /* get digits */
    while (digit(radix)) { ex = base*ex+digit_value(radix); nextch(str); }
    ex *= ex_sign;

    /* apply power of 10 */
    if ((ex >= -20) && (ex <= 18))
    {
     if (ex != 0)
     {
      float tenpow = 1.0f;
      long absex = (ex < 0) ? -ex : ex;
      for (i = 0; i < absex; i++) tenpow *= 10.0f;
      if (ex < 0)
          singleval /= tenpow;
      else
          singleval *= tenpow;
     }
    }
    else
        singleval = 0.0f;	 /* exponent out of range, so just return 0 */
   }
  }
  else
      singleval = 0.0f;   /* illegal character for start of number */

  singleval *= sign;	/* positive or negative */

 return(singleval);
}

long long_from_string(str)
char *str;
{
long	radix;
long 	base;
long	sign;
long	longval;

  /* set final value to zero */
  longval=0;

  /* start of string */
  cc=0;

  /* assume base 10 */
  radix=DEC;
  base=10;

  /* convert str to long integer */
  nextch(str);
  while (ch <= ' ' && ch != EOS) nextch(str);  /* skip leading whitespace */

  /* &H or &O? */
  if (ch == '&')
  {
   nextch(str);
   switch(ch)
   {
    case 'H' : radix=HEX; base=16; break;
    case 'O' : radix=OCT; base=8;  break;
    default  : return(0);	/* unknown symbol */
   }
   nextch(str);
  }

  /* + | - */
  switch(ch)
  {
   case '-' : 	sign = -1; nextch(str);
		break;

   case '+' :	sign = 1; nextch(str);
		break;

   default  :	sign = 1;
  }

  /* extract the integer value */
  longval=0;

  /* get the value */
  while (digit(radix))
  {
   longval=base*longval+digit_value(radix);
   nextch(str);
  }

 longval *= sign;

 return(longval);
}

short short_from_string(str)
char *str;
{
 return((short)long_from_string(str));
}
