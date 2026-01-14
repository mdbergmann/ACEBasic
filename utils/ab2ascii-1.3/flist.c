/*
 *  FLIST.C
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

#include <ctype.h>
#include <stdlib.h>

typedef struct fnode
{
  struct fnode *next;
  char *filename;

} fnode_t;

static fnode_t *flist= (fnode_t *)0L;


int
chain_fname(fname)
char *fname;
{
  static fnode_t *tail= (fnode_t *)0L;

  fnode_t *fn= (fnode_t *)malloc( sizeof(fnode_t) );

  if( fn )
  {
    fn->filename= fname;
    fn->next= (fnode_t *)0L;

    if(!flist)
       flist= fn;

    if(tail)
      tail->next= fn;

    tail= fn;
  }

  return fn ? 0:1;
}


char *
unchain_fname( void )
{
  char *fname= (char *)0L;

  if(flist)
  {
    fnode_t *fn= flist;
    flist= flist->next;

    fname= fn->filename;
    free(fn);
  }

  return fname;
}


void
purge_flist( void )
{
  while(flist)
  {
    fnode_t *fn= flist;
    flist= flist->next;
    free(fn);
  }
}
