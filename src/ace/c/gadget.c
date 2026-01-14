/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: gadget functions **
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
     Date: 1st,2nd,6th November 1993,
	   23rd-25th June 1994,
	   10th,12th July 1994,
	   12th March 1995,
	   6th November 1995
*/

#include "acedef.h"

/* externals */
extern	int	sym;
extern	int	lastsym;

/* functions */
void gadget_rectangle()
{
/* (x1,y1)-(x2,y2) */

    if (sym != lparen) _error(14);
    else
    {
     insymbol();
     make_sure_long(expr());	/* x1 */

     if (sym != comma) _error(16);
     else
     {
      insymbol();
      make_sure_long(expr()); /* y1 */

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
     	 make_sure_long(expr());	/* x2 */

         if (sym != comma) _error(16);
         else
         {
          insymbol();
     	  make_sure_long(expr());	/* y2 */

          if (sym != rparen) _error(9);
	  insymbol();
         }
	}
       }
      }
     }
    }
}

void close_gadget()
{
/* GADGET CLOSE gadget-id */

	insymbol();
     	make_sure_long(expr());	/* gadget-id */

	gen("jsr","_CloseGadget","  ");
	gen("addq","#4","sp");
	enter_XREF("_CloseGadget");
}

void gadget_output()
{
/*
** GADGET OUTPUT id
**
** Make the specified gadget the one from which 
** information may be obtained via the GADGET(n)
** function. This allows the value of a string,
** longint or slider gadget to be obtained at 
** any time rather than just when a gadget event
** occurs.
*/
	insymbol();
     	make_sure_long(expr());	/* gadget-id */

	gen("jsr","_SetCurrentGadget","  ");
	gen("addq","#4","sp");
	enter_XREF("_SetCurrentGadget");
}

void wait_gadget()
{
/* GADGET WAIT gadget-id */

	insymbol();
     	make_sure_long(expr());	/* gadget-id */
	
	gen("jsr","_WaitGadget","  ");
	gen("addq","#4","sp");
	enter_XREF("_WaitGadget");
}

void modify_gadget()
{
/* 
** GADGET MOD gadget-id,knob-position[,max-position] 
**
** For the modification of (proportional) gadgets.
*/

	insymbol();
    	make_sure_long(expr());	/* gadget-id */
	
	if (sym != comma) _error(16);
	else
	{
		insymbol();
    		make_sure_long(expr());	/* knob-position */

		/* specify new maximum notches for slider? */
		if (sym != comma) 
			gen("move.l","#-1","-(sp)");
		else
		{
			insymbol();
    			make_sure_long(expr());	/* max-position */
		}

		/* call function */
		gen("jsr","_modify_gad","  ");
		gen("add.l","#12","sp");
		
		enter_XREF("_modify_gad");
		enter_XREF("_GfxBase");
	}
}

void gadget()
{
/* GADGET gadget-id,status[,gadget-value,(x1,y1)-(x2,y2),type[,style][,font,size,txtstyle]]
   GADGET MOD gadget-id,knob-pos[,max-notches]
   GADGET WAIT gadget-id
   GADGET CLOSE gadget-id
   GADGET ON | OFF | STOP
*/
int  gtype;

	insymbol();
	
	if (sym == onsym || sym == offsym || sym == stopsym)
		change_event_trapping_status(lastsym);
	else
	if (sym == closesym)
		close_gadget();
	else
	if (sym == outputsym)
		gadget_output();
	else
        if (sym == waitsym)
		wait_gadget();
	else
	if (sym == modsym)
		modify_gadget();
	else
	{
    		make_sure_long(expr());	/* gadget-id */

	 	if (sym != comma) _error(16);
	 	else
	 	{
	 		insymbol();
			if (sym == onsym)
			{
				gen("move.l","#1","-(sp)");
				insymbol();
			}
			else
			if (sym == offsym)
			{
				gen("move.l","#0","-(sp)");
				insymbol();
			}
			else
			{
				/* status */
				make_sure_long(expr());
			}

			if (sym != comma)
			{
				gen("jsr","_ChangeGadgetStatus","  ");
				gen("addq","#8","sp");

				enter_XREF("_ChangeGadgetStatus");
				enter_XREF("_GfxBase");	
				return;	
			}
	 	}

		if (sym != comma) _error(16);
		else
		{
			insymbol();
			gtype = expr();	

			/* string or integer expression for 3rd parameter */
			if (gtype != stringtype)
			{
				make_sure_long(gtype);
			}
		}

		if (sym != comma) _error(16);
		else
		{
			insymbol();
			gadget_rectangle();	/* (x1,y1)-(x2,y2) */

			if (sym != comma) _error(16);
			else
			{
				/* 
				** Gadget Type.
				*/
	 			insymbol();

				if (sym == buttonsym)
				{
					gen("move.l","#1","-(sp)");
					insymbol();
				}
				else
				if (sym == stringsym)
				{
					gen("move.l","#2","-(sp)");
					insymbol();
				}
				else
				if (sym == longintsym)
				{
					gen("move.l","#3","-(sp)");
					insymbol();
				}
				else
				if (sym == potxsym)
				{
					gen("move.l","#4","-(sp)");
					insymbol();
				}
				else
				if (sym == potysym)
				{
					gen("move.l","#5","-(sp)");
					insymbol();
				}
				else
				{
					/* type */
					make_sure_long(expr());
				}
			}

			/*
			** Optional gadget style parameter.
			*/
			if (sym != comma)
				gen("move.l","#0","-(sp)");	/* style = 0 */
			else
			{
 				insymbol();

				if (sym != comma)
					make_sure_long(expr());	/* style */
				else
					gen("move.l","#0","-(sp)");  /* style = 0 */	
			}			
		
			/*
			** Optional font and font-size parameters (for button).
			*/
			if (sym != comma)
			{
				gen("move.l","#0","-(sp)");  /* font name = NULL */
				gen("move.l","#0","-(sp)");  /* font size = 0 */
				gen("move.l","#0","-(sp)");  /* font style = 0 */
			}
			else
			{
				insymbol();
				if (expr() != stringtype)    /* font name */
					_error(4);
				else
				{
					if (sym != comma) 
						_error(16);
					else
					{
	 					insymbol();
						make_sure_long(expr());	/* font size */
					}

					if (sym != comma) 
						_error(16);
					else
					{
	 					insymbol();
						make_sure_long(expr());	/* font style */
					}
				}
			}					
	 }

	 /* call function */
	 gen("jsr","_CreateGadget","  ");
	 gen("add.l","#48","sp");

	 enter_XREF("_CreateGadget");
	 enter_XREF("_GfxBase");
	}
}

void	bevel_box()
{
/* 
** BEVELBOX (x1,y1)-(x2,y2),type
*/
	insymbol();

	gadget_rectangle();
	if (sym != comma) _error(16);
	else
	{
		insymbol();
		make_sure_long(expr());	/* type */

	 	/* call function */
		gen("jsr","_BevelBox","  ");
		gen("add.l","#20","sp");

		enter_XREF("_BevelBox");
		enter_XREF("_GfxBase");
	}
}
