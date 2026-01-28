/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: event trapping code **
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
	   6th,7th,21st December 1992,
	   13th,28th February 1993,
	   1st March 1993,
	   25th September 1993,
	   24th,25th,26th October 1993,
	   2nd,8th-10th November 1993,
	   24th July 1994,
	   7th,8th August 1995
*/

#include "acedef.h"

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	SYM	*curr_item;

extern	char   	id[MAXIDSIZE]; 
extern	SHORT  	shortval;
extern	LONG   	longval; 
extern	LONG   singleval;

extern	BOOL 	break_event;
extern	BOOL 	menu_event;
extern	BOOL 	mouse_event;
extern	BOOL 	timer_event;
extern	BOOL 	error_event;
extern	BOOL 	wdw_event;
extern	BOOL 	gad_event;

extern	BOOL 	break_event_label_exists;
extern	BOOL 	menu_event_label_exists;
extern	BOOL 	mouse_event_label_exists;
extern	BOOL 	timer_event_label_exists;
extern	BOOL 	error_event_label_exists;
extern	BOOL 	wdw_event_label_exists;
extern	BOOL 	gad_event_label_exists;

extern	BOOL  	ontimerused;
extern	BOOL	gadtoolsused;

extern	BOOL 	break_opt;
extern	BOOL 	wdw_close_opt;

extern	int	break_event_branch;
extern	int	menu_event_branch;
extern	int	mouse_event_branch;
extern	int	timer_event_branch;
extern	int	error_event_branch;
extern	int	wdw_event_branch;
extern	int	gad_event_branch;

extern	char 	break_event_label[80];
extern	char 	menu_event_label[80];
extern	char 	mouse_event_label[80];
extern	char 	timer_event_label[80];
extern	char 	error_event_label[80];
extern	char 	wdw_event_label[80];
extern	char 	gad_event_label[80];

extern	LONG    timer_event_seconds;
extern	char  	ontimer_seconds[40];

/* functions */
void get_event_trap_label()
{
/* ON <event>|[TIMER(n)] GOSUB <label> | GOTO <label> | CALL <SUBname> */
int   event;
int   branchsym;
char  theLabel[80];

 if ((sym != breaksym) && (sym != menusym) &&
     (sym != mousesym) && (sym != timersym) && 
     (sym != errorsym) && (sym != windowsym) &&
     (sym != gadgetsym))
    _error(55);
 else
 {
  event=sym; /* remember event specifier */

  /* if TIMER, get single-precision seconds */
  if (event == timersym)
  {
   insymbol();
   if (sym != lparen) _error(14);
   else
   {
    insymbol();
    if ((sym != shortconst) && (sym != longconst) &&
        (sym != singleconst)) _error(27); /* numeric constant expected */
    else
    {
     switch(sym)
     {
      case shortconst  : timer_event_seconds=SPFlt((ULONG)shortval); break;
      case longconst   : timer_event_seconds=SPFlt((ULONG)longval);  break;
      case singleconst : timer_event_seconds=singleval; break;
     }
     sprintf(ontimer_seconds,"#$%lx",timer_event_seconds);
     insymbol();
     if (sym != rparen) _error(9);       
    }
   }
  }
  insymbol();
  if (sym != gosubsym && sym != gotosym && sym != callsym) 
     _error(56);
  else
  {
   branchsym=sym; /* GOSUB, GOTO or CALL? */

   insymbol();
   if (sym != ident && sym != shortconst && sym != longconst)
       _error(57);  /* label or SUB name expected */
   else
   {
     /* Make a label from a line number? */
     if (sym != ident) make_label_from_linenum(sym,id);

     /* 
     ** Convert to a SUB label, check for existence 
     ** (defined or declared) of SUB and number of 
     ** parameters (must be zero to be valid).
     */	
     if (branchsym == callsym) 
     {
	sprintf(theLabel,"_SUB_%s",id);
	if (!exist(theLabel,subprogram))
	{
		_error(59);
		return;
	}
	else
	if (curr_item->no_of_params != 0)
	{
		_error(78);
		return;
	}
     }
     else
	strcpy(theLabel,id);

     switch(event)
     {
      case breaksym : strcpy(break_event_label,theLabel);
		      break_event_label_exists=TRUE; 
		      break_event_branch=branchsym;
		      break;

      case menusym  : strcpy(menu_event_label,theLabel);
 		      menu_event_label_exists=TRUE;
		      menu_event_branch=branchsym;
		      break;

      case mousesym : strcpy(mouse_event_label,theLabel); 
		      mouse_event_label_exists=TRUE;
		      mouse_event_branch=branchsym;
		      break;

      case timersym : strcpy(timer_event_label,theLabel); 
		      timer_event_label_exists=TRUE;
		      timer_event_branch=branchsym;
		      break;

      case errorsym : strcpy(error_event_label,theLabel); 
		      error_event_label_exists=TRUE;
		      error_event_branch=branchsym;
		      break;

      case windowsym : strcpy(wdw_event_label,theLabel); 
		      wdw_event_label_exists=TRUE;
		      wdw_event_branch=branchsym;
		      break;

      case gadgetsym : strcpy(gad_event_label,theLabel); 
		      gad_event_label_exists=TRUE;
		      gad_event_branch=branchsym;
		      break;
     }
    insymbol();
   }
  }
 }
}

void change_event_trapping_status(event)
int event;
{
/* <event> ON|OFF|STOP */
int action;

 if (lastsym != windowsym && lastsym != gadgetsym &&
     lastsym != menusym) insymbol();

 if ((sym != onsym) && (sym != offsym) && (sym != stopsym))
    _error(58); /* ON, OFF or STOP expected */
 else
 {
  action=sym; /* remember action symbol */
  insymbol();
  /* enable event trapping for <event>. */
  if (action == onsym)
     switch(event)
     {
      case breaksym : if (break_event_label_exists) 
		         break_event=TRUE;
                      else _error(59);
		      break;

      case menusym  : if (menu_event_label_exists) 
		         menu_event=TRUE;
                      else _error(59);
		      break;

      case mousesym : if (mouse_event_label_exists) 
		         mouse_event=TRUE;
                      else _error(59);
		      break;

      case timersym : if (timer_event_label_exists) 
		         { timer_event=TRUE; ontimerused=TRUE; }
                      else _error(59);
		      break;

      case errorsym : if (error_event_label_exists) 
		         error_event=TRUE;
                      else _error(59);
		      break;

      case windowsym : if (wdw_event_label_exists) 
		         wdw_event=TRUE;
                      else _error(59);
		      break;

      case gadgetsym : if (gad_event_label_exists) 
		         gad_event=TRUE;
                      else _error(59);
		      break;
     }
  else
  /* disable event trapping for <event>. */
  if (action == offsym)
     switch(event)
     {
      case breaksym : if (break_event_label_exists) 
		         { break_event=FALSE; break_event_label_exists=FALSE; }
                      else _error(59);
		      break;

      case menusym  :  if (menu_event_label_exists) 
		          { menu_event=FALSE; menu_event_label_exists=FALSE; }
                       else _error(59);
		       break;

      case mousesym : if (mouse_event_label_exists) 
		         { mouse_event=FALSE; mouse_event_label_exists=FALSE; }
                      else _error(59);
		      break;

      case timersym : if (timer_event_label_exists) 
		         { timer_event=FALSE; timer_event_label_exists=FALSE; }
                      else _error(59);
		      break;

      case errorsym : if (error_event_label_exists) 
		         { error_event=FALSE; error_event_label_exists=FALSE; }
                      else _error(59);
		      break;

      case windowsym : if (wdw_event_label_exists) 
		         { wdw_event=FALSE; wdw_event_label_exists=FALSE; }
                      else _error(59);
		      break;

      case gadgetsym : if (gad_event_label_exists) 
		         { gad_event=FALSE; gad_event_label_exists=FALSE; }
                      else _error(59);
		      break;
     }
  else
  /* disable event trapping for <event> but remember trapping routine. */ 
  if (action == stopsym)
     switch(event)
     {
      case breaksym : if (break_event_label_exists) 
		         break_event=FALSE;
                      else _error(59);
		      break;

      case menusym  : if (menu_event_label_exists) 
		         menu_event=FALSE;
                      else _error(59);
		      break;

      case mousesym : if (mouse_event_label_exists) 
		         mouse_event=FALSE;
                      else _error(59);
		      break;

      case timersym : if (timer_event_label_exists) 
		         timer_event=FALSE;
                      else _error(59);
		      break;

      case errorsym : if (error_event_label_exists) 
		         error_event=FALSE;
                      else _error(59);
		      break;

      case windowsym : if (wdw_event_label_exists) 
		         wdw_event=FALSE;
                      else _error(59);
		      break;

      case gadgetsym : if (gad_event_label_exists) 
		         gad_event=FALSE;
                      else _error(59);
		      break;
     }

  insymbol();
 } 
}

void turn_event_off(eventHandler)
char *eventHandler;
{
/* 
** Turn event trapping off if this 
** subroutine/subprogram belongs to 
** an event.
*/
     if ((strcmp(eventHandler,break_event_label) == 0) && (break_event))
        { break_event=FALSE; break_event_label_exists=FALSE; }
     else
     if ((strcmp(eventHandler,menu_event_label) == 0) && (menu_event))
        { menu_event=FALSE; menu_event_label_exists=FALSE; }
     else
     if ((strcmp(eventHandler,mouse_event_label) == 0) && (mouse_event))
        { mouse_event=FALSE; mouse_event_label_exists=FALSE; }
     else
     if ((strcmp(eventHandler,timer_event_label) == 0) && (timer_event))
        { timer_event=FALSE; timer_event_label_exists=FALSE; }
     else
     if ((strcmp(eventHandler,error_event_label) == 0) && (error_event))
        { error_event=FALSE; error_event_label_exists=FALSE; }
     else
     if ((strcmp(eventHandler,wdw_event_label) == 0) && (wdw_event))
        { wdw_event=FALSE; wdw_event_label_exists=FALSE; }
     else
     if ((strcmp(eventHandler,gad_event_label) == 0) && (gad_event))
        { gad_event=FALSE; gad_event_label_exists=FALSE; }
}

void check_for_event()
{
/* produce code for event trapping */
 if (break_opt)   	ctrl_c_test();
 if (break_event) 	break_event_test();
 if (menu_event)  	menu_event_test();
 if (wdw_close_opt)	wdw_close_test(); 
 if (wdw_event) 	wdw_event_test();
 if (gad_event) 	gad_event_test();
 if (mouse_event) 	mouse_event_test();
 if (timer_event) 	timer_event_test();
 if (error_event) 	error_event_test();
}

void ctrl_c_test()
{
char lab[80],lablabel[80];

/* test for ctrl-c signal 
   and exit program if a 
   break signal is pending. */

   make_label(lab,lablabel);

   gen("jsr","_ctrl_c_test","  ");
   gen("tst.l","d0","  ");
   gen("beq.s",lab,"  ");
   gen("jmp","_EXIT_PROG","  ");
   gen(lablabel,"  ","  ");

   enter_XREF("_ctrl_c_test");
}

void break_event_test()
{
char lab[80],lablabel[80];

/* test for ctrl-c signal 
   and pass control to the
   BREAK trapping subroutine. */

   make_label(lab,lablabel);

   gen("jsr","_ctrl_c_test","  ");
   gen("tst.l","d0","  ");
   gen("beq.s",lab,"  ");

   if (break_event_branch == callsym)
      gen("jsr",break_event_label,"  ");
   else
   if (break_event_branch == gosubsym) 
      gen_branch("jsr",break_event_label);
   else
      gen_branch("jmp",break_event_label);

   gen(lablabel,"  ","  ");

   enter_XREF("_ctrl_c_test");
}

void menu_event_test()
{
char lab[80],lablabel[80];

/* test for menu button press 
   and pass control to the
   MENU trapping subroutine. */

 gen("jsr","_menu_test","  ");
 gen("tst.l","d0","  ");
 make_label(lab,lablabel);
 gen("beq.s",lab,"  ");

 if (menu_event_branch == callsym)
   gen("jsr",menu_event_label,"  ");
 else
 if (menu_event_branch == gosubsym) 
    gen_branch("jsr",menu_event_label);
 else
    gen_branch("jmp",menu_event_label);
 gen(lablabel,"  ","  ");
 enter_XREF("_menu_test");
}

void mouse_event_test()
{
char lab[80],lablabel[80];

/* test for left mouse button 
   press and pass control to the
   MOUSE trapping subroutine. */

 gen("moveq","#0","d0");
 gen("jsr","_mouse","  ");
 gen("tst.l","d0","  ");
 make_label(lab,lablabel);
 gen("beq.s",lab,"  ");

 if (mouse_event_branch == callsym)
    gen("jsr",mouse_event_label,"  ");
 else
 if (mouse_event_branch == gosubsym) 
    gen_branch("jsr",mouse_event_label);
 else
    gen_branch("jmp",mouse_event_label);
 gen(lablabel,"  ","  ");
 enter_XREF("_mouse");
}

void timer_event_test()
{
char lab[80],lablabel[80];

/* test for timer event 
   and pass control to the
   TIMER trapping subroutine. */

 gen("move.l",ontimer_seconds,"d0");
 gen("jsr","_ontimer","  ");
 gen("tst.l","d0","  ");
 make_label(lab,lablabel);
 gen("beq.s",lab,"  ");

 if (timer_event_branch == callsym)
   gen("jsr",timer_event_label,"  ");
 else
 if (timer_event_branch == gosubsym) 
   gen_branch("jsr",timer_event_label);
 else
   gen_branch("jmp",timer_event_label);
 gen(lablabel,"  ","  ");
 enter_XREF("_ontimer");
 enter_XREF("_MathBase");  /* timer routines need mathffp.library */
}

void error_event_test()
{
char lab[80],lablabel[80];

/* Test for I/O error condition 
   and pass control to the ERROR
   trapping subroutine.
*/

 gen("jsr","_testerror","  ");
 gen("tst.l","d0","  ");
 make_label(lab,lablabel);
 gen("beq.s",lab,"  ");

 if (error_event_branch == callsym)
    gen("jsr",error_event_label,"  ");
 else
 if (error_event_branch == gosubsym) 
    gen_branch("jsr",error_event_label);
 else
    gen_branch("jmp",error_event_label);
 gen(lablabel,"  ","  ");
 enter_XREF("_testerror");
}

void wdw_close_test()
{
char lab[80],lablabel[80];

/* Test for close-gadget selection 
   in any window and exit program 
   if close-gadget click detected.

   The clicked window will be closed
   before the program exits.
*/
   make_label(lab,lablabel);

   gen("move.l","#1","-(sp)");
   gen("jsr","_wdw_close_test","  ");
   gen("addq","#4","sp");
   gen("tst.l","d0","  ");
   gen("beq.s",lab,"  ");
   gen("jmp","_EXIT_PROG","  ");
   gen(lablabel,"  ","  ");

   enter_XREF("_wdw_close_test");
}

void wdw_event_test()
{
char lab[80],lablabel[80];

/* Test for close-gadget selection 
   in any window and transfer control
   to a user-defined subroutine if 
   close-gadget click detected.
   
   This may be extended in the future
   to accommodate other window events
   (eg: resizing).   
*/
   make_label(lab,lablabel);

   gen("move.l","#0","-(sp)");
   gen("jsr","_wdw_close_test","  ");
   gen("addq","#4","sp");
   gen("tst.l","d0","  ");
   gen("beq.s",lab,"  ");
 
  if (wdw_event_branch == callsym)
	gen("jsr",wdw_event_label,"  ");
   else
   if (wdw_event_branch == gosubsym) 
      	gen_branch("jsr",wdw_event_label);
   else
    	gen_branch("jmp",wdw_event_label);
   gen(lablabel,"  ","  ");

   enter_XREF("_wdw_close_test");
}

void gad_event_test()
{
char lab[80],lablabel[80];

/* Test for user-defined gadget selection
   in current output window and transfer
   control to a user-defined subroutine
   if a gadget click is detected.
*/
   make_label(lab,lablabel);

   gen("move.l","#0","-(sp)");
   if (gadtoolsused)
      gen("jsr","_gt_gadget_event_test","  ");
   else
      gen("jsr","_gadget_event_test","  ");
   gen("addq","#4","sp");
   gen("tst.l","d0","  ");
   gen("beq.s",lab,"  ");

   if (gad_event_branch == callsym)
	gen("jsr",gad_event_label,"  ");
   else
   if (gad_event_branch == gosubsym)
      	gen_branch("jsr",gad_event_label);
   else
    	gen_branch("jmp",gad_event_label);
   gen(lablabel,"  ","  ");

   if (gadtoolsused)
      enter_XREF("_gt_gadget_event_test");
   else
      enter_XREF("_gadget_event_test");
}
