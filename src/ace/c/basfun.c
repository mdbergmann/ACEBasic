/* << ACE >>
   
   -- Amiga BASIC Compiler --

   ** Intrinsic Functions **
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
     Date: 16th-30th November, 1st-12th December 1991,
	   27th January 1992, 
           6th,11th,14th,17th,28th,29th February 1992,
	   23rd March 1992,
	   21st April 1992,
	   2nd,11th,15th May 1992,
	   8th,14th,28th June 1992,
	   2nd,5th,14th,15th,26th-28th July 1992,
	   2nd,9th August 1992,
	   6th,7th,8th,13th,29th December 1992,
	   5th January 1993,
	   14th,18th February 1993,
	   8th,10th March 1993,
	   25th,30th May 1993,
	   6th,13th,19th,30th June 1993,
	   1st,3rd,4th July 1993,
	   5th,25th September 1993,
	   10th,11th October 1993,
	   2nd,9th November 1993,
	   24th,28th December 1993,
	   6th January 1994,
	   7th,26th,27th February 1994,
	   4th April 1994,
	   28th August 1994,
	   3rd,4th September 1994,
	   5th,11th March 1995,
	   10th March 1996
*/

#include "acedef.h"

/* locals */
static	char	*addreg[] = { "a4","a5" };

/* externals */   
extern	int 	sym;
extern	int 	lev;
extern	int	struct_member_type;
extern	char 	id[MAXIDSIZE];   
extern	char 	ut_id[MAXIDSIZE];
extern	SYM	*curr_item;
extern	char 	tempstrname[80];
extern	char	strstorename[80];
extern	char	strstorelabel[80];
extern	BOOL 	cli_args;
extern	BOOL 	break_opt;
extern	BOOL	have_lparen;

/* string functions */
BOOL strfunc()
{
 switch(sym)
 {
  case argstrsym	: return(TRUE);
  case ascsym	   	: return(TRUE);
  case binstrsym	: return(TRUE);
  case chrstrsym   	: return(TRUE);
  case cstrsym		: return(TRUE);
  case fileboxstrsym	: return(TRUE);
  case hexsym	   	: return(TRUE); 
  case inputboxsym	: return(TRUE);	/* this is here for convienience */
  case inputboxstrsym	: return(TRUE);
  case inputstrsym 	: return(TRUE);
  case instrsym		: return(TRUE);
  case leftstrsym  	: return(TRUE);
  case lensym	   	: return(TRUE);
  case midstrsym   	: return(TRUE);
  case octstrsym   	: return(TRUE);
  case ptabsym		: return(TRUE);
  case rightstrsym 	: return(TRUE);
  case saddsym		: return(TRUE);
  case spacestrsym	: return(TRUE);
  case spcsym		: return(TRUE);
  case strstrsym   	: return(TRUE);
  case stringstrsym	: return(TRUE);
  case tabsym 		: return(TRUE);
  case translatestrsym 	: return(TRUE);
  case ucasestrsym 	: return(TRUE);
  case valsym      	: return(TRUE);
 }
 return(FALSE);
}

int stringfunction()
{
int  func;
int  sftype=undefined;
int  ntype=undefined;
char buf[80],srcbuf[80];
BOOL commaset=FALSE;
BOOL offset_on_stack;

 if (strfunc()) 
 {
  func=sym;
  insymbol();
  if (sym != lparen) _error(14);
  else
  {
   insymbol();
   sftype=expr();
    
   switch(func)
      {
        /* CHR$ */
        case chrstrsym : sftype=make_integer(sftype);
        		 if (sftype == longtype) 
        		 {
    	 		  make_short();
    	 		  sftype=shorttype;
        		 }

      			 if (sftype != notype)
      			 {
      			  /* Ascii value to copy to string */
        		  gen("move.w","(sp)+","d0");
      			  /* create a string to copy value to */
      			  make_string_store();
      			  strcpy(buf,strstorename);
      			  gen("lea",buf,"a0");
      			  gen("jsr","_chrstring","  ");
      			  gen("pea",strstorename,"  ");
      			  enter_XREF("_chrstring");
      			  enter_BSS(strstorelabel,"ds.b 2");
      			  sftype=stringtype;
      			 }
     			 else { _error(4); sftype=undefined; }
        		break;

    /* ARG$ */
    case argstrsym  :	if (sftype != stringtype)
			{
			 /* argument number */
			 if (make_integer(sftype)==shorttype) make_long();	
			 /* destination buffer */
			 make_temp_string();  	
			 gen("pea",tempstrname,"  ");
			 gen("jsr","_arg","  ");
			 gen("addq","#8","sp");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_arg");
			 cli_args=TRUE;
			 sftype=stringtype;
			}
			else { _error(4); sftype=undefined; }
			break;

    /* ASC */
    case ascsym  :	if (sftype == stringtype) 
			{
			 gen("move.l","(sp)+","a2");
			 gen("jsr","_asc","  ");
			 gen("move.w","d0","-(sp)");
			 enter_XREF("_asc");	
			 sftype=shorttype;
			}
			else { _error(4); sftype=undefined; }	 
   			break;

    /* BIN$ */
    case binstrsym  :	if (sftype != stringtype)
			{
			 if (make_integer(sftype) == shorttype)
			     make_long(); /* only handle long val */
			 make_temp_string();
			 gen("lea",tempstrname,"a0");
			 gen("move.l","(sp)+","d0"); /* long argument */
			 gen("jsr","_binstr","  ");
			 enter_XREF("_binstr");
		         gen("move.l","a0","-(sp)"); /* push string result */
			 sftype=stringtype;
			 }
			 else { _error(4); sftype=undefined; }
			 break;

    /* CSTR */
    case cstrsym : if ((sftype == stringtype) || (sftype == longtype))
		      sftype=stringtype;
	      	   else
		      { _error(4); sftype=undefined; }
		   break;

    /* FILEBOX$ */
    case fileboxstrsym : if (sftype == stringtype)  /* title */
			 {
				/* default directory? */
				if (sym == comma)
				{
					insymbol();
					if (expr() != stringtype) _error(4);
				}
				else
					gen("move.l","#0","-(sp)");
	
				gen("jsr","_filerequest","  ");
				gen("addq","#8","sp");
				gen("move.l","d0","-(sp)");
				enter_XREF("_filerequest");
				enter_XREF("_GfxBase");
				sftype=stringtype;
			 }
			 else 
			     { _error(4); sftype=undefined; }
			 break;

    /* HEX$ */
    case hexsym  :	if (sftype != stringtype)
			{
			 sftype = make_integer(sftype);
			 make_temp_string();
			 gen("lea",tempstrname,"a0");
			 if (sftype == longtype)
			 {
			  gen("move.l","(sp)+","d0");
			  gen("jsr","_hexstrlong","  ");
			  enter_XREF("_hexstrlong");
			 }
			 else
			  /* shorttype */
			  {
			   gen("move.w","(sp)+","d0");
			   gen("jsr","_hexstrshort","  ");
			   enter_XREF("_hexstrshort");
			  }
			  gen("move.l","a0","-(sp)");  /* push string result */
			  sftype=stringtype;
			 }
			 else { _error(4); sftype=undefined; }
			 break;
			  
    /* INPUTBOX and INPUTBOX$ */
    case inputboxsym :
    case inputboxstrsym : if (sftype == stringtype) 	/* prompt */ 	
			  {				
			   /* all other parameters are optional */

			   if (sym == comma) 		/* title */
			   {
				insymbol();
				if (sym != comma)
				{
					if (expr() != stringtype) _error(4);
				}
				else
					gen("move.l","#0","-(sp)");
			   }
			   else 
				gen("move.l","#0","-(sp)"); 

			   if (sym == comma)		/* default value */
			   {
				insymbol();
				if (sym != comma)
				{
					if (expr() != stringtype) _error(4);
				}
				else
					gen("move.l","#0","-(sp)");
			   }
			   else 
				gen("move.l","#0","-(sp)");

			   if (sym == comma)		/* xpos */
			   {
				insymbol();
				if (sym != comma)
				{
			   		if (make_integer(expr()) == shorttype)
						make_long();
				}
				else
					gen("move.l","#0","-(sp)");
			   }
			   else 
				gen("move.l","#0","-(sp)");

			   if (sym == comma)		/* ypos */
			   {
				insymbol();
				if (sym != comma)
				{
			   		if (make_integer(expr()) == shorttype)
						make_long();
				}
				else
					gen("move.l","#0","-(sp)");
			   }
			   else 
				gen("move.l","#0","-(sp)");

			   /* which function? */
			   if (func == inputboxsym)
			   {
				/* INPUTBOX */
				gen("jsr","_longint_input_box","  ");
				gen("add.l","#20","sp");
				gen("move.l","d0","-(sp)");
				enter_XREF("_longint_input_box");
				sftype = longtype;
			   }
			   else
			   {
				/* INPUTBOX$ */
				gen("jsr","_string_input_box","  ");
				gen("add.l","#20","sp");
				gen("move.l","d0","-(sp)");
				enter_XREF("_string_input_box");
				sftype = stringtype;
			   }

			   /* both functions need graphics and intuition libraries! */
			   enter_XREF("_GfxBase");	
			  }
			  else { _error(4); sftype=undefined; }
			  break;
			 
    /* INPUT$(X,[#]filenumber) */
    case inputstrsym : if (sftype != stringtype)
		       { 
			check_for_event();

			if (make_integer(sftype) == shorttype)
			   make_long(); 	/* no. of characters */

			if (sym == comma)
			{
			 insymbol();
			 if (sym == hash) insymbol();
			 if (make_integer(expr()) == shorttype)
			    make_long();  	/* filenumber */
			}
			else { _error(16); sftype=undefined; }

		       	gen("move.l","(sp)+","d0");  /* pop filenumber */
		        gen("move.l","(sp)+","d1");  /* pop no. of characters */
		       	gen("jsr","_inputstrfromfile","  ");
		       	gen("move.l","d0","-(sp)");  /* push string result */

		       	enter_XREF("_inputstrfromfile");
		       	enter_XREF("_DOSBase");
		       	sftype=stringtype;
		       }
		       else { _error(4); sftype=undefined; }
		       break;     
		
    /* INSTR$([I,]X$,Y$) */
    case instrsym  :	if (sftype != stringtype)
			{
			 if (make_integer(sftype) == shorttype) make_long();
 
			 if (sym == comma) 
			 { 
			  offset_on_stack=TRUE;		/* optional offset I */
			  insymbol(); sftype=expr(); 
			 }
			 else
			     { _error(16); sftype=undefined; }	   
			}	
		    	else 
			    offset_on_stack=FALSE;

			/* get X$ and Y$ */
		     	if (sftype == stringtype)
			{
			 if (sym == comma) 
			 {
			  insymbol();			 
			  if (expr() == stringtype)
			  {
			   gen("movea.l","(sp)+","a1");		/* Y$ */
			   gen("movea.l","(sp)+","a0");		/* X$ */
			   if (offset_on_stack) 
			      gen("move.l","(sp)+","d0");	/* I */
			   else
			      gen("moveq","#1","d0");		/* I=1 */
			   
			   /* call INSTR */
			   gen("jsr","_instr","  ");
			   gen("move.l","d0","-(sp)");	/* posn of Y$ in X$ */
			   enter_XREF("_instr");
			   sftype=longtype;
			  }
			  else { _error(4); sftype=undefined; }
			 }
			 else { _error(16); sftype=undefined; }
			}
			else { _error(4); sftype=undefined; }
			break;
			
    /* LEFT$ */
    case leftstrsym :	if (sftype == stringtype)
			{
			 if (sym == comma)
			 {
			  insymbol();
			  make_sure_short(expr());
			  gen("move.w","(sp)+","d0");  /* index */
			  gen("move.l","(sp)+","a0");  /* string */
			  make_temp_string();
			  gen("lea",tempstrname,"a1");
			  gen("jsr","_leftstr","  ");
			  gen("move.l","a0","-(sp)");  /* addr of left$ */
			  enter_XREF("_leftstr");
			  sftype=stringtype;
			 }
			 else { _error(16); sftype=undefined; }
			}
			else { _error(4); sftype=undefined; }
			break;

    /* LEN */
    case lensym  :	if (sftype == stringtype) 
			{
			 gen("move.l","(sp)+","a2");
			 gen("jsr","_strlen","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_strlen");	
			 sftype=longtype;
			}
			else { _error(4); sftype=undefined; }	 
   			break;

    /* OCT$ */
    case octstrsym  :	if (sftype != stringtype)
			{
			 if (make_integer(sftype) == shorttype)
			     make_long(); /* only handle long val */
			 make_temp_string();
			 gen("lea",tempstrname,"a0");
			 gen("move.l","(sp)+","d0"); /* long argument */
			 gen("jsr","_octstr","  ");
			 enter_XREF("_octstr");
		         gen("move.l","a0","-(sp)"); /* push string result */
			 sftype=stringtype;
			 }
			 else { _error(4); sftype=undefined; }
			 break;
 
    /* RIGHT$ */
    case rightstrsym :	if (sftype == stringtype)
			{
			 if (sym == comma)
			 {
			  insymbol();
			  make_sure_short(expr());
			  gen("move.w","(sp)+","d0");  /* index */
			  gen("move.l","(sp)+","a0");  /* string */
			  make_temp_string();
			  gen("lea",tempstrname,"a1");
		   	  gen("jsr","_rightstr","  ");
			  gen("move.l","a0","-(sp)");  /* addr of right$ */
			  enter_XREF("_rightstr");
			  sftype=stringtype;
			 }
			 else { _error(16); sftype=undefined; }
			}
			else { _error(4); sftype=undefined; }
			break;

    /* SADD */
    case saddsym : 	if (sftype == stringtype)
		      	   sftype=longtype; /* address is on stack */
		   	else { _error(4); sftype=undefined; }
		   	break;

    /* SPC, SPACE$ */
    case spcsym:
    case spacestrsym :  if (sftype != stringtype)
			{
			 make_sure_short(sftype);
			 gen("move.w","(sp)+","d0");
			 make_temp_string();
			 gen("lea",tempstrname,"a0");
			 if (func == spacestrsym)
			   	gen("jsr","_spacestring","  ");
			 else
				gen("jsr","_spc","  ");
			 gen("move.l","d0","-(sp)");
			 if (func == spacestrsym)
				enter_XREF("_spacestring");
			 else
				enter_XREF("_spc");
			 sftype=stringtype;
			}
			else { _error(4); sftype=undefined; }
			break;

    /* STR$ */
    case strstrsym :	if (sftype != stringtype)
			{
			 make_temp_string();
			 gen("lea",tempstrname,"a0");
			 if (sftype == longtype)
			 {
			  gen("move.l","(sp)+","d0");
			  gen("jsr","_strlong","  ");
			  enter_XREF("_strlong");
			  gen("move.l","a0","-(sp)");  /* push string result */
			 }
			 else
			  if (sftype == shorttype)
			  {
			   gen("move.w","(sp)+","d0");
			   gen("jsr","_strshort","  ");
			   enter_XREF("_strshort");
 			   gen("move.l","a0","-(sp)");  /* push string result */
			  }
			  else
			   if (sftype == singletype)
			   {
			    gen("jsr","_strsingle","  ");
			    gen("addq","#4","sp");
			    gen("move.l","d0","-(sp)"); /* push string result */
			    enter_XREF("_strsingle");
			    enter_XREF("_MathBase");
			   }
			  sftype=stringtype;
			 }
			 else { _error(4); sftype=undefined; }
			 break;

    /*   STRING$(I,J) 
      or STRING$(I,X$) */
    case stringstrsym : if (sftype != stringtype)
			{
			 make_sure_short(sftype);

			 if (sym == comma)
			 {		
			  insymbol();
			  ntype=expr();

			  if (ntype == stringtype)
			  {
			   gen("move.l","(sp)+","a0");
			   gen("move.b","(a0)","d1");
			   gen("ext.w","d1","  ");
			   gen("ext.l","d1","  ");	/* MID$(X$,1,1) */
			  }
			  else
			  {
			   if (make_integer(ntype) == shorttype) 
			      make_long();
			   gen("move.l","(sp)+","d1");	/* J */			
			  }

			  gen("move.w","(sp)+","d0");  /* I */

			  /* call STRING$ */
			  make_temp_string();
			  gen("lea",tempstrname,"a0");
			  gen("jsr","_stringstr","  ");
			  gen("move.l","d0","-(sp)");	/* push string result */
			  enter_XREF("_stringstr");
			  sftype=stringtype;
			 }
			 else { _error(16); sftype=undefined; }
		    	}
			else { _error(4); sftype=undefined; }	
			break;    

    /* MID$ -> MID$(X$,n[,m]) */
    case midstrsym :	if (sftype == stringtype)
			{
			 if (sym == comma)
			 {
			  insymbol();	       /* start position */
			  make_sure_short(expr());

			   if (sym == comma)
			   {
			    insymbol();        /* character count */
			    make_sure_short(expr());
			    commaset=TRUE;
			   }

		    	   if (commaset) 
			      gen("move.w","(sp)+","d1");  /* char count */
		  	   else
			   /* take the full length of the string */
			   gen("move.w","#-1","d1");  
	   	
			   gen("move.w","(sp)+","d0");  /* start posn */
			   gen("move.l","(sp)+","a0");  /* string */
			   make_temp_string();
			   gen("lea",tempstrname,"a1");
		           gen("jsr","_midstr","  ");
			   gen("move.l","a0","-(sp)");  /* addr of mid$ */
			   enter_XREF("_midstr");
			   sftype=stringtype;
			 }
			 else { _error(16); sftype=undefined; }
			}
			else { _error(4); sftype=undefined; }
			break;

    /* PTAB */
    case ptabsym :	if (sftype != stringtype)
			{
			 make_sure_short(sftype);
			 gen("move.w","(sp)+","d0");  /* x coordinate */
			 gen("jsr","_ptab","  ");
			 gen("move.l","a0","-(sp)");  /* NULL ptab string */
			 enter_XREF("_ptab");
			 enter_XREF("_GfxBase");
			 sftype=stringtype;
			}
			else sftype=undefined; 
			break;
	
    /* TAB */
    case tabsym :	if (sftype != stringtype)
			{
			 make_sure_short(sftype);
			 gen("move.w","(sp)+","d0");  /* # of columns */
			 gen("jsr","_horiz_tab","  ");
			 gen("move.l","a0","-(sp)");  /* addr of tab string */
			 enter_XREF("_horiz_tab");
			 enter_XREF("_DOSBase");
			 enter_XREF("_GfxBase");
			 sftype=stringtype;
			}
			else sftype=undefined; 
			break;
	
    /* TRANSLATE$ */
    case translatestrsym :if (sftype == stringtype)
			  {
			   gen("movea.l","(sp)+","a0"); /* instr */
			   make_temp_string();
			   gen("lea",tempstrname,"a1"); /* outstr */
			   gen("movea.l","a0","a2");
			   gen("jsr","_strlen","  "); /* inlen in d0 */
			   sprintf(srcbuf,"#%ld",MAXSTRLEN); /* #MAXSTRLEN */
			   gen("move.l",srcbuf,"d1"); /* outlen = MAXSTRLEN */
			   gen("movea.l","_TransBase","a6");
			   gen("jsr","_LVOTranslate(a6)","  ");
			   gen("pea",tempstrname,"  "); /* outstr on stack */
			   enter_XREF("_TransBase");
			   enter_XREF("_LVOTranslate");
			   enter_XREF("_strlen");
			   sftype=stringtype;
			  }
			  else { _error(4); sftype=undefined; }
			  break;
	
    /* UCASE$ */
    case ucasestrsym  :	if (sftype == stringtype) 
			{
			 gen("move.l","(sp)+","a1");
		   	 make_temp_string();
			 gen("lea",tempstrname,"a0"); /* result buffer */
			 gen("jsr","_ucase","  ");
			 gen("move.l","a0","-(sp)");
			 enter_XREF("_ucase");	
			 sftype=stringtype;
			}
			else { _error(4); sftype=undefined; }	 
   			break;

    /* VAL */
    case valsym :	if (sftype == stringtype)
			{
			 gen("jsr","_val","  "); /* string is on the stack */
			 gen("addq","#4","sp");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_val");
			 enter_XREF("_MathBase");  /* _val needs math libs */
			 enter_XREF("_MathTransBase");
			 sftype=singletype;
			}
			else { _error(4); sftype=undefined; } 
			break;
   }

   if (sym != rparen) { _error(9); sftype=undefined; }
  }  
  insymbol();
 }
 return(sftype);
}

/* numeric functions */
int gen_single_func(funcname,nftype)
char *funcname;
int  nftype;
{
char func[80];

  if (nftype != stringtype)
  {
   if (nftype != singletype) gen_Flt(nftype);  
   gen("move.l","(sp)+","d0");
   gen("movea.l","_MathTransBase","a6");
   strcpy(func,funcname);
   strcat(func,"(a6)");
   gen("jsr",func,"  ");
   gen("move.l","d0","-(sp)");
   enter_XREF(funcname);
   enter_XREF("_MathTransBase");
   enter_XREF("_MathBase");
   nftype=singletype;
  }
  else { _error(4); nftype=undefined; }
 return(nftype);
}

BOOL numfunc()
{
 switch(sym)
 {
  case abssym    	: return(TRUE);
  case allocsym	 	: return(TRUE);
  case atnsym    	: return(TRUE);
  case cintsym   	: return(TRUE);
  case clngsym   	: return(TRUE);
  case cossym    	: return(TRUE);
  case csngsym   	: return(TRUE);
  case eofsym	 	: return(TRUE);
  case expsym    	: return(TRUE); 
  case fixsym    	: return(TRUE);
  case fresym	 	: return(TRUE);
  case gadgetsym 	: return(TRUE);
  case handlesym 	: return(TRUE);
  case iffsym		: return(TRUE);
  case intsym    	: return(TRUE);
  case locsym	 	: return(TRUE);
  case lofsym	 	: return(TRUE);
  case logsym    	: return(TRUE);
  case longintsym    	: return(TRUE);
  case menusym	 	: return(TRUE);
  case mousesym  	: return(TRUE);
  case msgboxsym 	: return(TRUE);
  case peeksym   	: return(TRUE);
  case peekwsym 	: return(TRUE);
  case peeklsym  	: return(TRUE);
  case pointsym  	: return(TRUE);
  case potxsym	 	: return(TRUE);
  case potysym	 	: return(TRUE);
  case saysym	 	: return(TRUE);
  case screensym 	: return(TRUE);
  case serialsym 	: return(TRUE);
  case sgnsym    	: return(TRUE);
  case shlsym	 	: return(TRUE);
  case shrsym	 	: return(TRUE);
  case sinsym    	: return(TRUE);
  case sizeofsym 	: return(TRUE);
  case sqrsym    	: return(TRUE);
  case sticksym  	: return(TRUE);
  case strigsym  	: return(TRUE);
  case tansym    	: return(TRUE);
  case varptrsym 	: return(TRUE);
  case windowsym 	: return(TRUE);
 }
 return(FALSE);
}

int numericfunction()
{
int  func;
int  nftype=undefined;
int  targettype;
char labname[80],lablabel[80];
char buf[40],numbuf[40];
char varptr_obj_name[MAXIDSIZE];

 if (numfunc()) 
 {
  func=sym;
  insymbol();
  if (sym != lparen) _error(14);
  else
  {
   insymbol();
   if ((func != varptrsym) && (func != sizeofsym)) nftype=expr();
    
   switch(func)
      {
       /* ABS */
       case abssym : if (nftype == shorttype)
       		     {
           		gen("move.w","(sp)+","d0");
   	   		gen("jsr","_absw","  ");
   	   		gen("move.w","d0","-(sp)");
   	   		enter_XREF("_absw");
         	     }
         	     else
         	     if (nftype == longtype)
         	     {
           		gen("move.l","(sp)+","d0");
   	   		gen("jsr","_absl","  ");
   	   		gen("move.l","d0","-(sp)");
   	   		enter_XREF("_absl");
         	     }
         	     else
         	     if (nftype == singletype)
         	     {
           		gen("move.l","(sp)+","d0");
   	   		gen("jsr","_absf","  ");
   	   		gen("move.l","d0","-(sp)");
   	   		enter_XREF("_absf");
			enter_XREF("_MathBase");
         	     }
         	     else { _error(4); nftype=undefined; }
         	     break;

	 /* ALLOC */ 
	 case allocsym :if (nftype != stringtype)
			{
			 /* minimum number of bytes to reserve */
			 if (make_integer(nftype) == shorttype) make_long();
		
			 if (sym != comma)
			 {
			    gen("move.l","#9","-(sp)");	/* 9 = default type */
			    nftype=longtype;
			 }
			 else 
			 {
			  /* memory type specification */
			  insymbol();
			  nftype=expr();
			  if (nftype != stringtype)
			  {
			    	if (make_integer(nftype) == shorttype) 
			       	   make_long(); 
			    	nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			 }

			 /* call ACEalloc() function */
			 gen("jsr","_ACEalloc","  ");
			 gen("addq","#8","sp");
			 gen("move.l","d0","-(sp)");  /* push result */
			 enter_XREF("_ACEalloc"); 
			 enter_XREF("_IntuitionBase");
			}
			else { _error(4); nftype=undefined; }
			break;
  	 
	 /* ATN */
         case atnsym  : nftype = gen_single_func("_LVOSPAtan",nftype);
		        break;

	 /* CINT */
	 case cintsym : nftype = make_integer(nftype);
			if (nftype == longtype)
                        { 
                           make_short();
			   nftype=shorttype;
 			}
			if (nftype == notype) 
			   { _error(4); nftype=undefined; }
			break;

	 /* CLNG */
	 case clngsym : if (nftype == singletype)
			{
			 gen_round(nftype);
			 nftype=longtype;
			}
			else
			  if (nftype == shorttype)
			  {
 			   gen("move.w","(sp)+","d0");
			   gen("ext.l","d0","  ");
			   gen("move.l","d0","-(sp)");
			   nftype=longtype;
			  }
			  else
			      if (nftype == stringtype)
				  { _error(4); nftype=undefined; }
			break;

	 /* COS */
         case cossym  : nftype = gen_single_func("_LVOSPCos",nftype);
		        break;

	 /* CSNG */
	 case csngsym : if ((nftype == shorttype) || (nftype == longtype))
			{
			   gen_Flt(nftype);
			   nftype=singletype;
			}
 			else 
			    if (nftype == stringtype) 
			       { _error(4); nftype=undefined; }
			break; 
			    
    	/* EOF */
    	case eofsym   : if (nftype != stringtype)
		  	{ 
			 check_for_event();

		   	 if (make_integer(nftype) == shorttype)
		      	    make_long();	
		   	 gen("move.l","(sp)+","d0"); /* pop filenumber */
		   	 gen("jsr","_eoftest","  ");
		   	 gen("move.l","d0","-(sp)");
		   	 enter_XREF("_eoftest");
		   	 enter_XREF("_DOSBase");
		     	 nftype=longtype;
		  	}
		  	else { _error(4); nftype=undefined; }
		  	break;

	 /* EXP */
         case expsym  : nftype = gen_single_func("_LVOSPExp",nftype);
		        break;

	 /* FIX */
	 case fixsym  : if (nftype == singletype)
			{
			 gen("move.l","(sp)+","d0");
			 gen("movea.l","_MathBase","a6");
			 gen("jsr","_LVOSPFix(a6)","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_MathBase");
			 enter_XREF("_LVOSPFix");
			 nftype=longtype;
			}
			else
			  if (nftype == stringtype)
			     { _error(4); nftype=undefined; }

			/* else if short or long, leave on stack 
			   and let nftype remain the same! */
			break;

    	 /* FRE */
      	 case fresym : if (nftype != stringtype)
		       {
		        make_sure_short(nftype);
		        gen("move.w","(sp)+","d0"); /* pop argument */
		        gen("jsr","_fre","  ");
		        gen("move.l","d0","-(sp)");
		        enter_XREF("_fre");
		        nftype=longtype;
		       }
		       else { _error(4); nftype=undefined; }
		       break;

	 /* GADGET */
	 case gadgetsym : nftype = make_integer(nftype);
			  if (nftype == shorttype) make_long();
			  gen("jsr","_GadFunc","  ");
			  gen("addq","#4","sp");
			  gen("move.l","d0","-(sp)");
			  enter_XREF("_GadFunc");
			  nftype=longtype;
			  break;

	 /* HANDLE */
	 case handlesym : if (nftype != stringtype)
			  {
			   check_for_event();

			   if (make_integer(nftype) == shorttype)
			      make_long();
			   gen("move.l","(sp)+","d0");
			   gen("jsr","_handle","  ");
			   gen("move.l","d0","-(sp)");
			   enter_XREF("_handle");
			   nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			  break;

	 /* IFF */
	 case iffsym : if (nftype != stringtype)
			  {
			   check_for_event();

			   /* channel */
			   if (make_integer(nftype) == shorttype)
			      make_long();

			   /* function number */
			   if (sym == comma) 
			   {
			    insymbol();
			    if (make_integer(expr()) == shorttype)
			       make_long();

			    gen("jsr","_iff_func","  ");
			    gen("addq","#8","sp");
			    gen("move.l","d0","-(sp)");	/* push return value */
			    enter_XREF("_iff_func");
			
			    nftype = longtype;
			   }
			   else { _error(16); nftype=undefined; }
			  }
			  else { _error(4); nftype=undefined; }
			  break;

	 /* INT */
	 case intsym  : if (nftype == singletype)
			{
			 gen("move.l","(sp)+","d0");
			 gen("move.l","_MathBase","a6");
			 gen("jsr","_LVOSPFloor(a6)","  ");
			 gen("jsr","_LVOSPFix(a6)","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_MathBase");
			 enter_XREF("_LVOSPFloor");
			 enter_XREF("_LVOSPFix");
			 nftype=longtype;
			}
			else
			  if (nftype == stringtype)
			     { _error(4); nftype=undefined; }

			/* else if short or long, leave on stack 
			   and let nftype remain the same! */
			break;

	 /* LOC */
	 case locsym  : if (nftype != stringtype)
			{
			 check_for_event();

			 if (make_integer(nftype) == shorttype)
			    make_long();
			 gen("jsr","_FilePosition","  ");
			 gen("addq","#4","sp");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_FilePosition");
			 nftype=longtype;
			}
			else { _error(4); nftype=undefined; } 
 			break;
			   
	 /* LOF */
	 case lofsym  : if (nftype != stringtype)
			{
			 check_for_event();

			 if (make_integer(nftype) == shorttype)
			    make_long();
			 gen("move.l","(sp)+","d0");
			 gen("jsr","_lof","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_lof");
			 nftype=longtype;
			}
			else { _error(4); nftype=undefined; } 
 			break;
			   
	 /* LOG */
         case logsym  : nftype = gen_single_func("_LVOSPLog",nftype);
		        break;

	 /* LONGINT */
	 case longintsym: if (nftype == stringtype)
			  {	
				gen("jsr","_long_from_string","  ");
				gen("addq","#4","sp");
				gen("move.l","d0","-(sp)");
				enter_XREF("_long_from_string");
				nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			  break;
		
	 /* MENU */		
	 case menusym : if (nftype != stringtype)
			{
				nftype = make_integer(nftype);
				if (nftype == shorttype) make_long();
				gen("jsr","_MenuFunc","  ");
				gen("addq","#4","sp");
				gen("move.l","d0","-(sp)");
				enter_XREF("_MenuFunc");
				nftype=longtype;
			}
			else { _error(4); nftype=undefined; }
			break;
			
	 /* MOUSE */
	 case mousesym : if (nftype != stringtype)
			 {
			  make_sure_short(nftype);
			  gen("move.w","(sp)+","d0");
			  gen("jsr","_mouse","  ");
			  gen("move.w","d0","-(sp)");
			  enter_XREF("_mouse");
			  enter_XREF("_IntuitionBase");
			  nftype=shorttype;
			 }
			 else nftype=undefined;
			 break;

	 /* MSGBOX */
	 case msgboxsym : if (nftype == stringtype)     /* message */
			  {
			   if (sym != comma)
			      { _error(16); nftype=undefined; }
			   else
			   {
			    insymbol();
			    if (expr() == stringtype)   /* response #1 */
			    {
			     if (sym == comma)
			     {
			      insymbol(); 
			      if (expr() != stringtype) /* response #2 */
			         { _error(4); nftype=undefined; return; }
			     }
			     else
			     	 gen("move.l","#0","-(sp)"); /* #2 = NULL*/
			     
			     /* call the function */
			     gen("jsr","_sysrequest","  ");
			     gen("add.l","#12","sp");
			     gen("move.w","d0","-(sp)");
			     enter_XREF("_sysrequest");
			     enter_XREF("_IntuitionBase");
			     nftype=shorttype;
			    }
			    else { _error(4); nftype=undefined; }
			   }
			  }
			  else { _error(4); nftype=undefined; }
			  break;

	 /* PEEK */
	 case peeksym : nftype=make_integer(nftype);
			if ((nftype == longtype) || (nftype == shorttype))
			{
			 /* get address */
      			 if (nftype == shorttype)
			 {
			    gen("move.w","(sp)+","d0");
			    gen("ext.l","d0","  ");
			    gen("move.l","d0","a0");    
			 }
			 else
			    gen("move.l","(sp)+","a0"); 
			 /* get value */
			 gen("move.b","(a0)","d0");
			 gen("ext.w","d0","  ");
			 /* if n<0 n=255-not(n) */
			 gen("cmp.w","#0","d0");
			 make_label(labname,lablabel);
			 gen("bge.s",labname,"  ");
			 gen("not.w","d0","  ");
			 gen("move.w","#255","d1");
			 gen("sub.w","d0","d1");
			 gen("move.w","d1","d0");
			 gen(lablabel,"  ","  ");
			 gen("move.w","d0","-(sp)");
			 nftype=shorttype;
			}
			else { _error(4); nftype=undefined; }
			break;

	 /* PEEKW */
	 case peekwsym : nftype=make_integer(nftype); 
			 if ((nftype == longtype) || (nftype == shorttype))
			 {
			  /* get address */
      			  if (nftype == shorttype)
			  {
			     gen("move.w","(sp)+","d0");
			     gen("ext.l","d0","  ");
			     gen("move.l","d0","a0");    
			  }
			  else
			     gen("move.l","(sp)+","a0"); 
			  /* get value */
			  gen("move.w","(a0)","-(sp)");
			  nftype=shorttype;
			 }
            		 break;

	 /* PEEKL */
	 case peeklsym : nftype=make_integer(nftype); 
			 if ((nftype == longtype) || (nftype == shorttype))
			 {
			  /* get address */
      			  if (nftype == shorttype)
			  {
			     gen("move.w","(sp)+","d0");
			     gen("ext.l","d0","  ");
			     gen("move.l","d0","a0");    
			  }
			  else
			     gen("move.l","(sp)+","a0"); 
			  /* get value */
			  gen("move.l","(a0)","-(sp)");
			  nftype=longtype;
			 }			
			 break;

	/* POINT */
	case pointsym :	if (nftype != stringtype)
			{
			 make_sure_short(nftype);
			 if (sym != comma)
			    { _error(16); nftype=undefined; }
			 else
			 {
			  insymbol();
			  make_sure_short(expr());
			  gen("move.w","(sp)+","d1");  /* y */
			  gen("move.w","(sp)+","d0");  /* x */
			  gen("move.l","_RPort","a1"); /* rastport */
			  gen("move.l","_GfxBase","a6");
			  gen("jsr","_LVOReadPixel(a6)","  ");
			  gen("move.l","d0","-(sp)");
			  enter_XREF("_LVOReadPixel");
			  enter_XREF("_GfxBase");
			  enter_XREF("_RPort");
			  nftype=longtype;
			 }
			}
			else { _error(4); nftype=undefined; }
			break;
			
	 /* POTX */
	 case potxsym : if (nftype != stringtype)
			{
			 make_sure_short(nftype);
			 gen("move.w","(sp)+","d0"); /* pop argument */
			 gen("jsr","_potx","  ");
			 gen("move.w","d0","-(sp)");
			 enter_XREF("_potx");
			 enter_XREF("_DOSBase");
			 nftype=shorttype;
			}
			else { _error(4); nftype=undefined; }
			break;

	 /* POTY */
	 case potysym : if (nftype != stringtype)
			{
			 make_sure_short(nftype);
			 gen("move.w","(sp)+","d0"); /* pop argument */
			 gen("jsr","_poty","  ");
			 gen("move.w","d0","-(sp)");
			 enter_XREF("_poty");
			 enter_XREF("_DOSBase");
			 nftype=shorttype;
			}
			else { _error(4); nftype=undefined; }
			break;

	 /* SERIAL */
	 case serialsym : if (nftype != stringtype)
			  {
			   check_for_event();

			   /* channel */
			   if (make_integer(nftype) == shorttype)
			      make_long();

			   /* function number */
			   if (sym == comma) 
			   {
			    insymbol();
			    if (make_integer(expr()) == shorttype)
			       make_long();

			    gen("jsr","_serial_func","  ");
			    gen("addq","#8","sp");
			    gen("move.l","d0","-(sp)");	/* push return value */
			    enter_XREF("_serial_func");
			
			    nftype = longtype;
			   }
			   else { _error(16); nftype=undefined; }
			  }
			  else { _error(4); nftype=undefined; }
			  break;

	 /* SGN */
	 case sgnsym  : if (nftype == shorttype)
			{
			 gen("move.w","(sp)+","d0");
			 gen("jsr","_sgnw","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_sgnw");
			 nftype=longtype;
			}
			else
			if (nftype == longtype)
			{
			 gen("move.l","(sp)+","d0");
			 gen("jsr","_sgnl","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_sgnl");
			 nftype=longtype;
			}
			else
			if (nftype == singletype)
			{
			 gen("move.l","(sp)+","d1");
			 gen("jsr","_sgnf","  ");
			 gen("move.l","d0","-(sp)");
			 enter_XREF("_sgnf");
			 enter_XREF("_MathBase");
			 nftype=longtype;
			}
			else
			    { _error(4); nftype=undefined; }
			break; 
			 
 
	 /* SHL */
	 case shlsym  : if (nftype != stringtype)
			{
			 /* value to be shifted */
			 if (make_integer(nftype) == shorttype)
			    make_long();
			 
			 if (sym == comma)
			 {
			  insymbol();
			  /* shifted by how many bits? */
			  if ((nftype=expr()) != stringtype)
			  {
			   if (make_integer(nftype) == shorttype)
			      make_long();
			   
			   gen("move.l","(sp)+","d0"); /* pop shift factor */
			   gen("move.l","(sp)+","d1"); /* pop value */
			   gen("asl.l","d0","d1");     /* shift d1 by d0 */
			   gen("move.l","d1","-(sp)"); /* push result */
			   nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			 }
			 else { _error(16); nftype=undefined; }
			}
			else { _error(4); nftype=undefined; }
			break;
			 
	 /* SHR */
	 case shrsym  : if (nftype != stringtype)
			{
			 /* value to be shifted */
			 if (make_integer(nftype) == shorttype)
			    make_long();
			 
			 if (sym == comma)
			 {
			  insymbol();
			  /* shifted by how many bits? */
			  if ((nftype=expr()) != stringtype)
			  {
			   if (make_integer(nftype) == shorttype)
			      make_long();
			   
			   gen("move.l","(sp)+","d0"); /* pop shift factor */
			   gen("move.l","(sp)+","d1"); /* pop value */
			   gen("asr.l","d0","d1");     /* shift d1 by d0 */
			   gen("move.l","d1","-(sp)"); /* push result */
			   nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			 }
			 else { _error(16); nftype=undefined; }
			}
			else { _error(4); nftype=undefined; }
			break;
			
	 /* SQR */
         case sqrsym  : nftype = gen_single_func("_LVOSPSqrt",nftype);
		        break;

	 /* SIN */
         case sinsym  : nftype = gen_single_func("_LVOSPSin",nftype);
		        break;

	 /* SIZEOF */
	 case sizeofsym : nftype = find_object_size();
			  break;

	 /* STICK */
	 case sticksym : make_sure_short(nftype);
			 gen("move.w","(sp)+","d0");
			 gen("jsr","_stick","  ");
			 gen("move.w","d0","-(sp)");
			 enter_XREF("_stick");
			 nftype=shorttype;
			 break;
	 /* STRIG */
	 case strigsym : make_sure_short(nftype);
			 gen("move.w","(sp)+","d0");
			 gen("jsr","_strig","  ");
			 gen("move.w","d0","-(sp)");
			 enter_XREF("_strig");
			 nftype=shorttype;
			 break;

	 /* TAN */
         case tansym  : nftype = gen_single_func("_LVOSPTan",nftype);
		        break;

	 /* VARPTR */
	 case varptrsym : if (sym == ident) 
			  {
			   strcpy(varptr_obj_name,id);
			   nftype=address_of_object();
			   /* structure and array code returns next symbol */
			   if (!exist(varptr_obj_name,structure) &&
			       !exist(varptr_obj_name,array)) 
			      insymbol();
			  }
			  else 
			     { _error(7); nftype=undefined; insymbol(); }
			  break;

	 /* WINDOW */
	 case windowsym : make_sure_short(nftype);
		  	  gen("move.w","(sp)+","d0");
			  gen("jsr","_windowfunc","  ");
			  gen("move.l","d0","-(sp)");
			  enter_XREF("_windowfunc");
			  enter_XREF("_IntuitionBase");
			  nftype=longtype;
			  break;

	 /* SAY */
	 case saysym	: if (nftype != stringtype)
			  {
			   nftype=make_integer(nftype);
			   if (nftype == shorttype) make_long();
			   gen("jsr","_sayfunc","  ");
			   gen("addq","#4","sp");
			   gen("move.l","d0","-(sp)");
			   enter_XREF("_sayfunc");
			   nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			  break;

	 /* SCREEN */
	 case screensym : if (nftype != stringtype)
			  {
			   nftype = make_integer(nftype);
			   if (nftype == shorttype) make_long();
			   gen("jsr","_screenfunc","  ");
			   gen("addq","#4","sp");
			   gen("move.l","d0","-(sp)");
			   enter_XREF("_screenfunc");
			   enter_XREF("_IntuitionBase");
			   nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			  break;
       }
   if (sym != rparen) { _error(9); nftype=undefined; }
  }  
  insymbol();
 }
 return(nftype);
}

int address_of_object()
{
/* return the address of a variable, array or structure */
SYM    *varptr_item;
char   buf[50],numbuf[40];
char   addrbuf[40];
char   extobjid[MAXIDSIZE];
char   subname[MAXIDSIZE+5];
SYM    *structype;
STRUCM *member;
BOOL   found;

			/* 
			** Make external variable/function
   			** name by removing qualifier and 
   			** adding an underscore prefix 
   			** if one is not present. 
			*/
 			strcpy(buf,ut_id);
 			remove_qualifier(buf);
 			if (buf[0] != '_')
 			{
  			 strcpy(extobjid,"_\0");
  			 strcat(extobjid,buf);
 			}
	   		else 
                   	    strcpy(extobjid,buf);

			/*
			** Make SUB name.
			*/
			sprintf(subname,"_SUB_%s",id);

			/*
			** Push address of valid object
			** [see ref.doc].
			*/
			   /* external variable or function? */
			   if (exist(extobjid,extvar) || 
			       exist(extobjid,extfunc))
			   {
			   	gen("pea",extobjid,"  ");
			   	return(longtype);			      
			   }
			   else
			   if (exist(subname,subprogram))
			   {
				gen("pea",subname,"  ");
				return(longtype);
			   }
			   else
			   /* ordinary variable? */
			   if (exist(id,variable))
			   {
			    varptr_item=curr_item;

			    /* get the frame start address */
			    strcpy(addrbuf,addreg[lev]);

			    /* get the frame offset */
			    sprintf(numbuf,"#%ld",varptr_item->address);

			    /* calculate the absolute address */
			    gen("move.l",addrbuf,"d0");
			    gen("sub.l",numbuf,"d0");
			    if ((varptr_item->type == stringtype)
			       || ((varptr_item->shared) && (lev == ONE)))
			    {
			     /* location in frame contains address */  
			     gen("move.l","d0","a0");
			     gen("move.l","(a0)","-(sp)");
			    }
			    else
				/* absolute address in frame of variable */
			        gen("move.l","d0","-(sp)");
			    return(longtype);    
			   }
			   else
			   if ((exist(id,array)) || (exist(id,structure)))
			   {
			    varptr_item=curr_item;

			    /* get the frame start address */
			    strcpy(addrbuf,addreg[lev]);

			    /* get the frame offset */
			    sprintf(numbuf,"#%ld",varptr_item->address);

			    /* calculate the absolute address */
			    gen("move.l",addrbuf,"d0");
			    gen("sub.l",numbuf,"d0");

			    /* location in frame contains array/struct address 
			       (except for shared structure (see below) */  
			    gen("movea.l","d0","a0");
			    
			    /* address of a structure member? */
			    if (exist(id,structure))
			    {
			     /* shared struct? -> get struct variable address */
			     if (varptr_item->shared && lev == ONE) 
				gen("movea.l","(a0)","a0");

			     insymbol();  
			     if (sym == memberpointer)
			     {
			      insymbol();  
			      if (sym != ident) 
			         _error(7);
			      {
			       structype = varptr_item->other;
			       member = structype->structmem->next;
			       found=FALSE;
			       while ((member != NULL) && (!found))
			       {
			        if (strcmp(member->name,id) == 0)
				   found=TRUE;
			        else
			 	   member = member->next;
			       }
			       if (!found)
			 	  _error(67);  /* not a valid member */
			       else
				 {
				  /* push address of struct member */
				  sprintf(numbuf,"#%ld",member->offset);
				  gen("movea.l","(a0)","a0");
				  gen("adda.l",numbuf,"a0");
				  gen("move.l","a0","-(sp)");
				  /* store type for SWAP command */
				  struct_member_type = member->type;	  	
				 }
			       }
			      insymbol();
			     }
			     else
			     {
			      /* address of struct variable in stack frame */
			      gen("move.l","a0","-(sp)"); 
			      /* store type for SWAP command */
			      struct_member_type = longtype;
			     }	  	
			    }
			    else
			    /* array or array element address? */
			    {
				/* push array address */
			        gen("move.l","(a0)","-(sp)"); 

				insymbol();

				if (sym == lparen)
				{
				 /* calculate array element address */
				 have_lparen=TRUE;
				 push_indices(varptr_item);
				 get_abs_ndx(varptr_item); /* offset -> d7 */
				 gen("move.l","(sp)+","d0"); /* array start */
				 gen("add.l","d7","d0"); /* start+offset=addr */
			 	 gen("move.l","d0","-(sp)"); /* push address */
				 insymbol(); /* symbol after rparen */
				}
			    }
			    return(longtype);	    
			   }
			   else { _error(43); return(undefined); }
}

int find_object_size()
{
/* push the size (in bytes) 
   of a data object or type 
   onto the stack. 
*/
char numbuf[40];
int  nftype;

 if (sym == ident)
 {
  /* variable */
  if (exist(id,variable))
  {
   if (curr_item->type == shorttype)
   {
    gen("move.l","#2","-(sp)"); 
    nftype=longtype;
   }
   else
   if (curr_item->type == longtype)
   {
    gen("move.l","#4","-(sp)"); 
    nftype=longtype;
   }
   else
   if (curr_item->type == singletype)
   {
    gen("move.l","#4","-(sp)"); 
    nftype=longtype;
   }
   else
   if (curr_item->type == stringtype)
   {
    sprintf(numbuf,"#%ld",curr_item->size);
    gen("move.l",numbuf,"-(sp)"); 
    nftype=longtype;
   }
  }
  else
  /* array variable or structure definition? */
  if (exist(id,array) || exist(id,structdef))
  {
   sprintf(numbuf,"#%ld",curr_item->size);
   gen("move.l",numbuf,"-(sp)"); 
   nftype=longtype;
  }
  else
  /* structure variable? */
  if (exist(id,structure))
  {  
   sprintf(numbuf,"#%ld",curr_item->other->size);
   gen("move.l",numbuf,"-(sp)"); 
   nftype=longtype;
  }
  else
  {
   _error(43);	 /* undeclared array or variable */
   nftype=undefined;
  }
 }
 else
  /* type identifier? */
  if (sym == bytesym)
  {
   gen("move.l","#1","-(sp)"); 
   nftype=longtype;
  }
  else
  if (sym == shortintsym)
  {
   gen("move.l","#2","-(sp)"); 
   nftype=longtype;
  }
  else
  if (sym == longintsym || sym == addresssym)
  {
   gen("move.l","#4","-(sp)"); 
   nftype=longtype;
  }
  else
  if (sym == singlesym)
  {
   gen("move.l","#4","-(sp)"); 
   nftype=longtype;
  }
  else
  if (sym == stringsym)
  {
   sprintf(numbuf,"#%ld",MAXSTRLEN);
   gen("move.l",numbuf,"-(sp)"); 
   nftype=longtype;
  }
  else
  {
   /* expected an identifier or type */
   _error(60);
   nftype=undefined;
  }

 insymbol();
 return(nftype);
}
