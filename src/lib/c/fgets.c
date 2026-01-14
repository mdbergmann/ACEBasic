/* main ACE linked library module: buffered file functions.
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

       fgets: get at most n chars from iop (also returns string or NULL). 
    fgetline: get at most n chars from iop but don't include the final '\n'.
   fgetchars: get at most n chars from iop including '\n's.
  fgetseqfld: get the next sequential field in the specified file.

   fgets() was taken from K&R, 2nd ed., pg 165
   for use in db.lib

   fgetline(), fgetchars() and fgetseqfld() are variations on fgets().
 
   Date: 4th-6th January 1993
*/

#define EOF	(-1L)
#define NULL	(0L)

char *fgets(s,n,iop)
char *s;
unsigned long n;
unsigned long iop;
{
int  c;
char *cs;
 
 cs = s;
 while (--n > 0 && (c = fgetc(iop)) != EOF)
     if ((*cs++ = c) == '\n')
 	break;
 *cs = '\0';
 return (c == EOF && cs == s) ? NULL : s;  
}

void fgetline(s,n,iop)
char *s;
unsigned long n;
unsigned long iop;
{
int  c;
char *cs;
 
 cs = s;
 while (--n > 0 && (c = fgetc(iop)) != EOF)
     if ((*cs++ = c) == '\n')
 	break;
 if (cs != s) --cs;  /* overwrite the '\n' */
 *cs = '\0';
}

void fgetchars(s,n,iop)
char *s;
unsigned long n;
unsigned long iop;
{
int  c;
char *cs;
 
 cs = s;
 while (--n > 0 && (c = fgetc(iop)) != EOF) *cs++ = c;
 *cs = '\0';
}

void fgetseqfld(s,n,iop)
char *s;
unsigned long n;
unsigned long iop;
{
int  c;
char *cs;

 cs = s;

 --n;

 /* skip whitespace (incl. LF) and commas 
    (latter from after a quote-delimited string) */
 while ((c = fgetc(iop)) != EOF && (c <= ' ' || c == ','));

 /* quote-delimited string? */
 if (n > 0 && c == '"')
 {
  do
  {
   c = fgetc(iop);
   if (c != '"' && c != EOF) *cs++=c;
  }
  while (--n > 0 && c != '"' && c != EOF);

  *cs='\0';

  fgetc(iop);	/* - Assume next character is EOF, whitespace or comma. 
		   - The next test for EOF by ACE or this function will
		     be positive if we're now at EOF. This prevents ACE
		     from trying to read another line (say in a WHILE loop)
		     and getting NULL strings. 
		*/

  return;
 }

 /* get the next field: could be a non-delimited string, integer or float */
 while (n > 0 && c != EOF)
 {
     if ((*cs++ = c) <= ' ' || c == ',')  
        break;	/* delimiters are: whitespace (incl. LF), comma */
 
     --n;

     c = fgetc(iop);
 }

 if (cs != s) --cs;  /* overwrite the delimiter */
 *cs = '\0';
}
