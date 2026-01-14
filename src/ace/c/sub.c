/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: subprogram code **
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
	   24th March 1993,
	   14th,20th,30th June 1993,
	   18th December 1993,
	   12th,21st June 1994
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	typ;
extern	int	lev;
extern	char   	id[MAXIDSIZE]; 
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	int  	addr[2]; 

/* functions */
void forward_ref()
{
char  sub_name[80];
SYM   *sub_ptr;
short param_count=0;
int   param_type;
int   sub_type=undefined;
/* declare a forward reference to a SUB -- see declare() 
   NO checking against symbol table is carried out */

 insymbol();

 /* type identifiers */
 if (sym == shortintsym || sym == longintsym || sym == addresssym ||
     sym == singlesym || sym == stringsym)
 {
  switch(sym)
  {
   case shortintsym : sub_type = shorttype;  break;
   case longintsym  : sub_type = longtype;   break;
   case addresssym  : sub_type = longtype;   break;
   case singlesym   : sub_type = singletype; break;
   case stringsym   : sub_type = stringtype; break;
  }
  insymbol();
 }

 if (sym != ident) _error(7);
 else
 {
  /* get the name */ 
  strcpy(sub_name,"_SUB_");
  strcat(sub_name,id);
  
  /* enter it into symbol table & mark as forward ref. */
  if (!exist(sub_name,subprogram))
  {
   if (sub_type == undefined) sub_type = typ;
   enter(sub_name,sub_type,subprogram,0);
   curr_item->decl=fwdref;
  }
  else _error(33); /* subprogram already declared */

  sub_ptr=curr_item;

  /* get parameters -- if any */  
  insymbol();
  if (sym != lparen) 
  {
   /* Is this an external subprogram? */
   if (sym == externalsym) 
   {
	insymbol();
	enter_XREF(sub_name);
	sub_ptr->address = extfunc;
   }

   sub_ptr->no_of_params=0;
   return; /* no parameters -> return sym */
  }
  else
  {
   /* parameters expected */
   do
   {
    param_type = undefined;

    insymbol();

    /* type identifiers */
    if (sym == shortintsym || sym == longintsym || sym == addresssym ||
        sym == singlesym || sym == stringsym)
    {
     switch(sym)
     {
      case shortintsym : param_type = shorttype;  break;
      case longintsym  : param_type = longtype;   break;
      case addresssym  : param_type = longtype;   break;
      case singlesym   : param_type = singletype; break;
      case stringsym   : param_type = stringtype; break;
     }
     insymbol();
    }

    if (sym != ident) _error(7);  /* ident expected */
    else
    {
     /* store parameter type */
     if (param_type == undefined) param_type=typ;
     sub_ptr->p_type[param_count]=param_type;
     param_count++;
    }
    insymbol();
   }
   while ((sym == comma) && (param_count < MAXPARAMS));
  
   sub_ptr->no_of_params=param_count;

   if (param_count == MAXPARAMS) _error(42);  /* too many */

   if (sym != rparen) _error(9);
   insymbol();

   /* Is this an external subprogram? */
   if (sym == externalsym) 
   {
	insymbol();
	enter_XREF(sub_name);
	sub_ptr->address = extfunc;
   }
  }
 }
}

void load_params(sub_ptr)
SYM *sub_ptr;
{
SHORT par_addr=-8; /* one word above stack frame 
                  (allows for R.A. & address reg store) */
SHORT i,n;
int   formal_type;
char  addrbuf[40];
char  formaltemp[MAXPARAMS][80],formaladdr[MAXPARAMS][80];
int   formaltype[MAXPARAMS];

 /* store actual parameters in stack frame of subprogram to be CALLed */

 if (sym != lparen) { _error(14); return; }
 else
 {
  i=0;
  do
  {
   insymbol();
   formal_type=expr();

   /* check parameter types */
   if (formal_type != sub_ptr->p_type[i]) 
   {
    /* coerce actual parameter type to formal parameter type */
    switch(sub_ptr->p_type[i])
    {
     case shorttype: make_sure_short(formal_type);
		     break;

     case longtype: if ((formal_type = make_integer(formal_type)) == shorttype) 
		       make_long();
		    else 
                       if (formal_type == notype) _error(4); /* string */ 
		    break;

     case singletype : gen_Flt(formal_type);
		       break;

     case stringtype : _error(4);  /* can't coerce this at all! */
		       break;
    }
   }

   /* store parameter information temporarily since further stack operations  
      may corrupt data in next frame if stored immediately */
   if (sub_ptr->p_type[i] == shorttype)
   {
    par_addr -= 2; 
    /* save parameter type */
    formaltype[i]=shorttype; /* not data TYPE but STORE type (2 or 4 bytes) */

    /* save address of formal */
    itoa(par_addr,addrbuf,10);
    strcat(addrbuf,"(sp)");
    strcpy(formaladdr[i],addrbuf);

    /* create temporary store in current stack frame -> don't use a global
       data object as it could be clobbered during recursion! */
    addr[lev] += 2;
    itoa(-1*addr[lev],formaltemp[i],10);
    strcat(formaltemp[i],frame_ptr[lev]); 
    
    /* store it */
    gen("move.w","(sp)+",formaltemp[i]);
   }
   else
   /* long, single, string, array */   
   {
    par_addr -= 4; 
    /* save parameter type */
    formaltype[i]=longtype;  /* storage requirement is 4 bytes */

    /* save address of formal */
    itoa(par_addr,addrbuf,10);
    strcat(addrbuf,"(sp)");
    strcpy(formaladdr[i],addrbuf);

    /* create temporary store in current stack frame -> don't use a global
       data object as it could be clobbered during recursion! */
    addr[lev] += 4;
    itoa(-1*addr[lev],formaltemp[i],10);
    strcat(formaltemp[i],frame_ptr[lev]); 
    
    /* store it */
    gen("move.l","(sp)+",formaltemp[i]);
   }
   
   i++;
  }
  while ((i < sub_ptr->no_of_params) && (sym == comma));

  if ((i < sub_ptr->no_of_params) || (sym == comma)) 
     _error(39); /* parameter count mismatch - too few or too many resp. */
  else
  {
   /* disable multi-tasking 
      before passing parameters */
   gen("movea.l","_AbsExecBase","a6");
   gen("jsr","_LVOForbid(a6)","  ");
   enter_XREF("_AbsExecBase");
   enter_XREF("_LVOForbid");

   /* load parameters into next frame */
   for (n=0;n<sub_ptr->no_of_params;n++)
   {
    if (formaltype[n] == shorttype) 
       gen("move.w",formaltemp[n],formaladdr[n]); /* short */
    else
       gen("move.l",formaltemp[n],formaladdr[n]); /* long,string,single,array */
   }
  }

  if (sym != rparen) _error(9);
 }
}

void sub_params(sub_ptr)
SYM  *sub_ptr;
{
SHORT param_count=0;
int   param_type;
char  addrbuf[40];

 /* parse current SUB's formal parameter list */

 insymbol();
 if (sym != lparen) 
 {
  sub_ptr->no_of_params=0;
  return; /* no parameters -> return sym */
 }
 else
 {
  /* if actual parameters passed, Forbid() called -> Permit() */
  gen("movea.l","_AbsExecBase","a6");
  gen("jsr","_LVOPermit(a6)","  ");
  enter_XREF("_AbsExecBase");
  enter_XREF("_LVOPermit");

  /* formal parameters expected */
  do
  {
   param_type=undefined;

   insymbol();

   /* type identifiers */
   if (sym == shortintsym || sym == longintsym || sym == addresssym ||
       sym == singlesym || sym == stringsym)
   {
    switch(sym)
    {
     case shortintsym : param_type = shorttype;  break;
     case longintsym  : param_type = longtype;   break;
     case addresssym  : param_type = longtype;   break;
     case singlesym   : param_type = singletype; break;
     case stringsym   : param_type = stringtype; break;
    }
    insymbol();
   }

   if (sym != ident) _error(7);  /* ident expected */
   else
   {
    if (!exist(id,variable)) /* treat param's as local variables */
    {
       /* if type not already specified, take type indicated by ident */ 
       if (param_type == undefined) param_type = typ;

       /* enter parameter as a variable into symbol table */
       enter(id,param_type,variable,0);

       /* string parameter? -> associate with BSS object */
       if (curr_item->type == stringtype)  
       {
          itoa(-1*curr_item->address,addrbuf,10);
	  strcat(addrbuf,frame_ptr[ONE]);
	  gen("move.l",addrbuf,"-(sp)");  /* push value parameter */
          assign_to_string_variable(curr_item,MAXSTRLEN);
       }
    }
    else
       _error(38); /* duplicate parameter */
   }

   /* store parameter type */
   sub_ptr->p_type[param_count]=param_type;
   param_count++;

   insymbol();
  }
  while ((sym == comma) && (param_count < MAXPARAMS));
  
  sub_ptr->no_of_params=param_count;

  if (param_count == MAXPARAMS) _error(42);  /* too many */

  if (sym != rparen) _error(9);
  insymbol();
 }
}
 
void parse_shared_vars()
{
SYM  *zero_ptr,*one_ptr;
int  i;
char buf0[40],buf1[40],num[40];
BOOL share_it;

 /* get the SHARED list for current SUB and store details */

 do
 {
  share_it=FALSE;
  insymbol();
  if (sym != ident) _error(7);  /* identifier expected */
  else
  {
   lev=ZERO;
   if (exist(id,variable) || exist(id,structure)) 
   {
    share_it=TRUE;
    zero_ptr=curr_item;
    lev=ONE;
    enter(id,zero_ptr->type,zero_ptr->object,0);  /* variable or structure */	
    one_ptr=curr_item;
    /* add another 2 bytes to address if short */
    if (one_ptr->type == shorttype) 
    {
     addr[lev] += 2;
     one_ptr->address=addr[lev];
    }
    zero_ptr->shared=TRUE;
    one_ptr->shared=TRUE;
    if (one_ptr->type == stringtype)
	one_ptr->new_string_var=FALSE; /* don't want a new BSS object! */
    if (one_ptr->object == structure)
	one_ptr->other = zero_ptr->other; /* pointer to structdef SYM node */
   }
   else
   if (exist(id,array))
   {
    share_it=TRUE;
    zero_ptr=curr_item;
    lev=ONE;
    enter(id,zero_ptr->type,array,zero_ptr->dims);	
    one_ptr=curr_item;
    zero_ptr->shared=TRUE;
    one_ptr->shared=TRUE;
    /* copy array index values from level ZERO to ONE */
    for (i=0;i<=zero_ptr->dims;i++) one_ptr->index[i] = zero_ptr->index[i];
    /* get string array element size? */
    if (one_ptr->type == stringtype) 
       one_ptr->numconst.longnum = zero_ptr->numconst.longnum;
   }
   else { _error(40); lev=ONE; }

   if (share_it)
   {
    /* copy size information for SIZEOF? */
    if (one_ptr->type == stringtype || 
        one_ptr->object == array ||
        one_ptr->object == structure) one_ptr->size = zero_ptr->size;

    /* copy address of object from level ZERO to level ONE stack frame */
    
    /* frame location of level ONE object */ 
    itoa(-1*one_ptr->address,buf1,10);
    strcat(buf1,"(a5)");

    /* if simple numeric variable (short,long,single) or structure 
       -> get address */
    if ((zero_ptr->type != stringtype) && (zero_ptr->object != array))
    {
     strcpy(num,"#\0");
     itoa(zero_ptr->address,buf0,10);
     strcat(num,buf0);
     gen("move.l","a4","d0");  /* frame pointer */
     gen("sub.l",num,"d0");    /* offset from frame top */
     gen("move.l","d0",buf1);  /* store address in level ONE frame */
    }
    else
    {
     /* array or string -> level ZERO already contains address */
     itoa(-1*zero_ptr->address,buf0,10);
     strcat(buf0,"(a4)");
     gen("move.l",buf0,buf1);
    }
   }
  }

  insymbol();
 }
 while (sym == comma);
}
