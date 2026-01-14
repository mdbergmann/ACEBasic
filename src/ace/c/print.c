/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: standard output and screen printing code **
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
	   6th,7th,13th December 1992,
	   6th January 1993,
	   18th February 1993,
	   10th,11th,31st October 1993,
	   14th,15th December 1993,
	   2nd January 1994
*/

#include "acedef.h"

#define QUN_CODE 3

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	int	obj;
extern	BOOL	end_of_source;
extern	BOOL	dosused;
extern	int  	fstrcount;

/* functions */
void gen_printcode(code)
int code;
{
 switch(code)
 {
  /* LF */
  case LF_CODE : 	gen("move.l","#0","-(sp)");
		 	break;
  /* TAB */
  case TAB_CODE :  	gen("move.l","#1","-(sp)");
			break;
  /* SPACE */
  case SPACE_CODE :	gen("move.l","#2","-(sp)");
			break;  
  /* QUN */
  case QUN_CODE :	gen("move.l","#3","-(sp)");
			break;	
 }

 /* call function */
 gen("jsr","_Ucodeprint","  ");
 gen("addq","#4","sp");
 enter_XREF("_Ucodeprint");
}

void print_statement()
{
/* - Print expression(s) to a DOS or Intuition window.
   - Expressions can be separated by spaces, commas or semicolons.
   - Text is clipped at the right edge of an Intuition window, but
     wraps around in a DOS window. The former is in line with AmigaBASIC.
   - Both window-types scroll text when the bottom is reached.
*/  
int exprtype,arguments=0;

enter_XREF("_GfxBase"); 

do
{
 if (sym != ident && !strfunc() && !numfunc() && !factorfunc() &&
     obj != constant) 
    insymbol();  /* ident/func/literal after space or as first parameter */

 /* PRINT# ? */
 if (sym == hash && (lastsym == printsym || lastsym == question)) return;

 /* end of line, multi-statement, ";", "," ELSE or comment 
    after PRINT command word? -> don't proceed to expr! */
 if ((sym == endofline) || (sym == colon) || (sym == apostrophe) || 
     (sym == semicolon) || (sym == comma) || (sym == elsesym) ||
     (end_of_source))
 {
  if (sym == comma) gen_printcode(TAB_CODE);
  else
  if ((arguments == 0) && (sym != semicolon)) 
     gen_printcode(LF_CODE);  /* PRINT with no args */ 

  if (sym != colon && sym != elsesym) 
     insymbol();  /* leave colon for multi-statement 
		     in statement() or leave ELSE for if_statement() */
  return;
 }

  /* get an expression */
  exprtype = expr();
   
  if (exprtype == undefined) { _error(0); return; } /* illegal syms? */

  switch(exprtype)
  {
   case shorttype :  make_long();
		     gen("jsr","_Ushortprint","  ");
		     gen("addq","#4","sp");	
		     enter_XREF("_Ushortprint");
		     break;

   case longtype :   gen("jsr","_Ulongprint","  ");
		     gen("addq","#4","sp");	
		     enter_XREF("_Ulongprint");
		     break;

   case singletype : gen("jsr","_Usingleprint","  ");
		     gen("addq","#4","sp");	
		     enter_XREF("_Usingleprint");
		     break;

   case stringtype : gen("jsr","_Ustringprint","  ");
		     gen("addq","#4","sp");	
		     enter_XREF("_Ustringprint");
		     break;
  }

  if (exprtype != stringtype) gen_printcode(SPACE_CODE); /* trailing space
							    for any number */
  arguments++;

  if (sym == comma) gen_printcode(TAB_CODE);
   
 }
 while ((sym == comma) || (sym == semicolon) || (sym == ident) ||
	strfunc() || numfunc() || factorfunc() || obj == constant);  

 /* no comma or semicolon at end of PRINT -> LF */
 gen_printcode(LF_CODE);

 /* need mathffp.library for _Usingleprint and 
    _beep if called by _Ustringprint. 
 */ 
 enter_XREF("_MathBase");
}  

void gen_printscode(code)
int code;
{
 switch(code)
 {
  /* LF */
  case LF_CODE : 	gen("jsr","_printsLF","  ");
 		 	enter_XREF("_printsLF");
		 	break;
  /* TAB */
  case TAB_CODE :  	gen("jsr","_printsTAB","  ");
 			enter_XREF("_printsTAB");
			break;
  /* SPACE */
  case SPACE_CODE :	gen("jsr","_printsSPC","  ");
 			enter_XREF("_printsSPC");
			break;
 }
}

void prints_statement()
{
/* - print expression(s) to current rastport (intended for screens or
     Intuition windows).
   - expressions can be separated by spaces, commas or semicolons which
     have the same effect as in the PRINT statement.
*/  
int exprtype,arguments=0;

enter_XREF("_GfxBase"); 

do
{
 if (sym != ident && !strfunc() && !numfunc() && !factorfunc() &&
     obj != constant) 
    insymbol();  /* ident/func/literal after space or as first parameter */

 /* end of line, multi-statement, ";", "," ELSE or comment 
    after PRINTS command word? -> don't proceed to expr! */
 if ((sym == endofline) || (sym == colon) || (sym == apostrophe) || 
     (sym == semicolon) || (sym == comma) || (sym == elsesym) ||
     (end_of_source))
 {
  if (sym == comma) gen_printscode(TAB_CODE);
  else
  if ((arguments == 0) && (sym != semicolon)) 
     gen_printscode(LF_CODE);  /* PRINTS with no args */ 

  if (sym != colon && sym != elsesym) 
     insymbol();  /* leave colon for multi-statement 
		     in statement() or leave ELSE for if_statement() */
  return;
 }

  /* get an expression */
  exprtype = expr();
   
  if (exprtype == undefined) { _error(0); return; } /* illegal syms? */

  switch(exprtype)
  {
   case shorttype :  gen("move.w","(sp)+","d0");
		     gen("jsr","_shortprints","  ");
		     enter_XREF("_shortprints");
		     break;

   case longtype :   gen("move.l","(sp)+","d0");  
		     gen("jsr","_longprints","  ");
		     enter_XREF("_longprints");
		     break;

   case singletype : gen("move.l","(sp)+","d0");
		     gen("jsr","_singleprints","  ");
		     enter_XREF("_singleprints");
		     enter_XREF("_MathBase");
		     break;

   case stringtype : gen("movea.l","(sp)+","a0");
		     gen("jsr","_stringprints","  ");
		     enter_XREF("_stringprints");
		     break;
  }

  if (exprtype != stringtype) gen_printscode(SPACE_CODE); /* trailing space
							     for any number */
  arguments++;

  if (sym == comma) gen_printscode(TAB_CODE);
   
 }
 while ((sym == comma) || (sym == semicolon) || (sym == ident) ||
	strfunc() || numfunc() || factorfunc() || obj == constant);  

 /* no comma or semicolon at end of PRINTS -> LF */
 gen_printscode(LF_CODE);
}  
