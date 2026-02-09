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
extern	BOOL	gadtoolsused;
extern	SYM	*last_addr_sub_sym;
extern	int	last_bind_bound_count;
extern	int	addr[];
extern	unsigned long gt_tag_lookup();

/* helper: GADGET GETATTR(id, TAG) */
static int gadget_getattr()
{
char vbuf[40];
unsigned long tag_id;

    insymbol();  /* eat GETATTR */
    if (sym != lparen) { _error(14); return(undefined); }
    insymbol();
    make_sure_long(expr());  /* id */
    if (sym != comma) { _error(16); return(undefined); }
    insymbol();
    if (sym != ident) { _error(82); return(undefined); }
    tag_id = gt_tag_lookup(id);
    if (tag_id == 0) { _error(82); return(undefined); }
    sprintf(vbuf, "#$%lx", tag_id);
    gen("move.l", vbuf, "-(sp)");
    insymbol();
    if (sym != rparen) { _error(9); return(undefined); }
    insymbol();

    gen_rt_call("_GetGTGadgetAttr");
    gen_stack_cleanup(8);
    gen("move.l","d0","-(sp)");
    return(longtype);
}

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
  case inputboxsym	: return(TRUE);	/* this is here for convenience */
  case inputboxstrsym	: return(TRUE);
  case inputstrsym 	: return(TRUE);
  case instrsym		: return(TRUE);
  case lcasestrsym  	: return(TRUE);
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
      			  gen_rt_call("_chrstring");
      			  gen("pea",strstorename,"  ");
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
			 gen_rt_call("_arg");
			 gen_stack_cleanup(8);
			 gen("move.l","d0","-(sp)");
			 cli_args=TRUE;
			 sftype=stringtype;
			}
			else { _error(4); sftype=undefined; }
			break;

    /* ASC */
    case ascsym  :	if (sftype == stringtype) 
			{
			 gen("move.l","(sp)+","a2");
			 gen_rt_call("_asc");
			 gen("move.w","d0","-(sp)");	
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
			 gen_rt_call("_binstr");
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
	
				gen_rt_call("_filerequest");
				gen_stack_cleanup(8);
				gen("move.l","d0","-(sp)");
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
			  gen_rt_call("_hexstrlong");
			 }
			 else
			  /* shorttype */
			  {
			   gen("move.w","(sp)+","d0");
			   gen_rt_call("_hexstrshort");
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
				gen_rt_call("_longint_input_box");
				gen_stack_cleanup(20);
				gen("move.l","d0","-(sp)");
				sftype = longtype;
			   }
			   else
			   {
				/* INPUTBOX$ */
				gen_rt_call("_string_input_box");
				gen_stack_cleanup(20);
				gen("move.l","d0","-(sp)");
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
		       	gen_rt_call("_inputstrfromfile");
		       	gen("move.l","d0","-(sp)");  /* push string result */

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
			   gen_rt_call("_instr");
			   gen("move.l","d0","-(sp)");	/* posn of Y$ in X$ */
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
			  gen_rt_call("_leftstr");
			  gen("move.l","a0","-(sp)");  /* addr of left$ */
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
			 gen_rt_call("_strlen");
			 gen("move.l","d0","-(sp)");
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
			 gen_rt_call("_octstr");
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
		   	  gen_rt_call("_rightstr");
			  gen("move.l","a0","-(sp)");  /* addr of right$ */
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
			   	gen_rt_call("_spacestring");
			 else
				gen_rt_call("_spc");
			 gen("move.l","d0","-(sp)");
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
			  gen_rt_call("_strlong");
			  gen("move.l","a0","-(sp)");  /* push string result */
			 }
			 else
			  if (sftype == shorttype)
			  {
			   gen("move.w","(sp)+","d0");
			   gen_rt_call("_strshort");
 			   gen("move.l","a0","-(sp)");  /* push string result */
			  }
			  else
			   if (sftype == singletype)
			   {
			    gen_rt_call("_strsingle");
			    gen_stack_cleanup(4);
			    gen("move.l","d0","-(sp)"); /* push string result */
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
			   gen_ext_to_long(TRUE, "d1");	/* MID$(X$,1,1) */
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
			  gen_rt_call("_stringstr");
			  gen("move.l","d0","-(sp)");	/* push string result */
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
		           gen_rt_call("_midstr");
			   gen("move.l","a0","-(sp)");  /* addr of mid$ */
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
			 gen_rt_call("_ptab");
			 gen("move.l","a0","-(sp)");  /* NULL ptab string */
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
			 gen_rt_call("_horiz_tab");
			 gen("move.l","a0","-(sp)");  /* addr of tab string */
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
			   gen_rt_call("_strlen"); /* inlen in d0 */
			   sprintf(srcbuf,"#%ld",MAXSTRLEN); /* #MAXSTRLEN */
			   gen("move.l",srcbuf,"d1"); /* outlen = MAXSTRLEN */
			   gen("movea.l","_TransBase","a6");
			   gen("jsr","_LVOTranslate(a6)","  ");
			   gen("pea",tempstrname,"  "); /* outstr on stack */
			   enter_XREF("_TransBase");
			   enter_XREF("_LVOTranslate");
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
			 gen_rt_call("_ucase");
			 gen("move.l","a0","-(sp)");
			 sftype=stringtype;
			}
			else { _error(4); sftype=undefined; }
   			break;

    /* LCASE$ */
    case lcasestrsym  :	if (sftype == stringtype)
			{
			 gen("move.l","(sp)+","a1");
		   	 make_temp_string();
			 gen("lea",tempstrname,"a0"); /* result buffer */
			 gen_rt_call("_lcase");
			 gen("move.l","a0","-(sp)");
			 sftype=stringtype;
			}
			else { _error(4); sftype=undefined; }
   			break;

    /* VAL */
    case valsym :	if (sftype == stringtype)
			{
			 gen_rt_call("_val"); /* string is on the stack */
			 gen_stack_cleanup(4);
			 gen("move.l","d0","-(sp)");
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
  case bindsym		: return(TRUE);
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
  if (func == gadgetsym && sym == getattrsym)
  {
   nftype = gadget_getattr();
   return(nftype);
  }
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
   	   		gen_rt_call("_absw");
   	   		gen("move.w","d0","-(sp)");
         	     }
         	     else
         	     if (nftype == longtype)
         	     {
           		gen("move.l","(sp)+","d0");
   	   		gen_rt_call("_absl");
   	   		gen("move.l","d0","-(sp)");
         	     }
         	     else
         	     if (nftype == singletype)
         	     {
           		gen("move.l","(sp)+","d0");
   	   		gen_rt_call("_absf");
   	   		gen("move.l","d0","-(sp)");
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
			 gen_rt_call("_ACEalloc");
			 gen_stack_cleanup(8);
			 gen("move.l","d0","-(sp)");  /* push result */
			 enter_XREF("_IntuitionBase");
			}
			else { _error(4); nftype=undefined; }
			break;

	 /* BIND */
	 case bindsym :
	  {
	   /* BIND(@SubName, expr1, expr2, ...)
	      First arg (nftype) was already evaluated by expr() --
	      it should be the address from @SubName (longtype).
	      last_addr_sub_sym should be set by address_of_object(). */
	   SYM *bind_sub;
	   int bound_count = 0;
	   int record_size;
	   char boundtemps[MAXPARAMS][80];
	   char functemp[80];
	   char offsetbuf[40];
	   char nbuf[80];
	   int argtype;
	   int bi;

	   if (nftype != longtype || last_addr_sub_sym == NULL ||
	       last_addr_sub_sym->object != subprogram)
	   {
	     _error(4); nftype = undefined; break;
	   }

	   bind_sub = last_addr_sub_sym;

	   /* Store function address in a temp */
	   addr[lev] += 4;
	   gen_frame_addr(addr[lev], functemp);
	   gen("move.l", "(sp)+", functemp);

	   /* Parse and evaluate bound arguments */
	   while (sym == comma && bound_count < bind_sub->no_of_params) {
	     insymbol();
	     argtype = expr();

	     /* Coerce to expected type */
	     switch(bind_sub->p_type[bound_count]) {
	       case shorttype:
	         make_sure_short(argtype);
	         /* Extend to long for uniform 4-byte storage */
	         gen("move.w", "(sp)+", "d0");
	         gen_ext_to_long(FALSE, "d0");
	         gen("move.l", "d0", "-(sp)");
	         break;
	       case longtype:
	         if ((argtype = make_integer(argtype)) == shorttype) make_long();
	         else if (argtype == notype) _error(4);
	         break;
	       case singletype:
	         gen_Flt(argtype);
	         break;
	       case stringtype:
	         if (argtype != stringtype) _error(4);
	         break;
	     }

	     /* Store in temp */
	     addr[lev] += 4;
	     gen_frame_addr(addr[lev], boundtemps[bound_count]);
	     gen("move.l", "(sp)+", boundtemps[bound_count]);

	     bound_count++;
	   }

	   /* Allocate closure record with signature info:
	      14 bytes header + param_count bytes for types + padding + bound args
	      Header: magic(4) + func(4) + total_params(2) + bound_count(2) + return_type(1) + reserved(1)
	      Then: param types (1 byte each), padding to 4-byte alignment, bound args (4 bytes each) */
	   {
	    int param_bytes = bind_sub->no_of_params;
	    int header_plus_params = 14 + param_bytes;
	    int param_padding = (4 - (header_plus_params % 4)) % 4;
	    int bound_args_offset = header_plus_params + param_padding;
	    int pi;

	    record_size = bound_args_offset + bound_count * 4;
	    sprintf(nbuf, "#%d", record_size);
	    gen("move.l", nbuf, "-(sp)");     /* size */
	    gen("move.l", "#9", "-(sp)");     /* memory type */
	    gen_rt_call("_ACEalloc");
	    gen_stack_cleanup(8);
	    gen("move.l", "d0", "a2");
	    enter_XREF("_IntuitionBase");

	    /* Fill closure record header */
	    gen("move.l", "#$434C5352", "(a2)");    /* magic "CLSR" */
	    gen("move.l", functemp, "4(a2)");       /* func ptr */
	    sprintf(nbuf, "#%d", bind_sub->no_of_params);
	    gen("move.w", nbuf, "8(a2)");           /* total param count */
	    sprintf(nbuf, "#%d", bound_count);
	    gen("move.w", nbuf, "10(a2)");          /* bound count */

	    /* Write return type at offset 12.
	       Encode as small value: type - 2000 (shorttype=1, longtype=2, etc.) */
	    sprintf(nbuf, "#%d", bind_sub->type - 2000);
	    gen("move.b", nbuf, "12(a2)");

	    /* Write reserved byte at offset 13 (zero) */
	    gen("move.b", "#0", "13(a2)");

	    /* Write param types starting at offset 14.
	       Encode as small values: type - 2000 */
	    for (pi = 0; pi < bind_sub->no_of_params; pi++) {
	      sprintf(nbuf, "#%d", bind_sub->p_type[pi] - 2000);
	      sprintf(offsetbuf, "%d(a2)", 14 + pi);
	      gen("move.b", nbuf, offsetbuf);
	    }

	    /* Store bound arg values */
	    for (bi = 0; bi < bound_count; bi++) {
	      sprintf(offsetbuf, "%d(a2)", bound_args_offset + bi * 4);
	      gen("move.l", boundtemps[bi], offsetbuf);
	    }
	   }

	   /* Push record address as result */
	   gen("move.l", "a2", "-(sp)");
	   nftype = longtype;

	   /* Set bound count + 1 for assign.c to pick up.
	      We add 1 so zero-arg BIND stores 1, distinguishing
	      it from direct @SubName which stores 0. */
	   last_bind_bound_count = bound_count + 1;
	  }
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
			   gen_ext_to_long(FALSE, "d0");
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
		   	 gen_rt_call("_eoftest");
		   	 gen("move.l","d0","-(sp)");
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
			 gen_ffp_call("_LVOSPFix");
			 gen("move.l","d0","-(sp)");
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
		        gen_rt_call("_fre");
		        gen("move.l","d0","-(sp)");
		        nftype=longtype;
		       }
		       else { _error(4); nftype=undefined; }
		       break;

	 /* GADGET */
	 case gadgetsym : nftype = make_integer(nftype);
			  if (nftype == shorttype) make_long();
			  if (gadtoolsused)
			  {
			    gen_rt_call("_GadFuncGT");
			    gen_stack_cleanup(4);
			    gen("move.l","d0","-(sp)");
			  }
			  else
			  {
			    gen_rt_call("_GadFunc");
			    gen_stack_cleanup(4);
			    gen("move.l","d0","-(sp)");
			  }
			  nftype=longtype;
			  break;

	 /* HANDLE */
	 case handlesym : if (nftype != stringtype)
			  {
			   check_for_event();

			   if (make_integer(nftype) == shorttype)
			      make_long();
			   gen("move.l","(sp)+","d0");
			   gen_rt_call("_handle");
			   gen("move.l","d0","-(sp)");
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

			    gen_rt_call("_iff_func");
			    gen_stack_cleanup(8);
			    gen("move.l","d0","-(sp)");	/* push return value */
			
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
			 gen_ffp_call("_LVOSPFloor");
			 gen("jsr","_LVOSPFix(a6)","  ");
			 enter_XREF("_LVOSPFix");
			 gen("move.l","d0","-(sp)");
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
			 gen_rt_call("_FilePosition");
			 gen_stack_cleanup(4);
			 gen("move.l","d0","-(sp)");
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
			 gen_rt_call("_lof");
			 gen("move.l","d0","-(sp)");
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
				gen_rt_call("_long_from_string");
				gen_stack_cleanup(4);
				gen("move.l","d0","-(sp)");
				nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			  break;
		
	 /* MENU */		
	 case menusym : if (nftype != stringtype)
			{
				nftype = make_integer(nftype);
				if (nftype == shorttype) make_long();
				gen_rt_call("_MenuFunc");
				gen_stack_cleanup(4);
				gen("move.l","d0","-(sp)");
				nftype=longtype;
			}
			else { _error(4); nftype=undefined; }
			break;
			
	 /* MOUSE */
	 case mousesym : if (nftype != stringtype)
			 {
			  make_sure_short(nftype);
			  gen("move.w","(sp)+","d0");
			  gen_rt_call("_mouse");
			  gen("move.w","d0","-(sp)");
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
			     gen_rt_call("_sysrequest");
			     gen_stack_cleanup(12);
			     gen("move.w","d0","-(sp)");
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
			    gen_ext_to_long(FALSE, "d0");
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
			     gen_ext_to_long(FALSE, "d0");
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
			     gen_ext_to_long(FALSE, "d0");
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
			 gen_rt_call("_potx");
			 gen("move.w","d0","-(sp)");
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
			 gen_rt_call("_poty");
			 gen("move.w","d0","-(sp)");
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

			    gen_rt_call("_serial_func");
			    gen_stack_cleanup(8);
			    gen("move.l","d0","-(sp)");	/* push return value */
			
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
			 gen_rt_call("_sgnw");
			 gen("move.l","d0","-(sp)");
			 nftype=longtype;
			}
			else
			if (nftype == longtype)
			{
			 gen("move.l","(sp)+","d0");
			 gen_rt_call("_sgnl");
			 gen("move.l","d0","-(sp)");
			 nftype=longtype;
			}
			else
			if (nftype == singletype)
			{
			 gen("move.l","(sp)+","d1");
			 gen_rt_call("_sgnf");
			 gen("move.l","d0","-(sp)");
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
			 gen_rt_call("_stick");
			 gen("move.w","d0","-(sp)");
			 nftype=shorttype;
			 break;
	 /* STRIG */
	 case strigsym : make_sure_short(nftype);
			 gen("move.w","(sp)+","d0");
			 gen_rt_call("_strig");
			 gen("move.w","d0","-(sp)");
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
			  gen_rt_call("_windowfunc");
			  gen("move.l","d0","-(sp)");
			  enter_XREF("_IntuitionBase");
			  nftype=longtype;
			  break;

	 /* SAY */
	 case saysym	: if (nftype != stringtype)
			  {
			   nftype=make_integer(nftype);
			   if (nftype == shorttype) make_long();
			   gen_rt_call("_sayfunc");
			   gen_stack_cleanup(4);
			   gen("move.l","d0","-(sp)");
			   nftype=longtype;
			  }
			  else { _error(4); nftype=undefined; }
			  break;

	 /* SCREEN */
	 case screensym : if (nftype != stringtype)
			  {
			   nftype = make_integer(nftype);
			   if (nftype == shorttype) make_long();
			   gen_rt_call("_screenfunc");
			   gen_stack_cleanup(4);
			   gen("move.l","d0","-(sp)");
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
			** [see ref.txt].
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
				last_addr_sub_sym = curr_item;
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
