/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: main module **
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
	   6th,7th,21st,22nd December 1992,
	   13th,30th January 1993,
	   2nd,6th,11th,14th,15th,28th February 1993,
	   7th,24th March 1993,
	   6th,13th,14th,30th June 1993,
	   1st,10th July 1993,
	   5th,26th September 1993,
	   25th October 1993,
	   15th-18th November 1993,
	   26th,27th December 1993,
	   2nd,5th,7th,9th,13th,14th January 1994,
	   7th,26th,27th February 1994,
	   4th,13th,30th April 1994,
	   14th May 1994,
	   12th,14th,21st,22nd,25th June 1994,
	   10th,14th,24th July 1994,
	   14th,19th August 1994,
	   11th,12th September 1994,
	   5th,11th March 1995,
	   8th August 1995,
	   6th October 1995,
	   10th March 1996
*/

#include "acedef.h"

/* externals */
extern	char	*srcfile,*destfile;
extern	int	sym;
extern	int	typ;
extern	int	lev;
extern	int	errors;
extern	char   	id[MAXIDSIZE]; 
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	BOOL	end_of_source;
extern	FILE	*dest;
extern	int  	addr[2]; 
extern	char 	exit_sub_name[80];
extern	BOOL 	early_exit;
extern	int  	exitvalue;
extern	char	*rword[];
extern	BOOL 	break_opt;
extern	BOOL	optimise_opt;
extern	BOOL	make_icon;
extern	BOOL	error_log;
extern	BOOL	asm_comments;
extern	BOOL	list_source;
extern	BOOL 	wdw_close_opt;
extern	BOOL 	module_opt;
extern	BOOL	cpu020_opt;
extern	BOOL	trace_opt;
extern	int	tracename_count;
extern	BOOL	cli_args;
extern	BOOL 	mathfloatused;
extern	BOOL 	mathtransused;
extern	BOOL 	gfxused;
extern	BOOL 	intuitionused;
extern	BOOL 	translateused;
extern	BOOL	ontimerused;
extern	BOOL	gadtoolsused;
extern	BOOL 	basdatapresent;
extern	BOOL 	readpresent;
extern	LONG	atomval;

/* external functions */
char	*version();

/* functions */
void method_block()
{
CODE *link;
SYM  *sub_ptr;
char method_generic_name[MAXIDSIZE];
char method_label[200], method_label_colon[200];
char exit_label[210], exit_label_colon[210];
char end_of_method_name[80], end_of_method_label[80];
char xdef_name[200];
char bytes[40], buf[40];
int  sub_type;
SHORT class_count;
char class_names[MAXPARAMS][MAXIDSIZE];
char param_names[MAXPARAMS][MAXIDSIZE];
int  i;
char saved_trace_label[40];

 /* consume METHOD keyword (already current sym) */
 insymbol();

 sub_type = undefined;

 /* optional return type */
 if (sym == shortintsym || sym == longintsym || sym == addresssym ||
     sym == singlesym || sym == stringsym)
 {
  sub_type = sym_to_type(sym);
  insymbol();
 }

 if (sym != ident) { _error(7); return; }

 /* save the generic name (e.g. "Draw") */
 strcpy(method_generic_name, id);

 /* prepare end-of-method jump label */
 make_label(end_of_method_name, end_of_method_label);
 gen("jmp", end_of_method_name, "  ");

 /* Phase A: scan parameters at level ZERO, collect class names and param names.
    We stay at level ZERO so exist() finds class/struct defs and so the
    method SYM is entered at level ZERO (like regular SUBs). */
 {
  SYM temp_sub;
  temp_sub.no_of_params = 0;

  method_scan_params(&temp_sub, param_names, class_names, &class_count);

  /* METHOD must have at least one CLASS-typed parameter */
  if (class_count == 0) _error(91);

  /* Construct method label: _METH_Draw_Circle[_Box] */
  strcpy(method_label, "_METH_");
  strcat(method_label, method_generic_name);
  for (i=0; i < class_count; i++)
  {
   strcat(method_label, "_");
   strcat(method_label, class_names[i]);
  }

  /* Construct exit label: _EXIT_METH_Draw_Circle */
  strcpy(exit_label, "_EXIT");
  strcat(exit_label, method_label);

  /* Create SYM entry for this method at level ZERO (like SUBs) */
  if (sub_type == undefined) sub_type = notype;
  enter(method_label, sub_type, subprogram, 0);
  curr_item->decl = subdecl;
  sub_ptr = curr_item;

  /* Copy param info from temp to real SYM */
  sub_ptr->no_of_params = temp_sub.no_of_params;
  for (i=0; i < temp_sub.no_of_params; i++)
  {
   sub_ptr->p_type[i] = temp_sub.p_type[i];
   sub_ptr->p_addr[i] = temp_sub.p_addr[i];
   sub_ptr->p_structdef[i] = temp_sub.p_structdef[i];
  }
 }

 /* Now switch to level ONE for the method body */
 lev=ONE;
 addr[lev]=0;
 new_symtab();

 /* Make method externally visible (always XDEF) */
 strcpy(xdef_name, method_label);
 xdef_name[0] = '*';  /* signal XDEF */
 enter_XREF(xdef_name);

 /* Emit method label */
 strcpy(method_label_colon, method_label);
 strcat(method_label_colon, ":\0");
 gen(method_label_colon, "  ", "  ");

 /* link instruction -- # of bytes patched later */
 gen("link", "a5", "  ");
 link = curr_code;

 /* Phase B: enter params into level-1 symbol table, emit Permit & setup code */
 method_enter_params(sub_ptr, param_names);

 /* Set exit_sub_name so EXIT METHOD works via existing mechanism */
 strcpy(exit_sub_name, exit_label);

 /* Methods always return via d0 (needed for generic dispatch) */
 sub_ptr->address = extfunc;

 /* -- Trace: METHOD entry -- */
 saved_trace_label[0] = '\0';
 if (trace_opt)
 {
  char trace_label[80], trace_data[200];
  char addrbuf[40];
  int pi;

  /* Create string constant with METHOD name (without _METH_ prefix) */
  sprintf(trace_label, "_tn%d:", tracename_count);
  sprintf(trace_data, "dc.b \"%s\",0", method_label+6);
  enter_DATA(trace_label, trace_data);

  /* Save label reference for exit code */
  sprintf(saved_trace_label, "_tn%d", tracename_count);
  tracename_count++;

  /* Call _trace_enter(name_ptr) - name in a0 */
  gen("lea", saved_trace_label, "a0");
  gen("jsr", "_trace_enter", "  ");
  enter_XREF("_trace_enter");

  /* Emit each parameter value */
  for (pi = 0; pi < sub_ptr->no_of_params; pi++)
  {
   if (pi > 0)
   {
    gen("jsr", "_trace_param_sep", "  ");
    enter_XREF("_trace_param_sep");
   }

   gen_frame_addr(sub_ptr->p_addr[pi], addrbuf);

   switch (sub_ptr->p_type[pi])
   {
    case shorttype:
     gen("move.w", addrbuf, "d0");
     gen("jsr", "_trace_param_short", "  ");
     enter_XREF("_trace_param_short");
     break;
    case longtype:
     gen("move.l", addrbuf, "d0");
     gen("jsr", "_trace_param_long", "  ");
     enter_XREF("_trace_param_long");
     break;
    case singletype:
     gen("move.l", addrbuf, "d0");
     gen("jsr", "_trace_param_single", "  ");
     enter_XREF("_trace_param_single");
     break;
    case stringtype:
     gen("move.l", addrbuf, "a0");
     gen("jsr", "_trace_param_str", "  ");
     enter_XREF("_trace_param_str");
     break;
   }
  }

  gen("jsr", "_trace_end_params", "  ");
  enter_XREF("_trace_end_params");
 }

 /* Parse method body */
 while ((sym != endsym) && (!end_of_source))
 {
  if (sym == sharedsym) parse_shared_vars();
  if ((sym != endsym) && (!end_of_source)) statement();
 }

 if (end_of_source) _error(90);  /* METHOD without END METHOD */

 if (sym == endsym)
 {
  insymbol();
  if (sym != methodsym) _error(90);  /* expected METHOD after END */
  insymbol();
 }

 /* Establish size of stack frame */
 if (addr[lev] == 0)
  strcpy(bytes, "#\0");
 else
  strcpy(bytes, "#-");
 itoa(addr[lev], buf, 10);
 strcat(bytes, buf);
 change(link, "link", "a5", bytes);

 /* Exit code */
 strcpy(exit_label_colon, exit_label);
 strcat(exit_label_colon, ":\0");
 gen(exit_label_colon, "  ", "  ");

 /* -- Trace: METHOD exit -- */
 if (trace_opt && saved_trace_label[0] != '\0')
 {
  gen("lea", saved_trace_label, "a0");

  if (sub_type == notype)
  {
   gen("jsr", "_trace_exit_void", "  ");
   enter_XREF("_trace_exit_void");
  }
  else
  {
   /* METHOD returns via d0 (address == extfunc) */
   gen("jsr", "_trace_exit_long", "  ");
   enter_XREF("_trace_exit_long");
  }
 }

 gen("unlk", "a5", "  ");
 gen("rts", "  ", "  ");
 gen(end_of_method_label, "  ", "  ");

 kill_symtab();
 lev=ZERO;
}

void generic_block()
{
SYM  *gm_sym;
char generic_name[MAXIDSIZE];
char gmeth_label[200], gmeth_label_colon[200];
char xdef_name[200];
char end_of_generic_name[80], end_of_generic_label[80];
int  return_type;
int  param_count, dispatch_count;
int  p_types[MAXPARAMS];
int  p_dispatch[MAXPARAMS];  /* 0=CLASS, 1=ATOM, -1=regular */
int  dispatch_positions[MAX_DISPATCH_POS];
int  on_count;
LONG on_hashes[MAX_ON_ENTRIES][MAX_DISPATCH_POS];
char on_labels[MAX_ON_ENTRIES][200];
char xref_labels[MAX_ON_ENTRIES][200];
char buf[80];
int  i, j;

 /* consume GENERIC (already current sym) */
 insymbol();

 return_type = notype;

 /* optional return type */
 if (sym == shortintsym || sym == longintsym || sym == addresssym ||
     sym == singlesym || sym == stringsym)
 {
  return_type = sym_to_type(sym);
  insymbol();
 }

 /* expect METHOD */
 if (sym != methodsym) { _error(92); return; }
 insymbol();

 /* expect identifier (generic name) */
 if (sym != ident) { _error(7); return; }
 strcpy(generic_name, id);

 /* jump-around label to skip dispatch table data */
 make_label(end_of_generic_name, end_of_generic_label);
 gen("jmp", end_of_generic_name, "  ");

 insymbol();

 /* expect '(' */
 if (sym != lparen) { _error(14); return; }

 /* parse type signature */
 param_count = 0;
 dispatch_count = 0;

 do
 {
  insymbol();

  if (sym == classsym)
  {
   p_types[param_count] = longtype;
   p_dispatch[param_count] = 0;  /* CLASS dispatch */
   dispatch_positions[dispatch_count] = param_count;
   dispatch_count++;
  }
  else if (sym == atomsym)
  {
   p_types[param_count] = atomtype;
   p_dispatch[param_count] = 1;  /* ATOM dispatch */
   dispatch_positions[dispatch_count] = param_count;
   dispatch_count++;
  }
  else if (sym == longintsym || sym == addresssym)
  {
   p_types[param_count] = longtype;
   p_dispatch[param_count] = -1;
  }
  else if (sym == shortintsym)
  {
   p_types[param_count] = shorttype;
   p_dispatch[param_count] = -1;
  }
  else if (sym == singlesym)
  {
   p_types[param_count] = singletype;
   p_dispatch[param_count] = -1;
  }
  else if (sym == stringsym)
  {
   p_types[param_count] = stringtype;
   p_dispatch[param_count] = -1;
  }
  else
  {
   _error(60);  /* Identifier or Type expected */
   return;
  }

  param_count++;
  insymbol();
 }
 while (sym == comma && param_count < MAXPARAMS);

 if (sym != rparen) { _error(9); return; }
 insymbol();

 /* create genericmethod SYM at level ZERO */
 enter(generic_name, return_type, genericmethod, 0);
 gm_sym = curr_item;
 gm_sym->no_of_params = param_count;
 for (i = 0; i < param_count; i++)
 {
  gm_sym->p_type[i] = p_types[i];
  /* sentinel values in p_structdef to mark dispatch positions */
  if (p_dispatch[i] == 0)
   gm_sym->p_structdef[i] = (SYM *)1;  /* CLASS dispatch */
  else if (p_dispatch[i] == 1)
   gm_sym->p_structdef[i] = (SYM *)2;  /* ATOM dispatch */
  else
   gm_sym->p_structdef[i] = NULL;       /* regular param */
 }

 /* parse ON clauses */
 on_count = 0;

 /* skip end-of-line tokens between ) and first ON */
 while (sym == endofline && !end_of_source) insymbol();

 while (sym == onsym && on_count < MAX_ON_ENTRIES)
 {
  /* for each dispatched position, get the type name/atom */
  for (j = 0; j < dispatch_count; j++)
  {
   insymbol();

   if (p_dispatch[dispatch_positions[j]] == 0)
   {
    /* CLASS dispatch: expect class name identifier */
    if (sym != ident) { _error(7); return; }
    if (!exist(id, classdef)) { _error(87); return; }
    on_hashes[on_count][j] = curr_item->numconst.longnum;

    /* build method label fragment */
    if (j == 0)
    {
     strcpy(on_labels[on_count], "_METH_");
     strcat(on_labels[on_count], generic_name);
    }
    strcat(on_labels[on_count], "_");
    strcat(on_labels[on_count], id);  /* id is already uppercase */
   }
   else
   {
    /* ATOM dispatch: expect atom literal `name */
    if (sym != atomconst) { _error(60); return; }
    on_hashes[on_count][j] = atomval;

    if (j == 0)
    {
     strcpy(on_labels[on_count], "_METH_");
     strcat(on_labels[on_count], generic_name);
    }
    /* reconstruct atom name from the id - need to re-scan */
    /* atomval already has the hash, we need the name for the label */
    /* Unfortunately atom literal doesn't give us the name back easily */
    /* So we must get it from the source - but the lexer already consumed it */
    /* The atom name was stored uppercased in the hash, but we need the text */
    /* We'll use a workaround: scan backwards to find the atom name */
    /* Actually, let's just use the hash as a hex label suffix */
    sprintf(buf, "_%lX", (unsigned long)atomval);
    strcat(on_labels[on_count], buf);
   }

   insymbol();

   /* expect comma between dispatched types (but not after last) */
   if (j < dispatch_count - 1)
   {
    if (sym != comma) { _error(96); return; }
   }
  }

  /* save XREF label (without colon or XDEF prefix) */
  strcpy(xref_labels[on_count], on_labels[on_count]);
  on_count++;

  /* skip end-of-line tokens between ON clauses */
  while (sym == endofline && !end_of_source) insymbol();
 }

 if (on_count >= MAX_ON_ENTRIES) _error(95);

 /* expect END GENERIC */
 if (sym != endsym) { _error(94); return; }
 insymbol();
 if (sym != genericsym) { _error(94); return; }
 insymbol();

 /* emit dispatch table */

 /* XDEF for _GMETH_<Name> */
 strcpy(gmeth_label, "_GMETH_");
 strcat(gmeth_label, generic_name);
 strcpy(xdef_name, gmeth_label);
 xdef_name[0] = '*';  /* signal XDEF */
 enter_XREF(xdef_name);

 /* label */
 strcpy(gmeth_label_colon, gmeth_label);
 strcat(gmeth_label_colon, ":");
 gen(gmeth_label_colon, "  ", "  ");

 /* dc.w N  (number of dispatched positions) */
 sprintf(buf, "%d", dispatch_count);
 gen("dc.w", buf, "  ");

 /* dc.w M  (number of ON entries) */
 sprintf(buf, "%d", on_count);
 gen("dc.w", buf, "  ");

 /* dc.w pos0, pos1, ...  (position indices, bit 15 set for ATOM) */
 for (i = 0; i < dispatch_count; i++)
 {
  int pos = dispatch_positions[i];
  if (p_dispatch[pos] == 1)
   sprintf(buf, "$%x", 0x8000 | pos);  /* ATOM: bit 15 set */
  else
   sprintf(buf, "%d", pos);             /* CLASS */
  gen("dc.w", buf, "  ");
 }

 /* ON entries: N hashes + method address */
 for (i = 0; i < on_count; i++)
 {
  /* emit hashes for each dispatched position */
  for (j = 0; j < dispatch_count; j++)
  {
   sprintf(buf, "$%lx", (unsigned long)on_hashes[i][j]);
   gen("dc.l", buf, "  ");
  }
  /* emit method address (relocation — vasm resolves at link time) */
  gen("dc.l", on_labels[i], "  ");
 }

 /* XREF for each method label */
 for (i = 0; i < on_count; i++)
 {
  enter_XREF(xref_labels[i]);
 }

 /* landing label for jump-around */
 gen(end_of_generic_label, "  ", "  ");
}

void block()
{
CODE *link;
CODE *sub_label_code;
SYM  *sub_ptr;
char end_of_sub_name[80],end_of_sub_label[80];
char sub_name[80],sub_label[80],exit_sub_label[80];
char xdef_name[80];
char bytes[40],buf[40];
int  subprog;
int  sub_type,def_expr_type;
BOOL sub_is_void;
char saved_trace_label[40];

 while (!end_of_source)
 {
  if (sym == genericsym)
  {
   /* GENERIC METHOD declaration with dispatch table */
   generic_block();
  }
  else if (sym == methodsym)
  {
   /* METHOD definition */
   method_block();
  }
  else if (sym != subsym && sym != defsym)
   /* ordinary statement */
   statement();
  else
  {
   /************************/
   /* SUBprogram or DEF FN */
   /************************/
   subprog = sym;
   insymbol();
   
   sub_type = undefined;

   /* type identifiers */
   if (sym == shortintsym || sym == longintsym || sym == addresssym ||
       sym == singlesym || sym == stringsym)
   {
    sub_type = sym_to_type(sym);
    insymbol();
   }

   if (sym != ident) _error(32);
   else
   { 
    /* get name of subprogram and prefix _SUB_ to it */
    strcpy(sub_name,"_SUB_");
    strcat(sub_name,id);

    sub_is_void = (sub_type == undefined);

    if (!exist(sub_name,subprogram))
    {
      if (sub_type == undefined) sub_type = typ;
      enter(sub_name,sub_type,subprogram,0);  /* new SUB */
      curr_item->decl=subdecl;
    }
    else
       if ((exist(sub_name,subprogram)) && (curr_item->decl == fwdref))
          curr_item->decl=subdecl;
       else 
           _error(33); /* already exists */

    sub_ptr=curr_item; /* pointer to sub info' */
    sub_ptr->is_callback = FALSE;  /* initialize callback flag */

    turn_event_off(sub_name);   /* see event.c */

    /* exit point name & label */
    strcpy(exit_sub_name,"_EXIT");
    strcat(exit_sub_name,sub_name);
    strcpy(exit_sub_label,exit_sub_name);
    strcat(exit_sub_label,":\0");

    /* prepare for level ONE */
    lev=ONE; 
    addr[lev]=0; 
    new_symtab();
    make_label(end_of_sub_name,end_of_sub_label);
    gen("jmp",end_of_sub_name,"  ");

    /* subprogram label -> _SUB_ prefix to make it unique */
    strcpy(sub_label,sub_name);
    strcat(sub_label,":\0");
    gen(sub_label,"  ","  ");
    sub_label_code = curr_code;  /* save for CALLBACK entry code insertion */

    /* all SUBs need link instruction -- add # of bytes later */
    gen("link","a5","  ");
    link=curr_code;

    /* parse formal parameter list */
    sub_params(sub_ptr);

    /* make this subprogram externally visible? */
    if (sym == externalsym)
    {
	insymbol();
	strcpy(xdef_name,sub_name);
	xdef_name[0] = '*';  /* signal that this is an XDEF */
	enter_XREF(xdef_name);
    }

    /* CALLBACK SUB for Amiga Hook convention? */
    if (sym == callbacksym)
    {
	insymbol();
	sub_ptr->is_callback = TRUE;

	/* Validate: must have exactly 3 ADDRESS (long) parameters */
	if (sub_ptr->no_of_params != 3 ||
	    sub_ptr->p_type[0] != longtype ||
	    sub_ptr->p_type[1] != longtype ||
	    sub_ptr->p_type[2] != longtype)
	{
	    _error(84);  /* CALLBACK SUB must have exactly 3 ADDRESS parameters */
	}

	/* CALLBACK SUBs return via D0, like external functions */
	sub_ptr->address = extfunc;

	/* Force CALLBACK SUBs to return LONGINT (not float) */
	sub_ptr->type = longtype;

	/* Make externally visible (for Hook.h_Entry) */
	strcpy(xdef_name,sub_name);
	xdef_name[0] = '*';  /* signal that this is an XDEF */
	enter_XREF(xdef_name);

	/* Generate CALLBACK entry code */
	{
	    CODE *movem_code;

	    /* Insert movem.l BEFORE link instruction to save registers */
	    movem_code = (CODE *)alloc_code("movem.l","d1-d7/a0-a6","-(sp)");
	    if (movem_code != NULL)
	    {
		strcpy(movem_code->opcode, "movem.l");
		strcpy(movem_code->srcopr, "d1-d7/a0-a6");
		strcpy(movem_code->destopr, "-(sp)");
		movem_code->next = link;
		sub_label_code->next = movem_code;
	    }

	    /* NOP out Permit code generated by sub_params (not needed for CALLBACK) */
	    /* sub_params generates: movea.l _AbsExecBase,a6 then jsr _LVOPermit(a6) */
	    if (link->next != NULL)
	    {
		change(link->next, "nop", "  ", "  ");
		if (link->next->next != NULL)
		    change(link->next->next, "nop", "  ", "  ");
	    }

	    /* Copy register parameters to local frame AFTER link */
	    /* Note: Hook convention uses A0, A2, A1 (not A0, A1, A2!) */
	    gen("move.l","a0","-4(a5)");   /* param 1: hook from A0 */
	    gen("move.l","a2","-8(a5)");   /* param 2: object from A2 */
	    gen("move.l","a1","-12(a5)"); /* param 3: message from A1 */
	}
    }

    /* INVOKABLE SUB returns via d0 (for use with INVOKE/closures) */
    if (sym == invokablesym)
    {
	insymbol();
	sub_ptr->address = extfunc;
    }

    /*
    ** Pass function (SUB) values via d0 for ALL subprograms
    ** in a module since there is no link using A4 for modules.
    */
    if (module_opt)
	sub_ptr->address = extfunc;  /* This has a numeric value of 3004:
					hopefully large enough to avoid
					clashes with real stack offsets. */

    /* -- Trace: SUB entry -- */
    saved_trace_label[0] = '\0';
    if (trace_opt && !sub_ptr->is_callback && subprog == subsym)
    {
	char trace_label[80], trace_data[200];
	char addrbuf[40];
	int pi;

	/* Create string constant with SUB name (without _SUB_ prefix) */
	sprintf(trace_label, "_tn%d:", tracename_count);
	sprintf(trace_data, "dc.b \"%s\",0", sub_name+5);
	enter_DATA(trace_label, trace_data);

	/* Save label reference for exit code */
	sprintf(saved_trace_label, "_tn%d", tracename_count);
	tracename_count++;

	/* Call _trace_enter(name_ptr) - name in a0 */
	/* Trace functions save/restore all registers internally */
	gen("lea", saved_trace_label, "a0");
	gen("jsr", "_trace_enter", "  ");
	enter_XREF("_trace_enter");

	/* Emit each parameter value */
	for (pi = 0; pi < sub_ptr->no_of_params; pi++)
	{
	    if (pi > 0)
	    {
		gen("jsr", "_trace_param_sep", "  ");
		enter_XREF("_trace_param_sep");
	    }

	    gen_frame_addr(sub_ptr->p_addr[pi], addrbuf);

	    switch (sub_ptr->p_type[pi])
	    {
		case shorttype:
		    gen("move.w", addrbuf, "d0");
		    gen("jsr", "_trace_param_short", "  ");
		    enter_XREF("_trace_param_short");
		    break;
		case longtype:
		    gen("move.l", addrbuf, "d0");
		    gen("jsr", "_trace_param_long", "  ");
		    enter_XREF("_trace_param_long");
		    break;
		case singletype:
		    gen("move.l", addrbuf, "d0");
		    gen("jsr", "_trace_param_single", "  ");
		    enter_XREF("_trace_param_single");
		    break;
		case stringtype:
		    gen("move.l", addrbuf, "a0");
		    gen("jsr", "_trace_param_str", "  ");
		    enter_XREF("_trace_param_str");
		    break;
	    }
	}

	gen("jsr", "_trace_end_params", "  ");
	enter_XREF("_trace_end_params");
    }

    /* SUB or DEF FN code? */
    if (subprog == subsym)
    {
      /* emit TCO re-entry label for eligible SUBs */
      if (sub_ptr->address != extfunc)
      {
	BOOL tco_ok = TRUE;
	int pi;
	for (pi = 0; pi < sub_ptr->no_of_params; pi++)
	{
	  if (sub_ptr->p_type[pi] == stringtype)
	  {
	    tco_ok = FALSE;
	    break;
	  }
	}
	if (tco_ok)
	{
	  char tcr_label[80];
	  strcpy(tcr_label, sub_name);
	  strcat(tcr_label, "_tcr:");
	  gen(tcr_label, "  ", "  ");
	}
      }

      while ((sym != endsym) && (!end_of_source)) 
      {
       if (sym == sharedsym) parse_shared_vars();
       if ((sym != endsym) && (!end_of_source)) statement();
      }

      if (end_of_source) _error(34);  /* END SUB expected */

      if (sym == endsym) 
      {
       insymbol();
       if (sym != subsym) _error(35); 
       insymbol(); 
      }
    }
    else
    {
        /* DEF FN code */
	if (sym != equal)
	   _error(5);
	else
	{
	  insymbol();
     	  def_expr_type = expr();
	  if (assign_coerce(sub_type,def_expr_type) != sub_type)
	     _error(4);
	  else
	  if (sub_type == shorttype)
	  	gen("move.w","(sp)+","d0");
	  else
		gen("move.l","(sp)+","d0");

  	  /* change object from SUB to DEF FN */
	  sub_ptr->object = definedfunc;
	}
    }

    /* establish size of stack frame */
    if (addr[lev] == 0)
       strcpy(bytes,"#\0");
    else
       strcpy(bytes,"#-");     
    itoa(addr[lev],buf,10);   
    strcat(bytes,buf);   
    change(link,"link","a5",bytes);  

    /* exit code */
    if (subprog == subsym) gen(exit_sub_label,"  ","  ");

    /* -- Trace: SUB exit -- */
    if (trace_opt && !sub_ptr->is_callback && subprog == subsym
	&& saved_trace_label[0] != '\0')
    {
	char addrbuf[40];

	/* Trace functions save/restore all registers internally */
	gen("lea", saved_trace_label, "a0");

	if (sub_is_void)
	{
	    gen("jsr", "_trace_exit_void", "  ");
	    enter_XREF("_trace_exit_void");
	}
	else if (sub_ptr->address == extfunc)
	{
	    /* INVOKABLE/module: return value already in d0 */
	    gen("jsr", "_trace_exit_long", "  ");
	    enter_XREF("_trace_exit_long");
	}
	else
	{
	    /* Return value is in caller's frame (a4), not callee's (a5).
	       sub_ptr->address was allocated at level ZERO. */
	    switch (sub_ptr->type)
	    {
		case shorttype:
		    itoa(-1*sub_ptr->address, addrbuf, 10);
		    strcat(addrbuf, "(a4)");
		    gen("move.w", addrbuf, "d0");
		    gen("jsr", "_trace_exit_short", "  ");
		    enter_XREF("_trace_exit_short");
		    break;
		case longtype:
		    itoa(-1*sub_ptr->address, addrbuf, 10);
		    strcat(addrbuf, "(a4)");
		    gen("move.l", addrbuf, "d0");
		    gen("jsr", "_trace_exit_long", "  ");
		    enter_XREF("_trace_exit_long");
		    break;
		case singletype:
		    itoa(-1*sub_ptr->address, addrbuf, 10);
		    strcat(addrbuf, "(a4)");
		    gen("move.l", addrbuf, "d0");
		    gen("jsr", "_trace_exit_single", "  ");
		    enter_XREF("_trace_exit_single");
		    break;
		case stringtype:
		    itoa(-1*sub_ptr->address, addrbuf, 10);
		    strcat(addrbuf, "(a4)");
		    gen("move.l", addrbuf, "a1");
		    gen("jsr", "_trace_exit_str", "  ");
		    enter_XREF("_trace_exit_str");
		    break;
		default:
		    gen("jsr", "_trace_exit_void", "  ");
		    enter_XREF("_trace_exit_void");
		    break;
	    }
	}
    }

    gen("unlk","a5","  ");
    if (sub_ptr->is_callback) gen("movem.l","(sp)+","d1-d7/a0-a6");
    gen("rts","  ","  ");
    gen(end_of_sub_label,"  ","  ");

    kill_symtab();
    lev=ZERO;
   } 
  }
 }
}

void parse()
{
 lev=ZERO;
 addr[lev]=0;
 new_symtab();
 create_lists();
  
 insymbol();
 block();

 undef_label_check();
 kill_symtab();
}

static void emit_startup_xrefs()
{
 if (!module_opt)
 {
   /* startup xrefs for startup.lib */
   enter_XREF("_startup");
   enter_XREF("_cleanup");

   /* command line argument xref */
   if (cli_args) enter_XREF("_parse_cli_args");

   if (translateused)
   {
    enter_XREF("_opentranslator");
    enter_XREF("_closetranslator");
   }

   if (mathfloatused)
   {
    enter_XREF("_openmathieee");
    enter_XREF("_closemathieee");
   }

   if (mathtransused)
   {
    enter_XREF("_openmathtrans");
    enter_XREF("_closemathtrans");
   }

   if (gfxused)
   {
    enter_XREF("_opengfx");
    enter_XREF("_closegfx");
    enter_XREF("_openintuition");
    enter_XREF("_closeintuition");
   }

   if (intuitionused)
   {
    enter_XREF("_openintuition");
    enter_XREF("_closeintuition");
   }

   if (gadtoolsused)
   {
    enter_XREF("_opengadtools");
    enter_XREF("_closegadtools");
   }

   enter_XREF("_starterr");

   if (trace_opt)
   {
    enter_XREF("_trace_open");
    enter_XREF("_trace_close");
    enter_XREF("_trace_enabled");
    enter_XREF("_trace_enter");
    enter_XREF("_trace_param_long");
    enter_XREF("_trace_param_short");
    enter_XREF("_trace_param_single");
    enter_XREF("_trace_param_str");
    enter_XREF("_trace_param_sep");
    enter_XREF("_trace_end_params");
    enter_XREF("_trace_exit_void");
    enter_XREF("_trace_exit_long");
    enter_XREF("_trace_exit_short");
    enter_XREF("_trace_exit_single");
    enter_XREF("_trace_exit_str");
   }

   /*
   ** A module may need to jump to _EXIT_PROG so
   ** make this label externally referenceable (* = XDEF).
   */
   enter_XREF("*EXIT_PROG");

   if (ontimerused) enter_XREF("_ontimerstart");

   /*
   ** Always call this in case a db.lib function
   ** allocates memory via alloc(). This also takes
   ** care of the use of ALLOC by an ACE program.
   ** To do this we always need to externally
   ** reference the free_alloc() function.
   */
   enter_XREF("_free_alloc");
 }
 else
 {
   /*
   ** Current module may need to jump to _EXIT_PROG, so externally reference it.
   */
    enter_XREF("_EXIT_PROG");
 }
}

static void emit_icon(source_name)
char *source_name;
{
char icon_name[MAXSTRLEN];
FILE *icon_src,*icon_dest;
int  cc;

 if (make_icon && !early_exit)
 {
  if ((icon_src = fopen("ACE:icons/exe.info","r")) == NULL)
    puts("can't open ACE:icons/exe.info for reading.");
  else
  {
   cc=0; while(source_name[cc] != '.') cc++;
   source_name[cc] = '\0';
   sprintf(icon_name,"%s.info",source_name);
   if ((icon_dest = fopen(icon_name,"w")) == NULL)
      printf("can't open %s.info for writing.\n",source_name);
   else
   {
    while (!feof(icon_src)) fputc(fgetc(icon_src),icon_dest);
    fclose(icon_dest);
    fclose(icon_src);
    puts("icon created.");
   }
  }
 }
}

void compile(source_name,dest_name)
char *source_name,*dest_name;
{
 /*
 ** Parse the source file producing XREFs, code, data,
 ** bss & basdata segments.
 */
 parse();

 /* optimise? */
 if (optimise_opt && !early_exit) optimise();

 emit_startup_xrefs();

 /* DATA statements? */
 if (basdatapresent) enter_BSS("_dataptr:","ds.l 1");
 if ((readpresent) && (!basdatapresent)) _error(25);

 /* ------------------------------------------------- */
 /* create A68K compatible 68000 assembly source file */
 /* ------------------------------------------------- */

 if (!early_exit)
	printf("\ncreating %s\n",dest_name);
 else
	printf("\nfreeing code list...\n");

 if (!early_exit) write_xrefs();

 /* startup code */
 gen_asm_header();

 gen_startup_code(addr[lev]);

 /* write code & kill code list */
 kill_code();

 gen_exit_code();

 if (!early_exit)
 {
   write_data();
   write_basdata();
   write_bss();
 }

 gen_asm_end();

 /* errors? */
 if (errors > 0) putchar('\n');

 printf("%s compiled ",source_name);

 if (errors == 0)
    printf("with no errors.\n");
 else
 {
  exitvalue=10; /* set ERROR for bas script */
  printf("with %d ",errors);
  if (errors > 1) printf("errors.\n");
  else printf("error.\n");
 }

 emit_icon(source_name);
}

void show_title()
{
 printf("ACE Amiga BASIC Compiler version %s, copyright ",version());
 putchar(169);  /* copyright symbol */
 puts(" 1991-1996 David Benn.");
 puts("Copyright 2025,2026 Manfred Bergmann.");
}

void usage()
{
 printf("\nusage: ACE [words | options] <sourcefile>[.b[as]]\n\n");
 printf("Commands:\n");
 printf("  words      List all reserved words\n\n");
 printf("Options:\n");
 printf("  -2         Generate MC68020 code\n");
 printf("  -b         Enable Ctrl-C break checking\n");
 printf("  -c         Include comments in assembly output\n");
 printf("  -E         Log errors to <sourcefile>.err\n");
 printf("  -i         Create program icon (.info file)\n");
 printf("  -l         List source code during compilation\n");
 printf("  -m         Compile as shared module (no startup code)\n");
 printf("  -O         Enable peephole optimization\n");
 printf("  -t         Enable SUB call/return tracing\n");
 printf("  -w         Enable window close gadget handling\n");
}

BOOL check_options(opt)
char *opt;
{
BOOL legalopt=TRUE;

 if (*opt != '-') return(FALSE);
 /* extract the options */
 opt++;
 if (*opt == '\0') 
    	legalopt=FALSE;
 else
 while ((*opt != '\0') && (legalopt)) 
 {
  if (*opt == 'b') break_opt=TRUE; 
  else
  if (*opt == 'O') optimise_opt=TRUE; 
  else
  if (*opt == 'i') make_icon=TRUE; 
  else
  if (*opt == 'E') error_log=TRUE;
  else
  if (*opt == 'c') asm_comments=TRUE;
  else
  if (*opt == 'l') list_source=TRUE;
  else
  if (*opt == 'm') module_opt=TRUE;
  else
  if (*opt == 'w') wdw_close_opt=TRUE;
  else
  if (*opt == '2') cpu020_opt=TRUE;
  else
  if (*opt == 't') trace_opt=TRUE;
  else
     legalopt=FALSE;
  opt++;
 }

 return(legalopt);
}

void ctrl_c_break_test()
{
	if (SetSignal(0L,SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C) 
	{
		puts("\n*** Break: ACE terminating.");
		exit(5);
	}
}

void dump_reserved_words()
{
int i;

 printf("\nAmigaBASIC RESERVED WORDS: %ld\n\n",(long)(xorsym-abssym)+1);

 for (i=abssym;i<=xorsym;i++) 
 {
 	printf("%s\n",rword[i]);
	ctrl_c_break_test();	
 }
 
 printf("\nACE-SPECIFIC RESERVED WORDS: %ld\n\n",(long)(untilsym-addresssym)+1);

 for (i=addresssym;i<=untilsym;i++)
 {
 	printf("%s\n",rword[i]);
	ctrl_c_break_test();	
 }
}
  
int main(argc,argv)
int  argc;
char *argv[];
{
char *tmparg;

 show_title();
  
 /* 
 ** - get args and compiler switches.
 ** - open source and destination files. 
 */ 
 if ((argc == 1) || (argc > 3)) 
    { usage(); exit(10); } /* arg count mismatch */

 /* send reserved words to stdout then quit? */
 tmparg = (char *)malloc(strlen(argv[1])+1);
 if (tmparg == NULL) 
 {
	puts("Unable to allocate temporary argument buffer!");
 	exit(10);
 }
 else   
 {
	strcpy(tmparg,argv[1]);

 	if (strcmp((char*)strupr(tmparg),"WORDS") == 0)
 	{
		dump_reserved_words();
		if (tmparg) free(tmparg);
 		exit(0);
 	}
	else
		if (tmparg) free(tmparg);
 }

 open_shared_libs();

 /* 
 ** compile program 
 */
 if (argc == 2) 
 {
    /* source file, no options */
    open_files(argv[1]);
    setup();
    compile(srcfile,destfile); 
 }
 else 
 {
    /* options plus source file */
    if (!check_options(argv[1])) 
       { usage(); close_shared_libs(); exit(10); } /* illegal options */  
    open_files(argv[2]);  
    setup();
    compile(srcfile,destfile);
 }

 cleanup();
 return 0;
}
