/* << ACE >> - db.lib module: C string functions.
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
**
**  Author: David J Benn
**    Date: 19th,20th March 1994,
**	    17th October 1996
*/

#include <exec/types.h>

/* functions */

void stringcopy(a,b)
char *a,*b;
{
 	/* copy contents of b to a */

	while (*a++ = *b++);
}

ULONG stringlength(a)
char *a;
{
long i=0;

	/* return length of a */

	while (a[i]) i++;
	return(i);			
}

LONG stringcompare(s,t)
char *s,*t;
{
	/* lexicographical comparison of 2 strings */

	while (s && t && *s == *t)
	{
		if (!*s) return(0);  /* EOS */
		s++;
		t++;
	}

	/* if either string is null treat as if it were "" ? */

	if (s && !t) 
		return(*s);   /* ie. *s - 0 */
	else
	if (!s && t) 
		return(0 - *t);
	else
		return(*s - *t);
}
