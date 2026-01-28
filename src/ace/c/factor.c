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
extern	SYM	*last_addr_sub_sym;
extern	int	addr[];

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
	case chipsetsym		: return(TRUE);
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
SYM  *invoke_item;
SYM  *invoke_sub;
int  oldlevel;
BYTE libnum;
BOOL need_symbol;
int  i;
SHORT popcount;

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

	  if (invoke_item->other != NULL &&
	      invoke_item->other->object == subprogram &&
	      invoke_item->dims > 0)
	  {
	   /* Closure dispatch: bound args from record, free args from source */
	   invoke_sub = invoke_item->other;
	   {
	    int bound_count = invoke_item->dims;
	    int free_count = invoke_sub->no_of_params - bound_count;
	    int ci, formal_type;
	    SHORT par_addr = -8;
	    char formaltemp[MAXPARAMS][80];
	    int formaltype[MAXPARAMS];
	    char addrtmp[80], offsettmp[40];
	    BOOL had_parens = FALSE;

	    /* Parse free args from source into temps */
	    if (free_count > 0)
	    {
	     if (sym != lparen) { _error(14); }
	     else
	     {
	      had_parens = TRUE;
	      for (ci=0; ci<free_count; ci++)
	      {
	       insymbol();
	       formal_type = expr();

	       /* Coerce to expected type */
	       switch(invoke_sub->p_type[bound_count + ci])
	       {
	        case shorttype: make_sure_short(formal_type); break;
	        case longtype:
	          if ((formal_type = make_integer(formal_type)) == shorttype)
	            make_long();
	          else if (formal_type == notype) _error(4);
	          break;
	        case singletype: gen_Flt(formal_type); break;
	        case stringtype:
	          if (formal_type != stringtype) _error(4);
	          break;
	       }

	       /* Store in frame temp */
	       if (invoke_sub->p_type[bound_count + ci] == shorttype)
	       {
	        addr[lev] += 2;
	        itoa(-1*addr[lev], formaltemp[bound_count + ci], 10);
	        strcat(formaltemp[bound_count + ci], frame_ptr[lev]);
	        gen("move.w", "(sp)+", formaltemp[bound_count + ci]);
	        formaltype[bound_count + ci] = shorttype;
	       }
	       else
	       {
	        addr[lev] += 4;
	        itoa(-1*addr[lev], formaltemp[bound_count + ci], 10);
	        strcat(formaltemp[bound_count + ci], frame_ptr[lev]);
	        gen("move.l", "(sp)+", formaltemp[bound_count + ci]);
	        formaltype[bound_count + ci] = longtype;
	       }

	       if (ci < free_count - 1 && sym != comma) { _error(16); break; }
	      }
	      if (sym != rparen) _error(9);
	     }
	    }
	    else
	    {
	     /* No free args; skip parens if present */
	     if (sym == lparen)
	     {
	      had_parens = TRUE;
	      insymbol();
	      if (sym != rparen) _error(9);
	     }
	    }

	    /* Load closure record address */
	    itoa(-1*invoke_item->address, addrtmp, 10);
	    strcat(addrtmp, frame_ptr[lev]);
	    gen("move.l", addrtmp, "a2");

	    /* Read bound args from closure record into temps */
	    for (ci=0; ci<bound_count; ci++)
	    {
	     sprintf(offsettmp, "%d(a2)", 12 + ci * 4);
	     if (invoke_sub->p_type[ci] == shorttype)
	     {
	      /* Stored as long, load as long then truncate later */
	      addr[lev] += 4;
	      itoa(-1*addr[lev], formaltemp[ci], 10);
	      strcat(formaltemp[ci], frame_ptr[lev]);
	      gen("move.l", offsettmp, formaltemp[ci]);
	      formaltype[ci] = shorttype; /* mark for short copy later */
	     }
	     else
	     {
	      addr[lev] += 4;
	      itoa(-1*addr[lev], formaltemp[ci], 10);
	      strcat(formaltemp[ci], frame_ptr[lev]);
	      gen("move.l", offsettmp, formaltemp[ci]);
	      formaltype[ci] = longtype;
	     }
	    }

	    /* Forbid multitasking before frame setup */
	    gen("movea.l", "_AbsExecBase", "a6");
	    gen("jsr", "_LVOForbid(a6)", "  ");
	    enter_XREF("_AbsExecBase");
	    enter_XREF("_LVOForbid");

	    /* Copy all params into next frame */
	    par_addr = -8;
	    for (ci=0; ci<invoke_sub->no_of_params; ci++)
	    {
	     if (invoke_sub->p_type[ci] == shorttype)
	     {
	      par_addr -= 2;
	      itoa(par_addr, addrtmp, 10);
	      strcat(addrtmp, "(sp)");
	      if (ci < bound_count)
	      {
	       /* Bound arg: stored as long, truncate to short */
	       gen("move.l", formaltemp[ci], "d0");
	       gen("move.w", "d0", addrtmp);
	      }
	      else
	       gen("move.w", formaltemp[ci], addrtmp);
	     }
	     else
	     {
	      par_addr -= 4;
	      itoa(par_addr, addrtmp, 10);
	      strcat(addrtmp, "(sp)");
	      gen("move.l", formaltemp[ci], addrtmp);
	     }
	    }

	    /* Call through closure's function pointer */
	    itoa(-1*invoke_item->address, addrtmp, 10);
	    strcat(addrtmp, frame_ptr[lev]);
	    gen("move.l", addrtmp, "a2");
	    gen("move.l", "4(a2)", "a0");
	    gen("jsr", "(a0)", "  ");

	    /* Push return value */
	    if (invoke_sub->address != extfunc)
	    {
	     oldlevel=lev; lev=ZERO;
	     itoa(-1*invoke_sub->address,srcbuf,10);
	     strcat(srcbuf,frame_ptr[ZERO]);
	     lev=oldlevel;
	     if (invoke_sub->type == shorttype)
	        gen("move.w",srcbuf,"-(sp)");
	     else
	        gen("move.l",srcbuf,"-(sp)");
	    }
	    else
	    {
	     if (invoke_sub->type == shorttype)
	        gen("move.w","d0","-(sp)");
	     else
	        gen("move.l","d0","-(sp)");
	    }
	    ftype = invoke_sub->type;

	    if (had_parens) insymbol();
	   }
	  }
	  else
	  if (invoke_item->other != NULL &&
	      invoke_item->other->object == subprogram)
	  {
	   /* SUB calling convention */
	   invoke_sub = invoke_item->other;

	   if (invoke_sub->no_of_params > 0) load_params(invoke_sub);

	   itoa(-1*invoke_item->address,buf,10);
	   strcat(buf,frame_ptr[lev]);
	   gen("move.l",buf,"a0");
	   gen("jsr","(a0)","  ");

	   /* push return value from SUB's frame variable */
	   if (invoke_sub->address != extfunc)
	   {
	    oldlevel=lev; lev=ZERO;
	    itoa(-1*invoke_sub->address,srcbuf,10);
	    strcat(srcbuf,frame_ptr[ZERO]);
	    lev=oldlevel;
	    if (invoke_sub->type == shorttype)
	       gen("move.w",srcbuf,"-(sp)");
	    else
	       gen("move.l",srcbuf,"-(sp)");
	   }
	   else
	   {
	    if (invoke_sub->type == shorttype)
	       gen("move.w","d0","-(sp)");
	    else
	       gen("move.l","d0","-(sp)");
	   }
	   ftype = invoke_sub->type;

	   if (invoke_sub->no_of_params > 0) insymbol();
	  }
	  else
	  {
	   /* MC/C calling convention */
	   if (sym == lparen)
	   {
	    load_mc_params(invoke_item);

	    itoa(-1*invoke_item->address,buf,10);
	    strcat(buf,frame_ptr[lev]);
	    gen("move.l",buf,"a0");
	    gen("jsr","(a0)","  ");

	    if (invoke_item->no_of_params != 0)
	    {
	     popcount=0;
	     for (i=0;i<invoke_item->no_of_params;i++)
	     {
	      if (invoke_item->p_type[i] == shorttype) popcount += 2;
	      else popcount += 4;
	     }
	     strcpy(buf,"#\0");
	     itoa(popcount,srcbuf,10);
	     strcat(buf,srcbuf);
	     gen("add.l",buf,"sp");
	    }
	    insymbol();
	   }
	   else
	   {
	    /* no parameters */
	    itoa(-1*invoke_item->address,buf,10);
	    strcat(buf,frame_ptr[lev]);
	    gen("move.l",buf,"a0");
	    gen("jsr","(a0)","  ");
	   }

	   /* return value via d0 */
	   gen("move.l","d0","-(sp)");
	   ftype = longtype;
	  }
	 }
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

  case chipsetsym : gen("jsr","_chipset","  ");
		    gen("move.w","d0","-(sp)");
		    enter_XREF("_chipset");
		    enter_XREF("_GfxBase");
		    ftype=shorttype;
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
