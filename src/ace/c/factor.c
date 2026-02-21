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

/* externals */
extern	int	sym;
extern	int	obj;
extern	int	typ;
extern	char   	id[MAXIDSIZE];
extern	char   	ut_id[MAXIDSIZE];
extern	SHORT  	shortval;
extern	LONG   	longval;
extern	float  singleval;
extern	char   	stringval[MAXSTRLEN];
extern	SYM	*curr_item;
extern	int  	lev;
extern	char 	numbuf[80];
extern 	BOOL 	cli_args;
extern	LONG	atomval;

/* functions */
BOOL factorfunc(void)
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
	case chipsetsym		: return(TRUE);
    	case csrlinsym		: return(TRUE);
	case datestrsym		: return(TRUE);
	case daysym		: return(TRUE);
    	case errsym		: return(TRUE);
	case inkeysym		: return(TRUE);
	case possym		: return(TRUE);
	case rndsym		: return(TRUE); /* has optional parameter! */
	case systemsym		: return(TRUE);
	case timersym		: return(TRUE);
	case timestrsym		: return(TRUE);
	default			: return(FALSE);
  }
}

static int handle_ident_factor(void)
{
char srcbuf[80],sub_name[80];
char func_name[MAXIDSIZE];
char ext_name[MAXIDSIZE+1];
int  ftype=undefined;
int  arraytype=undefined;
SYM  *fact_item;
int  oldlevel;
BOOL need_symbol;

	       /* in case it's a subprogram */
  	       strcpy(sub_name,"_SUB_");
   	       strcat(sub_name,id);

	       /* store id in case it's a function */
	       strcpy(func_name,id);
  	       remove_qualifier(func_name);

	       make_ext_name(ext_name,ut_id);

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

               gen_var_addr(curr_item, srcbuf);

	       if (obj == subprogram) lev=oldlevel;

               /*
	       ** what sort of object? -> constant,variable,subprogram,
	       ** function (library,external,defined),array,structure.
	       */

               if (obj == variable)		 /* variable */
               {
		gen_load_var(fact_item, srcbuf);

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
		 /* CALLBACK SUB cannot be called from ACE code */
		 if (fact_item->is_callback)
		 {
		  _error(85);
		  insymbol();
		  return(notype);
		 }
		 /* CALL the subprogram */
		 if (fact_item->no_of_params != 0)
		 {
		  insymbol();
		  load_params(fact_item);
		 }
		 gen("jsr",sub_name,"  ");

		 /* push the return value */
		 if (fact_item->object == subprogram &&
		     fact_item->address != extfunc)
		    gen_push(fact_item->type, srcbuf);
		 else
		    gen_push(fact_item->type, "d0");
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
    		 gen_lib_call(fact_item);
		 gen_push(fact_item->type, "d0"); /* push return value */

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
		 gen_push(fact_item->type, "d0");
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
		 gen_push(arraytype, "0(a0,d7.L)");

   		 ftype=arraytype;  /* typ killed by push_indices()! */
   		 insymbol();
   		 return(ftype);
		}

	       return(undefined);
}

static int handle_parameterless(void)
{
int ftype;

 switch(sym)
 {
  case argcountsym : gen_rt_call("_argcount");
		     gen("move.l","d0","-(sp)");
		     ftype=longtype;
		     cli_args=TRUE;
		     insymbol();
		     return(ftype);

  case chipsetsym : gen_rt_call("_chipset");
		    gen("move.w","d0","-(sp)");
		    enter_XREF("_GfxBase");
		    ftype=shorttype;
		    insymbol();
		    return(ftype);

  case csrlinsym  : gen_rt_call("_csrlin");
		    gen("move.w","d0","-(sp)");
		    ftype=shorttype;
		    insymbol();
		    return(ftype);

  case datestrsym : gen_rt_call("_date");
		    gen("move.l","d0","-(sp)");
		    enter_XREF("_DOSBase"); /* DateStamp() needs dos.library */
		    ftype=stringtype;
		    insymbol();
		    return(ftype);

  case daysym   : gen_rt_call("_getday");
		  gen("move.l","d0","-(sp)");
		  ftype=longtype;
		  insymbol();
		  return(ftype);

  case errsym : gen_rt_call("_err");
		gen("move.l","d0","-(sp)");
		ftype=longtype;
		insymbol();
		return(ftype);

  case inkeysym : gen_rt_call("_inkey");
		  gen("move.l","d0","-(sp)");
		  enter_XREF("_DOSBase");
		  ftype=stringtype;
	 	  insymbol();
		  return(ftype);

  case possym  : gen_rt_call("_pos");
		 gen("move.w","d0","-(sp)");
		 ftype=shorttype;
		 insymbol();
		 return(ftype);

  case rndsym : insymbol();
		if (sym == lparen)
		{
		  /* ignore dummy expression if exists */
		  insymbol();
		  ftype = make_integer(expr());
		  switch(ftype)
		  {
			case shorttype 	: gen_pop(shorttype, "d0");
					  break;

			case longtype  	: gen_pop(longtype, "d0");
					  break;

			default		: _error(4);
		  }
		  if (sym != rparen) _error(9);
		  else
		      insymbol();
		}
		gen_rt_call("_rnd");
		gen("move.l","d0","-(sp)");
		enter_XREF("_MathBase"); /* make sure mathieeesingbas lib is open */
		ftype=singletype;
		return(ftype);

  case systemsym : gen_rt_call("_system_version");
		   gen("move.w","d0","-(sp)");
		   ftype=shorttype;
		   insymbol();
		   return(ftype);

  case timersym : gen_rt_call("_timer");
		  gen("move.l","d0","-(sp)");
		  enter_XREF("_DOSBase"); /* DateStamp() needs dos.library */
		  enter_XREF("_MathBase"); /* _timer needs basic float funcs */
		  ftype=singletype;
		  insymbol();
		  return(ftype);

  case timestrsym : gen_rt_call("_timeofday");
		    gen("move.l","d0","-(sp)");
		    enter_XREF("_DOSBase"); /* DateStamp() needs dos.library */
		    ftype=stringtype;
		    insymbol();
		    return(ftype);

 }

 return(undefined);
}

int factor(void)
{
char buf[80];
int  ftype=undefined;
SYM  *invoke_item;

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

  case longconst   : sprintf(numbuf,"#%ld",longval);
       		     gen("move.l",numbuf,"-(sp)");
                     ftype=typ;
                     insymbol();
                     return(ftype);

  case singleconst : { FLOAT_BITS u; u.f = singleval;
		       sprintf(numbuf,"#$%lx",u.l); }
       		     gen("move.l",numbuf,"-(sp)");
                     ftype=typ;
       		     insymbol();
                     return(ftype);

  case stringconst : make_string_const(stringval);
       		     ftype=typ;
       		     insymbol();
                     return(ftype);

  case atomconst   : sprintf(numbuf,"#$%lx",(unsigned long)atomval);
                     gen("move.l",numbuf,"-(sp)");
                     ftype=atomtype;
                     insymbol();
                     return(ftype);

  case ident : return(handle_ident_factor());

  case lparen : insymbol();
  		ftype=expr();
  		if (sym != rparen) _error(9);
  		insymbol();
  		return(ftype);

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

  /* INVOKE -- indirect function call through a variable (expression context) */
  case invokesym :
	insymbol();
	if (sym != ident) { _error(7); ftype=undefined; insymbol(); }
	else
	{
	 if (!exist(id,variable) || curr_item->type != longtype)
	    { _error(4); ftype=undefined; }
	 else
	 {
	  invoke_item = curr_item;
	  insymbol();
	  ftype = handle_invoke(invoke_item, TRUE);
	 }
	}
	return(ftype);

  /* parameterless functions */
  case argcountsym :
  case chipsetsym :
  case csrlinsym :
  case datestrsym :
  case daysym :
  case errsym :
  case inkeysym :
  case possym :
  case rndsym :
  case systemsym :
  case timersym :
  case timestrsym : return(handle_parameterless());
 }

 /* none of the above! */
 ftype=undefined;
 _error(13);  /* illegal expression */
 insymbol();
 return(ftype);
}
