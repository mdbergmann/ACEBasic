/*
 *  CODELINES.C
 */

/*
 * (c)Copyright 1994 by Tobias Ferber.
 *
 * This file is part of AmigaBASIC->ASCII.
 *
 * AmigaBASIC->ASCII is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 1 of the
 * License, or (at your option) any later version.
 *
 * AmigaBASIC->ASCII is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AmigaBASIC->ASCII; see the file COPYING.  If not, write to
 * the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "abasic.h"

/*
   Allocate and read one line of code and link it to the global code_buffer.
   The fread() function will be used with `len' packets size of size 1 because
   fread() returns the number of *complete* packets read.  This way we can also
   handle partial packets if needed.
   The number of 1 byte packets read will be returned.  If this value is != len
   then this indicates an error.
*/


static codeline_t *cl_tail= NIL(codeline_t *);

int
read_line( fp, len, flags )
FILE *fp;
int len, flags;
{
  codeline_t *cl;
  int n= 0;

  if( cl= (codeline_t *)malloc(CODELINE_SIZE) )
  {
    unsigned char *s= (unsigned char *)malloc( (len+1) * sizeof(unsigned char) );

    if( s )
    {
      cl->s= s;
      cl->len= len;
      cl->flags= flags;

      cl->next= NIL(codeline_t *);

      if(cl_tail)  cl_tail->next= cl;
      else         code_buffer= cl;

      cl_tail= cl;

      /*for( n=0; n<len && !feof(fp); s[n++]= fgetc(fp) );*/

      n= (int)fread(s, 1L, len, fp);
      s[len]= '\0';

      ++numlines;
    }
    else
    {
      free(cl);
      cl= NIL(codeline_t *);
    }
  }
  /* else panic! */

  return cl ? n:0;
}


/*
   Free up all lines of code linked to the global code_buffer.  Normally all
   code lines are free()d up immediately after they have been expanded by
   expand_code() but in fact we need it for two reasons:

   (1) to purge the code area (e.g. in case of a fatal error)
   (2) to reset cl_tail!  This means you *MUST* call free_code() even if
       code_buffer is empty!
*/

void
free_code( void )
{
  codeline_t *cl= code_buffer;

  while(cl)
  {
    codeline_t *t= cl;
    cl= cl->next;

    if(t->s)
      free(t->s);

    free(t);
  }

  code_buffer= cl_tail= NIL(codeline_t *);
}
