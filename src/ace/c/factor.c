/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: Factor code **
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
	   6th,29th December 1992,
	   15th,28th February 1993,
	   6th,12th,13th June 1993,
	   6th September 1993,
	   24th,27th,28th,31st December 1993,
	   2nd,5th January 1994,
	   21st June 1994,
	   22nd August 1994,
	   1st October 1994,
	   11th March 1995
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	obj;
extern	int	typ;
extern	char   	id[MAXIDSIZE]; 
extern	char   	ut_id[MAXIDSIZE];
extern	SHORT  	shortval;
extern	LONG   	longval; 
extern	LONG   singleval;
extern	char   	stringval[MAXSTRLEN];
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	SHORT	dimsize[255];
extern	BOOL	end_of_source;
extern	FILE	*dest;
extern	char	ch;
extern	int  	lev;
extern	char 	numbuf[80];
extern	char 	librarybase[MAXIDSIZE+6];
extern	ACELIBS	acelib[NUMACELIBS];
extern	BOOL 	restore_a4;
extern	BOOL	restore_a5;
extern 	BOOL 	cli_args;

/* functions */
BOOL factorfunc()
{
/* 
** Return TRUE if fsym is in the list of
** functions (generally parameterless) 
** found in factor(). 
** PRINT needs this information.
*/

  switch(sym)
  {
    	case argcountsym	: return(TRUE);
    	case csrlinsym		: return(TRUE);
	case datestrsym		: return(TRUE);
	case daysym		: return(TRUE);
    	case errsym		: return(TRUE);
	case headingsym		: return(TRUE);
	case inkeysym		: return(TRUE);
	case possym		: return(TRUE);
	case rndsym		: return(TRUE); /* has optional parameter! */
	case systemsym		: return(TRUE);
	case timersym		: return(TRUE);
	case timestrsym		: return(TRUE);
	case xcorsym		: return(TRUE);
	case ycorsym		: return(TRUE);
	default			: return(FALSE);
  }
}

int factor()
{
char buf[80],srcbuf[80],strname[80],strlabel[80],sub_name[80];
char func_name[MAXIDSIZE],func_address[MAXIDSIZE+9];
char ext_name[MAXIDSIZE+1];
char *strbuf;
int  ftype=undefined;
int  arraytype=undefined;
SYM  *fact_item;
int  oldlevel;
BYTE libnum;
BOOL need_symbol;

 ftype=stringfunction();
 if (ftype != undefined) return(ftype);

 ftype=numericfunction();
 if (ftype != undefined) return(ftype);

 switch(sym)
 {
  case shortconst  : sprintf(numbuf,"#%d",shortval);
                     gen("move.w",numbuf,"-(sp)");
                     ftype=typ;
                     insymbol();
                     return(ftype);
                     break;

  case longconst   : sprintf(numbuf,"#%ld",longval);
       		     gen("move.l",numbuf,"-(sp)");
                     ftype=typ;
                     insymbol();
                     return(ftype);
                     break;

  case singleconst : sprintf(numbuf,"#$%lx",singleval);
       		     gen("move.l",numbuf,"-(sp)");
                     ftype=typ;
       		     insymbol();
                     return(ftype);
                     break;
  
  case stringconst : make_string_const(stringval);
       		     ftype=typ;
       		     insymbol();
                     return(ftype);
       		     break;

  case ident : /* does object exist? */

	       /* in case it's a subprogram */
  	       strcpy(sub_name,"_SUB_");
   	       strcat(sub_name,id);

	       /* store id in case it's a function */
	       strcpy(func_name,id);
  	       remove_qualifier(func_name);

	       /* make external variable name */
  	       /* add an underscore prefix 
     	        if one is not present. 
  	       */
	       strcpy(buf,ut_id);
  	       remove_qualifier(buf);
               if (buf[0] != '_')
               {
                strcpy(ext_name,"_\0");
                strcat(ext_name,buf);
               }
               else 
                   strcpy(ext_name,buf);

	       /* what sort of object is it? */
	       if (exist(id,array)) 
                  { obj=array; arraytype=typ=curr_item->type; }
               else
                if (exist(sub_name,subprogram)) 
       	 	   { obj=subprogram; typ=curr_item->type; }
	       else
                if (exist(sub_name,definedfunc)) 
       	 	   { obj=definedfunc; typ=curr_item->type; }
               else
                if (exist(func_name,function)) 
       	 	   { obj=function; typ=curr_item->type; }
	       else		
		if (exist(ext_name,extfunc)) 
		   { obj=extfunc; typ=curr_item->type; } 
	       else
		if (exist(ext_name,extvar)) 
		   { obj=extvar; typ=curr_item->type; }	
	       else
		if (exist(id,structure)) obj=structure; 
               else
		if (exist(id,constant)) 
		   { obj=constant; typ=curr_item->type; } 
	       else
	        if (exist(id,obj))    /* obj == variable? */
		   typ=curr_item->type;
               else
		  {
		   /* object doesn't exist so create a default variable */
		   enter(id,typ,obj,0);  
		  }

	       fact_item=curr_item; 

               /* frame address of object */
	       if (obj == subprogram) { oldlevel=lev; lev=ZERO; }

               itoa(-1*curr_item->address,srcbuf,10);
               strcat(srcbuf,frame_ptr[lev]);
	       
	       if (obj == subprogram) lev=oldlevel;
  
               /* 
	       ** what sort of object? -> constant,variable,subprogram,
	       ** function (library,external,defined),array,structure.
	       */

               if (obj == variable)		 /* variable */
               {
                /* shared variable in SUB? */
		if ((fact_item->shared) && (lev == ONE) && (typ != stringtype))
                {
		 gen("move.l",srcbuf,"a0");
		 if (typ == shorttype)
                    gen("move.w","(a0)","-(sp)");
		 else
                    gen("move.l","(a0)","-(sp)");
		}
                else  
		/* ordinary variable */ 
  		if (typ == shorttype)
            	   gen("move.w",srcbuf,"-(sp)");
  		else  /* string, long, single */ 
     		   gen("move.l",srcbuf,"-(sp)"); /* push value */

   		ftype=typ;
   		insymbol();
	  	if (sym == lparen) _error(71);  /* undimensioned array? */
   		return(ftype);
  	       }
               else
	       if (obj == structure)  /* structure */
	       {
		ftype=push_struct(fact_item);
		return(ftype);
	       }
	       else
   	       if (obj == constant)  /* defined constant */
	       {
		push_num_constant(typ,fact_item); 
		ftype=typ;
		insymbol();
	  	if (sym == lparen) _error(71);  /* undimensioned array? */
		return(ftype);
	       }
		else
		if (obj == extvar)  /* external variable */
		{
		 if (typ == shorttype)
		    /* short integer */	
		    gen("move.w",ext_name,"-(sp)");
		 else
		 if (typ == stringtype)
		    /* string */
		    gen("pea",ext_name,"  ");		 
		 else
		    /* long integer, single-precision */
		    gen("move.l",ext_name,"-(sp)");
		 ftype=typ;
		 insymbol();
 	  	 if (sym == lparen) _error(71);  /* undimensioned array? */
		 return(ftype);
		}
  	        else
  		if (obj == subprogram || obj == definedfunc)  /* subprogram */
  		{ 
		 /* CALL the subprogram */
		 if (fact_item->no_of_params != 0) 
		 {
		  insymbol();
		  load_params(fact_item);
		 }
		 gen("jsr",sub_name,"  ");

		 /* push the return value */
    		 if (fact_item->type == shorttype)
	 	 {
          	  if (fact_item->object == subprogram && 
		      fact_item->address != extfunc)
			gen("move.w",srcbuf,"-(sp)");
		  else
			gen("move.w","d0","-(sp)");
		 }
  		 else  /* string, long, single */
  		 {
		  if (fact_item->object == subprogram &&
		      fact_item->address != extfunc)
  		  	gen("move.l",srcbuf,"-(sp)"); /* push value */
		  else
			gen("move.l","d0","-(sp)");
  		 }
  		 ftype=fact_item->type;
   		 insymbol();
   		 return(ftype);
 		}
	        else
	        if (obj == function)	/* library function */
 		{
    		 if (fact_item->no_of_params != 0)
    		    { insymbol(); load_func_params(fact_item); }
    		 /* call it */
  		 if ((libnum=check_for_ace_lib(fact_item->libname))==NEGATIVE) 
       		    make_library_base(fact_item->libname);
    		 else
       		    strcpy(librarybase,acelib[libnum].base);
    		 gen("move.l",librarybase,"a6");
    		 itoa(fact_item->address,func_address,10);
    		 strcat(func_address,"(a6)");
    		 gen("jsr",func_address,"  ");

		 if (fact_item->type == shorttype)
		    gen("move.w","d0","-(sp)");
		 else
		    gen("move.l","d0","-(sp)"); /* push return value */

                 if (restore_a4) 
                    { gen("move.l","_a4_temp","a4"); restore_a4=FALSE; }
                 if (restore_a5) 
                    { gen("move.l","_a5_temp","a5"); restore_a5=FALSE; }

  		 ftype=fact_item->type;
   		 insymbol();
   		 return(ftype);
	        }		 
  		else
	        if (obj == extfunc)
                {
		 /* external function call */
		 insymbol();
	         call_external_function(ext_name,&need_symbol);
		 /* push return value */
		 if (fact_item->type == shorttype)
		    gen("move.w","d0","-(sp)");
		 else
		    gen("move.l","d0","-(sp)");
		 ftype=fact_item->type;
		 if (need_symbol) insymbol();
		 return(ftype);
		}
 		else
                if (obj == array)
                {
		 push_indices(fact_item);
	  	 get_abs_ndx(fact_item);
		 gen("move.l",srcbuf,"a0");

		 if (arraytype == stringtype)
		 {
		  /* push start address of string within BSS object */
		  gen("adda.l","d7","a0");
		  gen("move.l","a0","-(sp)");
		 }   
 		 else
		 if (arraytype == shorttype)
		    gen("move.w","0(a0,d7.L)","-(sp)");
		 else
		    gen("move.l","0(a0,d7.L)","-(sp)");

   		 ftype=arraytype;  /* typ killed by push_indices()! */
   		 insymbol();
   		 return(ftype);
		}
  		break;

  case lparen : insymbol();
  		ftype=expr();
  		if (sym != rparen) _error(9);
  		insymbol();
  		return(ftype);
         	break;

  /* @<object> */
  case atsymbol : insymbol();
		  if (sym != ident)
		     { _error(7); ftype=undefined; insymbol(); }
		  else
		  {
		   strcpy(buf,id);
		   ftype=address_of_object();
		   /* structure and array code returns next symbol */
		   if (!exist(buf,structure) && !exist(buf,array)) 
		      insymbol();
		  }
	          return(ftype);
		  break;

  /* parameterless functions */

  case argcountsym : gen("jsr","_argcount","  ");
		     gen("move.l","d0","-(sp)");
		     enter_XREF("_argcount");
		     ftype=longtype;
		     cli_args=TRUE;
		     insymbol();
		     return(ftype);
		     break;

  case csrlinsym  : gen("jsr","_csrlin","  ");
		    gen("move.w","d0","-(sp)");
		    enter_XREF("_csrlin");
		    ftype=shorttype;
		    insymbol();
		    return(ftype);
		    break;
 
  case datestrsym : gen("jsr","_date","  ");
		    gen("move.l","d0","-(sp)");
		    enter_XREF("_date");
		    enter_XREF("_DOSBase"); /* DateStamp() needs dos.library */
		    ftype=stringtype;
		    insymbol();
		    return(ftype);
		    break;			

  case daysym   : gen("jsr","_getday","  ");
		  gen("move.l","d0","-(sp)");
		  enter_XREF("_getday");
		  ftype=longtype;
		  insymbol();
		  return(ftype);
		  break;

  case errsym : gen("jsr","_err","  ");
		gen("move.l","d0","-(sp)");
		enter_XREF("_err");
		ftype=longtype;
		insymbol();
		return(ftype);
		break;

  case headingsym : gen("jsr","_heading","  ");
		    gen("move.w","d0","-(sp)");
		    enter_XREF("_heading");
		    enter_XREF("_IntuitionBase");
		    ftype=shorttype;
		    insymbol();
		    return(ftype);
		    break;

  case inkeysym : gen("jsr","_inkey","  ");
		  gen("move.l","d0","-(sp)");
		  enter_XREF("_inkey");
		  enter_XREF("_DOSBase");
		  ftype=stringtype;
	 	  insymbol();
		  return(ftype);
		  break;

  case possym  : gen("jsr","_pos","  ");
		 gen("move.w","d0","-(sp)");
		 enter_XREF("_pos");
		 ftype=shorttype;
		 insymbol();
		 return(ftype);
		 break;

  case rndsym : insymbol();
		if (sym == lparen)
		{
		  /* ignore dummy expression if exists */
		  insymbol();
		  ftype = make_integer(expr());
		  switch(ftype)
		  {
			case shorttype 	: gen("move.w","(sp)+","d0");
					  break;

			case longtype  	: gen("move.l","(sp)+","d0");
					  break;

			default		: _error(4);
		  }	
		  if (sym != rparen) _error(9);
		  else
		      insymbol();
		}
		gen("jsr","_rnd","  ");
		gen("move.l","d0","-(sp)");
		enter_XREF("_rnd");
		enter_XREF("_MathBase"); /* make sure mathffp lib is open */
		ftype=singletype;
		return(ftype);
		break;

  case systemsym : gen("jsr","_system_version","  ");
		   gen("move.w","d0","-(sp)");
		   enter_XREF("_system_version");
		   ftype=shorttype;
		   insymbol();
		   return(ftype);
		   break;

  case timersym : gen("jsr","_timer","  ");
		  gen("move.l","d0","-(sp)");
		  enter_XREF("_timer");
		  enter_XREF("_DOSBase"); /* DateStamp() needs dos.library */
		  enter_XREF("_MathBase"); /* _timer needs basic ffp funcs */
		  ftype=singletype;
		  insymbol();
		  return(ftype);
		  break;

  case timestrsym : gen("jsr","_timeofday","  ");
		    gen("move.l","d0","-(sp)");
		    enter_XREF("_timeofday");
		    enter_XREF("_DOSBase"); /* DateStamp() needs dos.library */
		    ftype=stringtype;
		    insymbol();
		    return(ftype);
		    break;

  case xcorsym	: gen("jsr","_xcor","  ");
		  gen("move.w","d0","-(sp)");
		  enter_XREF("_xcor");
		  enter_XREF("_GfxBase");
		  ftype=shorttype;
		  insymbol();
		  return(ftype);
		  break;

  case ycorsym	: gen("jsr","_ycor","  ");
		  gen("move.w","d0","-(sp)");
		  enter_XREF("_ycor");
		  enter_XREF("_GfxBase");
		  ftype=shorttype;
		  insymbol();
		  return(ftype);
		  break;
 }

 /* none of the above! */
 ftype=undefined;
 _error(13);  /* illegal expression */
 insymbol();
 return(ftype);
}
