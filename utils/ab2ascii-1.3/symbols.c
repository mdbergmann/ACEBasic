/*
 *  SYMBOLS.C
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
   Allocate a new symbol w/ len+1 bytes for it's '\0' terminated name and link it to sym_tab.
   This function is only called by read_sym()
*/

static symbol_t *
alloc_sym( len, id )
int len, id;
{
  symbol_t *sym;

  if( sym= (symbol_t *)malloc(SYMBOL_SIZE) )
  {
    if( sym->s= (char *)malloc( (len+1) * sizeof(char)) )
    {
      sym->next= sym_tab;
      sym_tab= sym;

      sym->id= id;
      sym->s[0]= '\0';
    }
    else
    {
      free(sym);
      sym= NIL(symbol_t *);
    }
  }

  return sym;
}


/*
   Allocate a new symbol via alloc_sym() and read it's name from stdin.
   Return 1 for success, 0 if there was not enough free store.
*/

int
read_sym( fp, len, id )
FILE *fp;
int len, id;
{
  symbol_t *sym;

  if( sym = alloc_sym(len,id) )
  {
    int i;
    char *s= sym->s;

    for( i=0; i<len && !feof(fp); i++ )
      s[i]= fgetc(fp);

    s[len]= '\0';
  }

  return sym ? 1:0;
}


/*
   Lookup a symbol by it's id in the sym_tab and return a pointer to it's name
   or NIL(char *) if the referenced id does not exist
*/

char *
get_sym( id )
int id;
{
  symbol_t *sym;

  for( sym= sym_tab; sym; sym= sym->next )
    if( sym->id == id )
      return sym->s;

  return NIL(char *);
}


/* free up all memory allocated via alloc_sym() */

void
free_symbols( void )
{
  while(sym_tab)
  {
    symbol_t *sym= sym_tab;
    sym_tab= sym_tab->next;

    if(sym->s)
      free(sym->s);

    free(sym);
  }
}
