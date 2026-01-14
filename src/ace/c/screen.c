/*
** <<ACE>>
**
** Amiga BASIC Compiler **
**
** Parser: screens **
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
** Author: David J Benn
**   Date: 16th February 1994 (code removed from statement.c)
*/

#include "acedef.h"

/* external */
extern	int	sym;

/* functions */
void	screen()
{
/*
** SCREEN [CLOSE|FORWARD|BACK]
*/
int	rword,stype;

  insymbol();

  /* SCREEN CLOSE screen-id */
  if (sym == closesym) 
  {
   insymbol();
   make_sure_short(expr()); /* screen-id */
   gen("move.w","(sp)+","d0");
   gen("jsr","_closescreen","  ");
   enter_XREF("_closescreen");
   enter_XREF("_IntuitionBase");
  }
  else
  /* SCREEN FORWARD|BACK screen-id */
  if (sym == forwardsym || sym == backsym)
  {
	rword = sym;

	insymbol();
	stype = expr();
	if (stype == stringtype)
		_error(4);
	else
	{
		/* screen-id */
		make_sure_short(stype);
		gen("move.w","(sp)+","d0");

		/* forward or back? */
		switch(rword)
		{
			case forwardsym : gen("move.w","#1","d1"); break;
			case backsym 	: gen("move.w","#2","d1"); break;
		}

		gen("jsr","_change_screen_depth","  ");

		enter_XREF("_change_screen_depth");
		enter_XREF("_IntuitionBase");
	}
  }
  else
  /* SCREEN screen-id,width,height,colors,mode */
  {
   /* open a screen */
   make_sure_short(expr()); /* screen-id */
   if (sym != comma) _error(16);
   else
   {
    insymbol();
    make_sure_short(expr()); /* width */
    if (sym != comma) _error(16);
    else
    {
     insymbol();
     make_sure_short(expr()); /* height */
     if (sym != comma) _error(16);
     else
     {
      insymbol();
      make_sure_short(expr()); /* depth */
      if (sym != comma) _error(16);
      else
      {
       insymbol();
       make_sure_short(expr()); /* mode */
       
       /* pop parameters */
       gen("move.w","(sp)+","d4"); /* mode */
       gen("move.w","(sp)+","d3"); /* depth */
       gen("move.w","(sp)+","d2"); /* height */
       gen("move.w","(sp)+","d1"); /* width */
       gen("move.w","(sp)+","d0"); /* screen-id (1-9) */

       /* open the screen */
       gen("jsr","_openscreen","  ");
       enter_XREF("_openscreen");
       enter_XREF("_GfxBase");
      }
     }
    }
   }
  }
}
