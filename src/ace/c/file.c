/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: file functions **
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
	   4th,5th,6th January 1993,
	   12th,14th,15th February 1993,
	   1st March 1993,
	   9th,17th,18th May 1993,
	   15th December 1993,
	   2nd January 1994,
	   11th March 1995,
	   10th March 1996
*/

#include "acedef.h"

/* externals */
extern	int	lev;
extern	int	sym;
extern	int	obj;
extern	int	typ;
extern	BOOL	end_of_source;
extern	SYM	*curr_item;
extern	char	id[MAXIDSIZE];
extern	char	tempstrname[80];
	
/* functions */
void open_a_file()
{
 /* OPEN mode,[#]filenumber,filespec */

 check_for_event();

 insymbol();
 if (expr() != stringtype) _error(4);  /* mode = I, O or A */
 else
 {
  if (sym != comma) _error(16);
  else
  {
   insymbol();
   if (sym == hash) insymbol(); /* # filenumber */
   if (make_integer(expr()) == shorttype) 
      make_long(); /* 1..255 */
   if (sym != comma) _error(16);
   else
   {
    insymbol();
    if (expr() != stringtype) _error(4);  /* filespec */
    else
    {
     /* pop arguments */
     gen("move.l","(sp)+","a1");  /* address of filespec */
     gen("move.l","(sp)+","d0");  /* filenumber */
     gen("move.l","(sp)+","a0");  /* address of mode string */

     gen_rt_call("_openfile");
     enter_XREF("_DOSBase");
    }
   }
  }
 }    
}

void close_a_file()
{
 /* CLOSE [#]filenumber[,[#]filenumber..] */

 check_for_event();

 do
 {
  insymbol();
  if (sym == hash) insymbol(); 
  if (make_integer(expr()) == shorttype) 
     make_long(); /* filenumber = 1..255 */
 
  gen("move.l","(sp)+","d0");
  gen_rt_call("_closefile");
 }
 while (sym == comma);

 enter_XREF("_DOSBase");
}

void line_input()
{
char addrbuf[40];
SYM  *storage;

 /* LINE INPUT  [;][prompt-string;]string-variable
    LINE INPUT# filenumber;string-variable

    Note: only the latter is currently implemented.
 */

 check_for_event();
 
 insymbol();
 
 if (sym != hash) _error(44);
 else
 {
  insymbol();

  if (make_integer(expr()) == shorttype) 
     make_long();  /* filenumber = 1..255 */

  if (sym != comma) _error(16);
  else
  {
   insymbol();

   if (sym == ident && obj == variable)
   {
    /* if string variable/array doesn't exist, create a simple variable */
    if (!exist(id,variable) && !exist(id,array)) 
    {
     /* allocate a simple string variable */
     enter(id,typ,obj,0);
     enter_DATA("_nullstring:","dc.b 0");
     gen("pea","_nullstring","  ");
     assign_to_string_variable(curr_item,MAXSTRLEN);
    }

    storage=curr_item;

    /* is it a string variable or array? */
    if (storage->type != stringtype) _error(4);
    else    
    {
     /* get address of string pointed to by variable/array element */
     gen_frame_addr(storage->address,addrbuf);

     /* pass filenumber (d0) and string address (a0) to function */
     if (storage->object == array)
     {
      point_to_array(storage,addrbuf);
      gen("move.l",addrbuf,"a0");
      gen("adda.l","d7","a0");
     }
     else
      	 gen("move.l",addrbuf,"a0");	/* string address */
      
     gen("move.l","(sp)+","d0");	/* filenumber */

     /* call _line_input */
     gen_rt_call("_line_input");

     insymbol();
     if (sym == lparen && storage->object != array) 
	_error(71);  /* undeclared array */
    }
   }
   else _error(19); /* variable (or array) expected */
  }
 }
}

void write_to_file()
{
int wtype;

 /* WRITE #filenumber,expression-list */

 check_for_event();

 insymbol();

 if (sym != hash) _error(44);
 else
 {
  insymbol();

  if (make_integer(expr()) == shorttype) 
     make_long();  /* filenumber = 1..255 */

  gen("move.l","(sp)+","_seq_filenumber");
  
  if (sym != comma) _error(16);
  else
  {
   /* get expressions */
   do
   {
    insymbol();
    wtype=expr(); 

    switch(wtype)
    {
     case undefined : _error(0);  /* expression expected */ 
		      break;

     case shorttype : 	gen("move.w","(sp)+","d1");
 		      	gen("move.l","_seq_filenumber","d0");
		      	gen_rt_call("_writeshort");
		      	break;

     case longtype : 	gen("move.l","(sp)+","d1");
		     	gen("move.l","_seq_filenumber","d0");
		     	gen_rt_call("_writelong");
		     	break;

     case singletype : 	gen("move.l","(sp)+","d1");
		       	gen("move.l","_seq_filenumber","d0");
		       	gen_rt_call("_writesingle");
			enter_XREF("_MathBase");
		       	break;

     case stringtype : 	gen("move.l","_seq_filenumber","d0");
			gen_rt_call("_writequote");
		       	gen("move.l","(sp)+","a0");
		       	gen("move.l","_seq_filenumber","d0");
		       	gen_rt_call("_writestring");
		       	gen("move.l","_seq_filenumber","d0");
		       	gen_rt_call("_writequote");
		       	break;
    }
    
    /* need a delimiter? */
    if (sym == comma) 
    { 
     gen("move.l","_seq_filenumber","d0");
     gen_rt_call("_writecomma");
    }

   }
   while (sym == comma);  

   /* write LF to mark EOLN */
   gen("move.l","_seq_filenumber","d0");
   gen_rt_call("_write_eoln");
   
   enter_XREF("_DOSBase");
   enter_BSS("_seq_filenumber:","ds.l 1");
  }
 }
}

void gen_writecode(code)
int code;
{
 /* write special character sequence to a file */

 check_for_event();

 gen("move.l","_seq_filenumber","d0");

 switch(code)
 {
  /* LF */
  case LF_CODE : 	gen_rt_call("_write_eoln");
		 	break;
  /* TAB */
  case TAB_CODE :  	gen_rt_call("_writeTAB");
			break;
  /* SPACE */
  case SPACE_CODE :	gen_rt_call("_writeSPC");
			break;
 }
}

void print_to_file()
{
int exprtype,arguments=0;

 /* PRINT #filenumber,expression-list */

 check_for_event();

 insymbol();

 if (make_integer(expr()) == shorttype)
    make_long();	/* filenumber 1..255 */

 gen("move.l","(sp)+","_seq_filenumber");
 enter_BSS("_seq_filenumber:","ds.l 1");

 if (sym != comma) _error(16);
 else
 {
  do
  {
   if (sym != ident && !strfunc() && !numfunc() && !factorfunc() && 
       obj != constant) 
      insymbol(); /* ident/func/literal after a space or as first parameter */

   /* end of line, multi-statement, ";", "," ELSE or comment 
      after "PRINT #filenumber," ? -> don't proceed to expr! */

      if ((sym == endofline) || (sym == colon) || (sym == apostrophe) || 
          (sym == semicolon) || (sym == comma) || (sym == elsesym) ||
	  (end_of_source))
      {
       if (sym == comma) gen_writecode(TAB_CODE);
       else
       if ((arguments == 0) && (sym != semicolon)) 
          gen_writecode(LF_CODE);  /* "PRINT #filenumber," with no args */ 

       if (sym != colon && sym != elsesym) 
 	  insymbol();  /* leave colon for multi-statement 
 	                  in statement() or leave ELSE for if_statement() */
       return;
      }

      /* get an expression */
      exprtype = expr();
   
      if (exprtype == undefined) { _error(0); return; } /* illegal syms? */

      /* pass filenumber to write routine */
      if (exprtype == stringtype) 
	 gen("move.l","_seq_filenumber","d0");
      else
	 gen("move.l","_seq_filenumber","d1");

      switch(exprtype)
      {
       	case shorttype : 	gen("move.w","(sp)+","d0");
		     		gen_rt_call("_fprintshort");
		     		break;

    	case longtype :		gen("move.l","(sp)+","d0");
		     		gen_rt_call("_fprintlong");
		     		break;

  	case singletype : 	gen("move.l","(sp)+","d0");
		     		gen_rt_call("_fprintsingle");
		     		enter_XREF("_MathBase");
		     		break;

   	case stringtype : 	gen("movea.l","(sp)+","a0");
		     		gen_rt_call("_writestring");
		     		break;
      }

      if (exprtype != stringtype) 
         gen_writecode(SPACE_CODE); /* trailing space for any number */

      arguments++;

      if (sym == comma) gen_writecode(TAB_CODE);
   
  }
  while ((sym == comma) || (sym == semicolon) || (sym == ident) ||
 	  strfunc() || numfunc() || factorfunc() || obj == constant);  

  /* no comma or semicolon at end of PRINT# -> LF */
  gen_writecode(LF_CODE);
 }
}

void input_from_file()
{
int  inptype;
char addrbuf[80];
SYM  *storage;

 /* INPUT #filenumber,variable-list */

 check_for_event();

 insymbol();

 if (make_integer(expr()) == shorttype)
    make_long();	/* filenumber 1..255 */

 gen("move.l","(sp)+","_seq_filenumber");
 enter_BSS("_seq_filenumber:","ds.l 1");

 if (sym != comma) _error(16);
 else
 {
  do
  { 
   /* allocate variable storage, call _input* and store value in variable */

   insymbol();

   if ((sym == ident) && (obj == variable))
   {
    if ((!exist(id,obj)) && (!exist(id,array)))
       enter(id,typ,obj,0);  /* allocate storage for a simple variable */

    storage = curr_item;

    gen_frame_addr(storage->address,addrbuf);

    /* ALL data types need a temporary string pointer in a1 */
    make_temp_string();
    gen("lea",tempstrname,"a0");  /* unique temp holder */

    /* when storing an input value into an array element, must save
       value (d0) first, since array index calculation may be corrupted
       if index has to be coerced from ffp to short.
    */

    /* pass file number */
    gen("move.l","_seq_filenumber","d0");
     
    switch(storage->type)
    {
    case shorttype  : gen_rt_call("_finputshort");

		      if (storage->object == variable)
			 gen_store_var(storage, addrbuf, "d0");
		      else
	 		 if (storage->object == array)
			 {
			  gen("move.w","d0","_short_input_temp");
			  point_to_array(storage,addrbuf);
			  gen("move.w","_short_input_temp","0(a2,d7.L)");
			  enter_BSS("_short_input_temp:","ds.w 1");
			 }

		      break;

    case longtype   : gen_rt_call("_finputlong");

		      if (storage->object == variable)
			 gen_store_var(storage, addrbuf, "d0");
		      else
	 		 if (storage->object == array)
			 {
			  gen("move.l","d0","_long_input_temp");
			  point_to_array(storage,addrbuf);
			  gen("move.l","_long_input_temp","0(a2,d7.L)");
			  enter_BSS("_long_input_temp:","ds.l 1");
			 }

		      break;

    case singletype : gen_rt_call("_finputsingle");

		      if (storage->object == variable)
			 gen_store_var(storage, addrbuf, "d0");
		      else
	 		 if (storage->object == array)
			 {
			  gen("move.l","d0","_long_input_temp");
			  point_to_array(storage,addrbuf);
			  gen("move.l","_long_input_temp","0(a2,d7.L)");
			  enter_BSS("_long_input_temp:","ds.l 1");
			 }

		      enter_XREF("_MathBase"); /* need math libs */
		      enter_XREF("_MathTransBase");
		      break;

    case stringtype : gen_rt_call("_finputstring");

		      gen("move.l","a0","-(sp)");

		      if (storage->object == variable)
  	   		 assign_to_string_variable(storage,MAXSTRLEN);
		      else
	 		 if (storage->object == array)
			 {
			  point_to_array(storage,addrbuf);
			  assign_to_string_array(addrbuf);
			 }

		      break;
    }
   } else _error(19);

   insymbol();
   if (sym == lparen && storage->object != array)
      _error(71);  /* undeclared array */
  }
  while (sym == comma);
 }
}

void kill()
{
/* KILL <filespec> */

 check_for_event();

 insymbol();
 if (expr() != stringtype) _error(4);
 else
 {
  gen("move.l","(sp)+","d1");
  gen_rt_call("_kill");
 }
}

void osrename()
{
/* NAME <filespec1> AS <filespec2> */

 check_for_event();

 insymbol();
 if (expr() != stringtype) _error(4);
 else
 {
  if (sym != assym) _error(72);
  else
  {
   insymbol();
   if (expr() != stringtype) _error(4);
   else
   {
    gen("move.l","(sp)+","d2");  /* <filespec2> */
    gen("move.l","(sp)+","d1");  /* <filespec1> */
    gen_rt_call("_rename");
   }
  }
 }
}

void chdir()
{
/* CHDIR <dirname> */

 check_for_event();

 insymbol();

 if (expr() != stringtype) _error(4);
 else
 {
  /* call code to change directory */
  gen("move.l","(sp)+","d1");  /* dirname */
  gen_rt_call("_chdir");
 }
}

void files()
{
/* FILES [TO <storefile>] [,<target>] */
 
 check_for_event();

 insymbol();

 /* storage file specified? */
 if (sym == tosym)
 {
  insymbol();
  if (expr() != stringtype) _error(4);
 }
 else
     gen("move.l","#0","-(sp)");  /* NULL for storage file name */
      
 /* target file or directory specified? */
 if (sym == comma)
 {
  insymbol();
  if (expr() != stringtype) _error(4);
 }
 else
     gen("move.l","#0","-(sp)");  /* NULL for target name */

 /* call _files routine */
 gen_rt_call("_files");
 gen_stack_cleanup(4);
}

char *push_struct_var_info(structVar)
SYM *structVar;
{
char addrbuf[40], sizebuf[10];

	/*
	** Push address held by structure variable.
	*/
	gen_frame_addr(structVar->address, addrbuf);
	if (structVar->shared && lev == ONE)
	{
		/*
		** Shared structure variable.
		*/
		gen("movea.l",addrbuf,"a0");	/* struct variable address */
		gen("move.l","(a0)","-(sp)");	/* start address of struct */
	}
	else
		/*
		** Local structure variable,
		** ie. in main program or SUB.
		*/
		gen("move.l",addrbuf,"-(sp)");	/* variable holds start address */

	/*
	** Push size of structure in bytes.
	*/
	sprintf(sizebuf,"#%d",structVar->other->size);
	gen("move.l",sizebuf,"-(sp)");
}

void random_file_get()
{
/*
** Fill a structure from a random file.
**
** SYNTAX: GET [#]fileNum, structVar [, recordNum]
*/
SYM *structVar;

	check_for_event(); 
	
	/* 
	** We already have the first symbol.
	** Skip `#' if present.
	*/
	if (sym == hash) insymbol();
	
	/*
	** Get the file number.
	*/
 	if (make_integer(expr()) == shorttype)
    		make_long();	/* filenumber 1..255 */

 	if (sym != comma) _error(16);
 	else
 	{
		/*
		** Structure variable address and size.
		*/
		insymbol();
		if (!exist(id,structure)) _error(79);
		else
		{
			structVar = curr_item;
			push_struct_var_info(structVar);

			insymbol();
			if (sym == comma)
			{
				/*
				** Optional record number.
				*/
				insymbol();
 				if (make_integer(expr()) == shorttype)
    					make_long();	/* record number >= 1 */
			}
			else
				/*
				** Tell library function not to
				** seek to a particular record 
				** before reading.
				*/
				gen("move.l","#0","-(sp)");

			/*
			** Call function.
			*/
			gen_rt_call("_GetRecord");
 			gen_stack_cleanup(16);
		}
	}	
}

void random_file_put()
{
/*
** Write a structure to a random file.
**
** SYNTAX: PUT [#]fileNum, structVar [, recordNum]
*/
SYM *structVar;

	check_for_event(); 
	
	/* 
	** We already have the first symbol.
	** Skip `#' if present.
	*/
	if (sym == hash) insymbol();
	
	/*
	** Get the file number.
	*/
 	if (make_integer(expr()) == shorttype)
    		make_long();	/* filenumber 1..255 */

 	if (sym != comma) _error(16);
 	else
 	{
		/*
		** Structure variable address and size.
		*/
		insymbol();
		if (!exist(id,structure)) _error(79);
		else
		{
			structVar = curr_item;
			push_struct_var_info(structVar);

			insymbol();
			if (sym == comma)
			{
				/*
				** Optional record number.
				*/
				insymbol();
 				if (make_integer(expr()) == shorttype)
    					make_long();	/* record number >= 1 */
			}
			else
				/*
				** Tell library function not to
				** seek to a particular record 
				** before writing.
				*/
				gen("move.l","#0","-(sp)");

			/*
			** Call function.
			*/
			gen_rt_call("_PutRecord");
 			gen_stack_cleanup(16);
		}
	}	
}
