/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: memory functions **
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
     Date: 13th,14th June 1993,
	   3rd July 1993
*/

#include "acedef.h"

/* locals */
int	struct_member_type;  /* for SWAP -> filled by address_of_object() */

/* externals */
extern	int	sym;
extern	int	lev;
extern 	SYM	*curr_item;
extern	char	id[MAXIDSIZE];
extern	char	tempstrname[80];

/* -------------- */
/* POKE functions */
/* -------------- */

void poke()
{
int addrtype;

 /* get address */
 insymbol();
 addrtype=make_integer(expr());
 if ((addrtype == longtype) || (addrtype == shorttype))
 {
  /* make sure address is long */
  if (addrtype == shorttype)
  {
   gen("move.w","(sp)+","d0");
   gen("ext.l","d0","  ");
   gen("move.l","d0","-(sp)");
  }
  if (sym == comma)
  { 
   /* get value */
   insymbol();
   make_sure_short(expr());
   gen("move.w","(sp)+","d0");   /* data to be poked */
   gen("move.l","(sp)+","a0");   /* address */
   gen("move.b","d0","(a0)");    /* poke (a0),d0 */
  }
 }
 else _error(4);
}

void pokew()
{
int addrtype;

 /* get address */
 insymbol();
 addrtype=make_integer(expr());
 if ((addrtype == longtype) || (addrtype == shorttype))
 {
  /* make sure address is long */
  if (addrtype == shorttype)
  {
   gen("move.w","(sp)+","d0");
   gen("ext.l","d0","  ");
   gen("move.l","d0","-(sp)");
  }
  if (sym == comma)
  { 
   /* get value */
   insymbol();
   make_sure_short(expr());
   gen("move.w","(sp)+","d0");   /* data to be poked */
   gen("move.l","(sp)+","a0");   /* address */
   gen("move.w","d0","(a0)");    /* pokew (a0),d0 */
  }
 }
 else _error(4);
}

void pokel()
{
int addrtype,datatype;

 /* get address */
 insymbol();
 addrtype=make_integer(expr());
 if ((addrtype == longtype) || (addrtype == shorttype))
 {
  /* make sure address is long */
  if (addrtype == shorttype)
  {
   gen("move.w","(sp)+","d0");
   gen("ext.l","d0","  ");
   gen("move.l","d0","-(sp)");
  }
  if (sym == comma)
  { 
   /* get value */
   insymbol();
   datatype=make_integer(expr());
   if ((datatype == shorttype) || (datatype == longtype))
   {
    /* coerce data to long */
    if (datatype == shorttype)
    {
     gen("move.w","(sp)+","d0");
     gen("ext.l","d0","  ");
    }
    else
        gen("move.l","(sp)+","d0");   /* data to be poked */
    gen("move.l","(sp)+","a0");       /* address */
    gen("move.l","d0","(a0)");	       /* pokel (a0),d0 */
   }
   else _error(4);
  }
 }
 else _error(4);
}

/* ---- */
/* SWAP */
/* ---- */
void get_obj_info(objname,object,objtype)
char *objname;
int  *object;
int  *objtype;
{
/* get info about a variable, extvar, array or structure for SWAP */

BOOL found=FALSE;

 if (exist(objname,variable))
    found = TRUE;
 else
 if (exist(objname,extvar))
    found = TRUE;
 else
 if (exist(objname,array))
    found = TRUE;
 else
 if (exist(objname,structure))
    found = TRUE;

 if (found)
 {
  *object = curr_item->object;
  *objtype = curr_item->type;
 }
 else
 {
  *object = undefined;
  *objtype = undefined;
 }
}

void swap()
{
/* SWAP <object>,<object> */

char first[MAXIDSIZE],second[MAXIDSIZE],bssbuf[80];
int  typ1,typ2,dataobj1,dataobj2;

 insymbol();

 if (sym != ident) _error(7);
 else
 {
  strcpy(first,id);
  address_of_object();
  get_obj_info(first,&dataobj1,&typ1);

  /* get_obj_info() won't tell us about structure member type */
  if (dataobj1 == structure) typ1 = struct_member_type;

  if (dataobj1 != structure && dataobj1 != array) insymbol();

  if (sym != comma) _error(16);
  else
  {
   insymbol();
   if (sym != ident) _error(7);
   else
   {
    strcpy(second,id);
    address_of_object();
    get_obj_info(second,&dataobj2,&typ2);

    /* get_obj_info() won't tell us about structure member type */
    if (dataobj2 == structure) typ2 = struct_member_type;

    if (dataobj2 != structure && dataobj2 != array) insymbol();

    /* if two objects are of same data type -> swap them */
    if (typ1 != typ2) _error(4);
    else
    {
     gen("movea.l","(sp)+","a2"); /* second address */
     gen("movea.l","(sp)+","a1"); /* first address */

     if (typ1 == stringtype)
     {
      /* make copies of two addresses */
      gen("move.l","a1","d1"); /* first address */
      gen("move.l","a2","d2"); /* second address */

      make_temp_string();

      /* copy first to temp */
      gen("movea.l","d1","a1");    /* source */ 
      gen("lea",tempstrname,"a0"); /* dest */ 
      gen("jsr","_strcpy","  ");   /* temp = first */

      /* copy second to first */
      gen("movea.l","d2","a1");    /* source */ 
      gen("movea.l","d1","a0");    /* dest */ 
      gen("jsr","_strcpy","  ");   /* first = second */ 

      /* copy temp to second */
      gen("lea",tempstrname,"a1"); /* source */ 
      gen("movea.l","d2","a0");    /* dest */
      gen("jsr","_strcpy","  ");   /* second = temp */

      enter_XREF("_strcpy");
     }
     else
     if (typ1 == shorttype)
     {
      gen("move.w","(a1)","d0");   /* temp = [first] */
      gen("move.w","(a2)","(a1)"); /* [first] = [second] */
      gen("move.w","d0","(a2)");   /* [second] =temp */     
     }
     else
     {
      gen("move.l","(a1)","d0");   /* temp = [first] */
      gen("move.l","(a2)","(a1)"); /* [first] = [second] */
      gen("move.l","d0","(a2)");   /* [second] =temp */     
     }
    }
   }
  }
 } 
}
