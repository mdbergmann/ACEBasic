/* 
** ACE -- CLI/Shell command line argument functions: 
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
**	  parse_cli_args -- parses raw command line buffer, counts arguments
**   		            and creates a buffer of NULL terminated arguments.
**
**     	  arg	         -- copies the Nth command line argument to the 
**		            specified buffer. 
**
**	  argcount       -- returns the number of command line arguments.
**
** Author: David J Benn
**   Date: 6th June 1993,
**	   24th August 1994,
**	   10th September 1994
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>

#define QUOTE '"'

/* CLI/shell Process address */
extern struct Process *TaskAddress;

/* raw command line data */
extern char *cmdbuf;
extern long cmdlen;

/* final command line argument data */
char   *argbuf=NULL;
static long nargs=0L;

void parse_cli_args()
{
char *src,*dest;
long nchars;

 /* 
 ** This function takes a source buffer consisting of
 ** the characters following a CLI command and converts
 ** it into a series of discrete arguments. An array of
 ** pointers is set to hold the start address of each 
 ** of up to 32 such arguments. 
 */ 

 /* 
 ** Allocate memory for arg buffer; allocating
 ** at least as much memory as there is in the
 ** source buffer will guarantee enough space
 ** is set aside for the arguments.
 ** There is a space before the first character
 ** which makes up for the lack of a terminating 
 ** NULL in the string.
 */
 argbuf = (char *)AllocMem(cmdlen,MEMF_ANY);
 if (argbuf == NULL) return;

 /* point to source and target buffers */
 src = cmdbuf;
 dest = argbuf;
 
 /* number of characters in buffer */
 nchars = cmdlen;

 while (nchars > 0)
 { 
  /* skip whitespace */
  while (*src <= ' ' && nchars > 0) { ++src; --nchars; }
 
  /* end of CLI buffer? */
  if (nchars == 0) return;

  /* increment argument counter */
  ++nargs;

  /* get quoted argument? */
  if (*src == QUOTE)
  {
   ++src; --nchars; /* skip first quote */
   while (*src != QUOTE && nchars > 0) { *dest++ = *src++; --nchars; }
   *dest++ = '\0'; 
   if (*src == QUOTE) { ++src; --nchars; } /* skip second quote */
  }
  else
  {
   /* get unquoted argument */  
   while (*src > ' ' && nchars > 0)  { *dest++ = *src++; --nchars; }
   *dest++ = '\0';
  }
 }
}

char *arg(buf,n)
char *buf;
long n;
{
long   count,length,i;
char   *src,*dest;
struct CommandLineInterface *cli;

/* Return the Nth command line argument 
   or the CLI/shell command name in the 
   specified buffer. 
 */

 if (n == 0)
 {
  /* return command name */
  cli = (struct CommandLineInterface *) ((long)TaskAddress->pr_CLI << 2);
  src = (char *) ((long)cli->cli_CommandName << 2);
  length = (long)src[0];
  src++;  /* skip past BCPL string character count */
  dest = buf;
  for (i=1;i<=length;i++) *dest++ = *src++;
  *dest = '\0';
 }
 else
 if (n > nargs || argbuf == NULL) 
    /* not N arguments or arg buffer not allocated -> NULL string */ 
    buf[0] = '\0';
 else
 {
  /* get Nth argument */
  count=1;
  src=argbuf;
  while (count != n) 
  {
   while (*src++ != '\0');
   ++count;
  } 

  /* copy argument into buffer */
  dest=buf;
  while (*dest++ = *src++); 
 }

 return(buf);
}

long argcount()
{
 /* Returns the number of command line arguments. */
 return(nargs);
}
