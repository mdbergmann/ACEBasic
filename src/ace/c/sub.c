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

/* externals */
extern	int	sym;
extern	int	typ;
extern	int	lev;
extern	char   	id[MAXIDSIZE]; 
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	int  	addr[2];
extern	BOOL	module_opt;
extern	LONG	atomval;

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
     sym == singlesym || sym == stringsym || sym == atomsym)
 {
  sub_type = sym_to_type(sym);
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

   /* INVOKABLE SUB returns via d0 (for use with INVOKE/closures) */
   if (sym == invokablesym)
   {
	insymbol();
	sub_ptr->address = extfunc;
   }

   /* TASK SUB for Exec Task entry point (forward ref) */
   if (sym == taskprocsym)
   {
	insymbol();
	sub_ptr->is_task = TRUE;
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
        sym == singlesym || sym == stringsym || sym == atomsym)
    {
     param_type = sym_to_type(sym);
     insymbol();
    }
    else if (sym == ident && (exist(id, structdef) || exist(id, classdef)))
    {
     /* struct/class type identifier -> treat as ADDRESS */
     sub_ptr->p_structdef[param_count] = curr_item;
     param_type = longtype;
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

   /* INVOKABLE SUB returns via d0 (for use with INVOKE/closures) */
   if (sym == invokablesym)
   {
	insymbol();
	sub_ptr->address = extfunc;
   }

   /* TASK SUB for Exec Task entry point (forward ref) */
   if (sym == taskprocsym)
   {
	insymbol();
	sub_ptr->is_task = TRUE;
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

     case atomtype : _error(4);  /* atom type mismatch */
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
    gen_frame_addr(addr[lev],formaltemp[i]);
    
    /* store it */
    gen_pop(shorttype, formaltemp[i]);
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
    gen_frame_addr(addr[lev],formaltemp[i]);
    
    /* store it */
    gen_pop(longtype, formaltemp[i]);
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
    gen_move_typed(formaltype[n], formaltemp[n], formaladdr[n]);
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
SYM   *struct_param_def;

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
   struct_param_def=NULL;

   insymbol();

   /* type identifiers */
   if (sym == shortintsym || sym == longintsym || sym == addresssym ||
       sym == singlesym || sym == stringsym || sym == atomsym)
   {
    param_type = sym_to_type(sym);
    insymbol();
   }
   else if (sym == ident && (exist(id, structdef) || exist(id, classdef)))
   {
    /* struct/class type identifier -> treat as ADDRESS */
    struct_param_def = curr_item;
    param_type = longtype;
    insymbol();
   }

   if (sym != ident) _error(7);  /* ident expected */
   else
   {
    if (struct_param_def != NULL)
    {
       /* struct/class-typed parameter: enter as structure or classobj */
       if (exist(id, structure) || exist(id, classobj))
          _error(38); /* duplicate parameter */
       else
       {
          if (struct_param_def->object == classdef)
          {
             enter(id, notype, classobj, 0);
          }
          else
          {
             enter(id, notype, structure, 0);
          }
          curr_item->other = struct_param_def;
       }
    }
    else if (!exist(id,variable)) /* treat param's as local variables */
    {
       /* if type not already specified, take type indicated by ident */
       if (param_type == undefined) param_type = typ;

       /* enter parameter as a variable into symbol table */
       enter(id,param_type,variable,0);

       /* string parameter? -> associate with BSS object */
       if (curr_item->type == stringtype)
       {
          gen_frame_addr(curr_item->address,addrbuf);
	  gen("move.l",addrbuf,"-(sp)");  /* push value parameter */
          assign_to_string_variable(curr_item,MAXSTRLEN);
       }
    }
    else
       _error(38); /* duplicate parameter */
   }

   /* store parameter type and address */
   sub_ptr->p_type[param_count]=param_type;
   sub_ptr->p_addr[param_count]=curr_item->address;
   sub_ptr->p_structdef[param_count]=struct_param_def;
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
   if (exist(id,variable) || exist(id,structure) || exist(id,classobj))
   {
    share_it=TRUE;
    zero_ptr=curr_item;
    lev=ONE;
    enter(id,zero_ptr->type,zero_ptr->object,0);  /* variable, structure or classobj */
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
    if (one_ptr->object == structure || one_ptr->object == classobj)
	one_ptr->other = zero_ptr->other; /* pointer to structdef/classdef SYM node */
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
        one_ptr->object == structure ||
        one_ptr->object == classobj) one_ptr->size = zero_ptr->size;

    /* copy address of object from level ZERO to level ONE stack frame */

    /* frame location of level ONE object */
    itoa(-1*one_ptr->address,buf1,10);
    strcat(buf1,"(a5)");

    /*
    ** For module-level SHARED variables/arrays (address == -32767),
    ** use absolute BSS addressing instead of A4-relative.
    ** This fixes the bug where A4 is uninitialized in modules.
    */
    if (zero_ptr->address == -32767)
    {
     /* Module variable/array - use BSS address */
     if (zero_ptr->object == array)
     {
      /* Module array: use BSS pointer from libname */
      if (zero_ptr->libname != NULL)
      {
       /* Copy the BSS pointer value to level ONE frame.
       ** The level ONE symbol keeps its normal frame address so
       ** SUB code uses frame-relative access (a5-based) which is correct.
       */
       gen("move.l",zero_ptr->libname,buf1);
      }
      else
      {
       /* Fallback - should not happen */
       gen("move.l","#0",buf1);
      }
     }
     else
     {
      /* Module simple variable: get absolute BSS address */
      char bss_name[MAXIDSIZE+8];

      strcpy(bss_name,"#");
      make_modvar_bss_name(bss_name+1, zero_ptr->name);
      gen("move.l",bss_name,buf1);  /* store BSS address in level ONE frame */
     }
    }
    else
    {
     /* Normal frame-relative addressing using A4 */
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
  }

  insymbol();
 }
 while (sym == comma);
}

void method_scan_params(sub_ptr, param_names, class_names, class_count)
SYM  *sub_ptr;
char param_names[MAXPARAMS][MAXIDSIZE];
char class_names[MAXPARAMS][MAXIDSIZE];
SHORT *class_count;
{
SHORT param_count=0;
int   param_type;
SYM   *struct_param_def;

 /* Parse METHOD's formal parameter list (Phase A: scan & collect).
    Records param types, names, and class names for label construction.
    Does NOT emit code or enter params into level-1 symbol table. */

 *class_count = 0;

 insymbol();
 if (sym != lparen)
 {
  sub_ptr->no_of_params=0;
  return;
 }

 /* formal parameters expected */
 do
 {
  param_type=undefined;
  struct_param_def=NULL;

  insymbol();

  /* type identifiers */
  if (sym == shortintsym || sym == longintsym || sym == addresssym ||
      sym == singlesym || sym == stringsym || sym == atomsym)
  {
   param_type = sym_to_type(sym);
   insymbol();
  }
  else if (sym == ident && (exist(id, structdef) || exist(id, classdef)))
  {
   /* struct/class type identifier -> treat as ADDRESS */
   struct_param_def = curr_item;
   param_type = longtype;
   /* collect class name for label construction */
   if (struct_param_def->object == classdef)
   {
    strcpy(class_names[*class_count], struct_param_def->name);
    (*class_count)++;
   }
   insymbol();
  }
  else if (sym == atomconst)
  {
   /* atom literal specializer like #:ok in METHOD Handle(#:ok result) */
   param_type = longtype;
   struct_param_def = (SYM *)2;  /* ATOM sentinel */
   sprintf(class_names[*class_count], "%lX", (unsigned long)atomval);
   (*class_count)++;
   insymbol();
  }

  if (sym != ident) _error(7);  /* ident expected */
  else
     strcpy(param_names[param_count], id);

  /* store parameter type, address placeholder, and structdef */
  sub_ptr->p_type[param_count]=param_type;
  sub_ptr->p_addr[param_count]=0;  /* filled in by method_enter_params */
  sub_ptr->p_structdef[param_count]=struct_param_def;
  param_count++;

  insymbol();
 }
 while ((sym == comma) && (param_count < MAXPARAMS));

 sub_ptr->no_of_params=param_count;

 if (param_count == MAXPARAMS) _error(42);  /* too many */

 if (sym != rparen) _error(9);
 insymbol();
}

void method_enter_params(sub_ptr, param_names)
SYM  *sub_ptr;
char param_names[MAXPARAMS][MAXIDSIZE];
{
SHORT n;
char  addrbuf[40];
SYM   *struct_param_def;
int   param_type;

 /* Phase B: emit code for METHOD parameters.
    Enters each param into level-1 symbol table and generates setup code.
    Called AFTER the method label and link instruction have been emitted. */

 if (sub_ptr->no_of_params == 0) return;

 /* if actual parameters passed, Forbid() called -> Permit() */
 gen("movea.l","_AbsExecBase","a6");
 gen("jsr","_LVOPermit(a6)","  ");
 enter_XREF("_AbsExecBase");
 enter_XREF("_LVOPermit");

 for (n=0; n < sub_ptr->no_of_params; n++)
 {
  struct_param_def = sub_ptr->p_structdef[n];
  param_type = sub_ptr->p_type[n];

  /* For ATOM-specialized params (sentinel (SYM *)2) */
  if (struct_param_def == (SYM *)2)
  {
   if (!exist(param_names[n], variable))
      enter(param_names[n], longtype, variable, 0);
   else
      _error(38); /* duplicate parameter */
  }
  /* For struct/class-typed params */
  else if (struct_param_def != NULL)
  {
   if (exist(param_names[n], structure) || exist(param_names[n], classobj))
      _error(38); /* duplicate parameter */
   else
   {
    if (struct_param_def->object == classdef)
    {
     enter(param_names[n], notype, classobj, 0);
    }
    else
    {
     enter(param_names[n], notype, structure, 0);
    }
    curr_item->other = struct_param_def;
   }
  }
  else
  {
   /* ordinary typed parameter */
   if (!exist(param_names[n], variable))
   {
    if (param_type == undefined) param_type = notype;
    enter(param_names[n], param_type, variable, 0);

    /* string parameter? -> associate with BSS object */
    if (curr_item->type == stringtype)
    {
     gen_frame_addr(curr_item->address,addrbuf);
     gen("move.l",addrbuf,"-(sp)");
     assign_to_string_variable(curr_item,MAXSTRLEN);
    }
   }
   else
      _error(38); /* duplicate parameter */
  }

  /* update the stored address for call-site matching */
  sub_ptr->p_addr[n] = curr_item->address;
 }
}

void call_generic_method(gm_sym)
SYM *gm_sym;
{
SHORT par_addr=-8;
SHORT i,n;
int   formal_type;
char  addrbuf[40];
char  formaltemp[MAXPARAMS][80],formaladdr[MAXPARAMS][80];
int   formaltype[MAXPARAMS];
char  gmeth_label[200];
int   dispatch_count;

 /* Parse and evaluate all arguments, storing in caller frame temps.
    Then push dispatch hash values, call _gm_dispatch to resolve
    the method, and invoke it with the evaluated arguments. */

 if (sym != lparen) { _error(14); return; }

 i=0;
 do
 {
  insymbol();
  formal_type=expr();

  /* check parameter types and coerce */
  if (formal_type != gm_sym->p_type[i])
  {
   switch(gm_sym->p_type[i])
   {
    case shorttype: make_sure_short(formal_type);
		    break;

    case longtype: if ((formal_type = make_integer(formal_type)) == shorttype)
		      make_long();
		   else
		      if (formal_type == notype) _error(4);
		   break;

    case singletype : gen_Flt(formal_type);
		      break;

    case stringtype : _error(4);
		      break;

    case atomtype : _error(4);
		    break;
   }
  }

  /* store parameter in temp (same pattern as load_params) */
  if (gm_sym->p_type[i] == shorttype)
  {
   par_addr -= 2;
   formaltype[i]=shorttype;

   itoa(par_addr,addrbuf,10);
   strcat(addrbuf,"(sp)");
   strcpy(formaladdr[i],addrbuf);

   addr[lev] += 2;
   gen_frame_addr(addr[lev],formaltemp[i]);
   gen_pop(shorttype, formaltemp[i]);
  }
  else
  {
   par_addr -= 4;
   formaltype[i]=longtype;

   itoa(par_addr,addrbuf,10);
   strcat(addrbuf,"(sp)");
   strcpy(formaladdr[i],addrbuf);

   addr[lev] += 4;
   gen_frame_addr(addr[lev],formaltemp[i]);
   gen_pop(longtype, formaltemp[i]);
  }

  i++;
 }
 while ((i < gm_sym->no_of_params) && (sym == comma));

 if ((i < gm_sym->no_of_params) || (sym == comma))
    _error(39); /* parameter count mismatch */

 if (sym != rparen) _error(9);

 /* count dispatched positions */
 dispatch_count = 0;
 for (i=0; i < gm_sym->no_of_params; i++)
 {
  if (gm_sym->p_structdef[i] == (SYM *)1 ||
      gm_sym->p_structdef[i] == (SYM *)2)
     dispatch_count++;
 }

 /* push dispatch hash values onto stack (reverse order so first
    dispatched position ends up closest to sp after all pushes) */
 for (i = gm_sym->no_of_params - 1; i >= 0; i--)
 {
  if (gm_sym->p_structdef[i] == (SYM *)1)
  {
   /* CLASS dispatch: read type ID from offset 0 of class instance */
   gen("movea.l", formaltemp[i], "a0");
   gen("move.l", "(a0)", "-(sp)");
  }
  else if (gm_sym->p_structdef[i] == (SYM *)2)
  {
   /* ATOM dispatch: value IS the hash */
   gen("move.l", formaltemp[i], "-(sp)");
  }
 }

 /* call dispatcher: lea _GMETH_<name>, a0 / jsr _gm_dispatch */
 strcpy(gmeth_label, "_GMETH_");
 strcat(gmeth_label, gm_sym->name);
 gen("lea", gmeth_label, "a0");
 gen("jsr", "_gm_dispatch", "  ");
 enter_XREF(gmeth_label);
 enter_XREF("_gm_dispatch");

 /* clean dispatch values from stack */
 if (dispatch_count > 0)
    gen_stack_cleanup(dispatch_count * 4);

 /* save resolved method address */
 gen("movea.l", "a0", "a2");

 /* Forbid before writing to callee frame */
 gen("movea.l","_AbsExecBase","a6");
 gen("jsr","_LVOForbid(a6)","  ");
 enter_XREF("_AbsExecBase");
 enter_XREF("_LVOForbid");

 /* move params from temps to callee frame */
 for (n=0; n < gm_sym->no_of_params; n++)
 {
  gen_move_typed(formaltype[n], formaltemp[n], formaladdr[n]);
 }

 /* call the resolved method */
 gen("jsr", "(a2)", "  ");
}
