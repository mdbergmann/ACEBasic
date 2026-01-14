/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: window functions **
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
     Date: 26th October-30th November, 1st-13th December 1991,
	   14th,20th-27th January 1992, 
           2nd-17th, 21st-29th February 1992, 
	   1st,13th,14th,22nd,23rd March 1992,
	   21st,22nd April 1992,
	   2nd,3rd,11th,15th,16th May 1992,
	   7th,8th,9th,11th,13th,14th,28th,29th,30th June 1992,
	   2nd-8th,14th-19th,26th-29th July 1992,
	   1st-3rd,7th,8th,9th August 1992,
	   6th,7th December 1992,
	   24th,26th October 1993,
	   15th November 1993,
	   30th April 1994
*/

#include "acedef.h"

/* externals */
extern	int	sym;
extern	int	lastsym;

/* functions */
void window()
{
int wtype;

 /* WINDOW wdw-id[,title],rectangle[,type][,screen-id] 
    WINDOW CLOSE wdw-id
    WINDOW OUTPUT wdw-id 
    WINDOW ON | OFF | STOP
*/

 insymbol();

 if (sym == onsym || sym == offsym || sym == stopsym)
    change_event_trapping_status(lastsym);
 else
 if (sym == closesym) wdwclose();
 else
 if (sym == outputsym) wdwoutput();
 else
 {
  /* open a window */
  if (make_integer(expr()) == shorttype) make_long();      /* Wdw-id */
  if (sym != comma) _error(16);
  else
  {
   insymbol();
   if (sym != comma)
   {
    wtype=expr();
    if (wtype != stringtype) _error(4); /* type mismatch */
   }
   else
	gen("move.l","#0","-(sp)");	/* NULL */
   
   if (sym != comma) _error(16);
   else
   {
    insymbol();
    if (sym != lparen) _error(14);
    else
    {
     insymbol();
     if (make_integer(expr()) == shorttype) make_long();  /* x1 */
     if (sym != comma) _error(16);
     else
     {
      insymbol();
      if (make_integer(expr()) == shorttype) make_long();  /* y1 */
      if (sym != rparen) _error(9);
      else
      {
       insymbol();
       if (sym != minus) _error(21);
       else
       {
        insymbol();
        if (sym != lparen) _error(14);
        else
        {
         insymbol(); 
         if (make_integer(expr()) == shorttype) make_long();  /* x2 */
         if (sym != comma) _error(16);
         else
         {
          insymbol();
          if (make_integer(expr()) == shorttype) make_long();  /* y2 */
          if (sym != rparen) _error(9);
         }

	 insymbol();
	 
	 /* optional window type */
	 if (sym == comma)
	 {
		insymbol();
		if (sym != comma)
		{
			if (make_integer(expr()) == shorttype) 
		   	   make_long();  /* type */
		}
		else
			gen("move.l","#-1","-(sp)");
	 }
	 else
		gen("move.l","#-1","-(sp)");

	 /* optional screen-id */
	 if (sym == comma)
	 {
		insymbol();
		if (sym != comma)
		{
			if (make_integer(expr()) == shorttype) 
		   	   make_long();  /* scrn-id */
		}
		else
			gen("move.l","#0","-(sp)");
	 }
	 else
		gen("move.l","#0","-(sp)");		
	 
	 /* call open-window routine */
	 gen("jsr","_OpenWdw","  ");
	 gen("add.l","#32","sp");
	 enter_XREF("_OpenWdw");
	 enter_XREF("_IntuitionBase");
	 enter_XREF("_GfxBase");
        }
       }
      }
     }
    }	
   }
  }
 }
}

void wdwclose()
{
 insymbol();
 if (make_integer(expr()) == shorttype) make_long();	/* Wdw-id */
 gen("jsr","_CloseWdw","  ");
 gen("addq","#4","sp");
 enter_XREF("_CloseWdw");
 enter_XREF("_IntuitionBase");
}

void wdwoutput()
{
 insymbol();
 if (make_integer(expr()) == shorttype) make_long();	/* Wdw-id */
 gen("jsr","_ChangeOutputWdw","  ");
 gen("addq","#4","sp");
 enter_XREF("_ChangeOutputWdw");
 enter_XREF("_IntuitionBase");
}
