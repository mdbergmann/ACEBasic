/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: statement code **
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
	   6th,7th,12th,13th,27th-29th December 1992,
	   4th,6th,31st January 1993,
	   6th,12th,13th,15th,18th,28th February 1993,
	   1st,7th,24th March 1993,
	   9th May 1993,
	   12th,13th,30th June 1993,
	   1st July 1993,
	   5th,25th September 1993 
	   26th October 1993,
	   1st,2nd,8th,9th November 1993,
	   27th December 1993,
	   2nd,5th January 1994,
	   6th,15th,16th,27th February 1994,
	   4th April 1994,
	   14th,15th May 1994,
	   10th July 1994,
	   7th August 1994,
	   3rd,8th,17th September 1994,
	   5th March 1995,
	   8th August 1995,
	   10th March 1996,
	   11th,22nd June 1996,
	   4th September 1996
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	int	obj;
extern	int	typ;
extern	int 	lev;
extern	char	ch;
extern	char   	id[MAXIDSIZE]; 
extern	char   	ut_id[MAXIDSIZE];
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	CODE	*exit_for_cx;

extern	ACELIBS acelib[NUMACELIBS];

extern	char 	librarybase[MAXIDSIZE+6];
extern	BOOL 	have_lparen;
extern	BOOL 	have_equal;
extern	BOOL 	restore_a4;
extern	BOOL 	restore_a5;
extern	BOOL	narratorused;
extern	BOOL	end_of_source;
extern	char 	exit_sub_name[80];

/* ------*/
/* sound */
/* ------*/

void sound()
{
/* make a tone of given period, duration and volume through 
   the specified channel */

BOOL voice=FALSE;
BOOL volume=FALSE;

 insymbol();
 make_sure_short(expr());  /* period (short) 0..32767 */ 

 if (sym != comma) _error(16);
 else
 {
  insymbol();
  gen_Flt(expr());  /* duration (single) 0..77 */
 }

 if (sym == comma)
 {
  insymbol();
  if (sym != comma)  /* if comma -> skip volume */
  {
   make_sure_short(expr());  /* volume (short) 0..64 */
   volume=TRUE;
  }
  else gen("moveq","#64","d2");  /* default volume = 64 */
 }
 else gen("moveq","#64","d2");  /* default volume = 64 */

 if (sym == comma)
 {
  insymbol();
  make_sure_short(expr());  /* voice (short) 0..3 */
  voice=TRUE;
 }
 else gen("moveq","#0","d3");  /* default voice = 0 */

 if (voice)  gen("move.w","(sp)+","d3");  /* pop voice */
 if (volume) gen("move.w","(sp)+","d2");  /* pop volume */

 gen("move.l","(sp)+","d1");  /* pop duration */
 gen("move.w","(sp)+","d0");  /* pop period */

 gen("jsr","_sound","  ");
 enter_XREF("_sound");
 enter_XREF("_DOSBase");
 enter_XREF("_MathBase");
}   

void handle_label(label_name)
char *label_name;
{
int  oldlevel;
char label_lab[50];

 /* create a new label */

    oldlevel=lev;  /* make all labels global -> level ZERO */ 
    lev=ZERO;

    /* does label already exist? */
    strcpy(label_lab,label_name);
    strcat(label_lab,":\0");

    if (!exist(label_lab,label)) 
    { 
     /* no, so create it */
     enter(label_lab,notype,label,0); 
     gen(label_lab,"  ","  "); 
     turn_event_off(label_name);  /* see event.c */
    }
    else _error(6);  /* duplicate label */
    lev=oldlevel;
}

/*-----------*/
/* statement */
/*-----------*/
 
void statement()
{
char  buf[50],destbuf[3],idholder[50],addrbuf[80],sub_name[80],numbuf[40];
char  func_name[MAXIDSIZE],func_address[MAXIDSIZE+9];
char  ext_name[MAXIDSIZE+1];
int   commandsym;
int   oldobj,oldtyp,stype;
int   statetype;
int   oldlevel;
SYM   *func_item,*sub_item,*mc_item,*inc_item,*dec_item;
BYTE  libnum;
BOOL  need_symbol=TRUE;
int   i;
SHORT popcount;

 /* data object assignment (variable, subprogram or array element), 
    label declaration or subprogram call without CALL? */
 if (sym == ident)
 {
  /* make subprogram name */
  strcpy(sub_name,"_SUB_");
  strcat(sub_name,id);

  /* store id in case it's a function */
  strcpy(func_name,id);
  remove_qualifier(func_name);

  /* make external variable name 
     by removing qualifier and 
     adding an underscore prefix 
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

  /* assignment? */
  strcpy(idholder,id);  /* save info for label or assign() */
  oldobj=obj;
  oldtyp=typ;

  insymbol();
  
  /* a variable/subprogram assignment or an array element assignment? */
  if ((sym == equal) || (sym == memberpointer) || ((sym == lparen) 
      && (!exist(sub_name,subprogram)) && (!exist(func_name,function))
      && (!exist(ext_name,extfunc)))) 
  {
     strcpy(id,idholder);  /* restore info */
     obj=oldobj;
     typ=oldtyp;
     if (sym == equal)  have_equal=TRUE;
     if (sym == lparen) 
         if (!exist(id,array)) { _error(71); insymbol(); return; } 
     else
	 have_lparen=TRUE;
     assign(); 
     have_equal=FALSE;
     have_lparen=FALSE;
  }
  else
  /* implicit subprogram or function call (ie: without CALL command)? */
  if (exist(func_name,function) || exist(sub_name,subprogram) ||
      exist(ext_name,extfunc)) 
  {
    sub_item=curr_item; /* - store curr_item because the next call to exist()
			     will clobber it! (for use by SUB call)
			   - if sub_item points to a function item,
			     it makes no difference since func_item
			     will be used instead. */
    check_for_event();

    if (exist(ext_name,extfunc))
    {
     /* call external function */
     call_external_function(ext_name,&need_symbol);
     if (need_symbol) insymbol();
    }
    else
    if (exist(func_name,function)) 
    {
     /* call shared library function */
     func_item=curr_item;
     if (func_item->no_of_params != 0)
        { load_func_params(func_item); insymbol(); }

     /* call the function */
     if ((libnum=check_for_ace_lib(func_item->libname)) == NEGATIVE) 
        make_library_base(func_item->libname);
     else
        strcpy(librarybase,acelib[libnum].base);
     gen("move.l",librarybase,"a6");
     itoa(func_item->address,func_address,10);
     strcat(func_address,"(a6)");
     gen("jsr",func_address,"  ");
     if (restore_a4) { gen("move.l","_a4_temp","a4"); restore_a4=FALSE; }
     if (restore_a5) { gen("move.l","_a5_temp","a5"); restore_a5=FALSE; }
    }
    else
    {
      /* call SUB */
      if (sub_item->no_of_params != 0) 
         { load_params(sub_item); insymbol(); }
      gen("jsr",sub_name,"  ");
    }
  }
  else
  {
   /* label? */
   if (sym == colon)
        handle_label(idholder);
   else 
       _error(24);   /* colon expected */
   insymbol();
  }
 }
 else
 /* line number? */
 if (sym == shortconst || sym == longconst)
 {
  make_label_from_linenum(sym,idholder);
  handle_label(idholder);
  insymbol();
 }
 else
 /* assign with LET ? */ 
 if (sym == letsym) 
 { 
  insymbol();

  if (sym == ident)
  {
   strcpy(idholder,id);  /* save info for assign() */
   oldobj=obj;
   oldtyp=typ;

   insymbol();

   if ((sym == equal) || (sym == lparen) || (sym == memberpointer))
   {
     strcpy(id,idholder);  /* restore info */
     obj=oldobj;
     typ=oldtyp;
     if (sym == equal) have_equal=TRUE;
     if (sym == lparen) have_lparen=TRUE;
     assign(); 
     have_equal=FALSE;
     have_lparen=FALSE;
   }
  }
  else _error(7); 
 }
 else
 /* multi-statement? */
 if (sym == colon)
 {
  while (sym == colon) { insymbol(); statement(); }
 }
 else
 /* assem */
 if (sym == assemsym) assem();
 else
 /* area */
 if (sym == areasym) area();
 else
 /* areafill */
 if (sym == areafillsym) areafill();
 else
 /* back */
 if (sym == backsym)
 {
  insymbol();
  gen_Flt(expr());
  gen("move.l","(sp)+","d0");
  gen("jsr","_back","  ");
  enter_XREF("_back");
  enter_XREF("_MathBase");
  enter_XREF("_MathTransBase");
  enter_XREF("_GfxBase"); 
 }
 else
 /* beep */
 if (sym == beepsym) 
 { 
  gen("jsr","_beep","  ");
  enter_XREF("_beep");
  enter_XREF("_MathBase");  /* _sound needs mathffp.library */
  insymbol();
 }  
 else
 /* assert */
 if (sym == assertsym)
 {
  insymbol();
  make_integer(expr());
  gen("move.l","(sp)+","d0");         /* condition in d0 */

  if (sym == comma) {
    /* optional message provided */
    insymbol();
    if (expr() != stringtype) _error(4);
    gen("move.l","(sp)+","a0");       /* string addr in a0 */
  } else {
    /* no message - pass NULL */
    gen("move.l","#0","a0");
  }

  gen("jsr","_assert","  ");
  enter_XREF("_assert");
 }
 else
 /* bevelbox */
 if (sym == bevelboxsym) bevel_box();
 else
 /* event trapping activation/deactivation? */
 if ((sym == breaksym) || (sym == mousesym) || 
     (sym == timersym) || (sym == errorsym)) 
    change_event_trapping_status(sym);
 else
 /* block */
 if (sym == blocksym) block_statement();
 else
 /* call */
 if (sym == callsym)
 {
  check_for_event();

  insymbol();
  if (sym != ident) 
     _error(32);
  else
  {
   /* function? */
   strcpy(func_name,id);
   remove_qualifier(func_name);

   if (exist(func_name,function)) 
   { 
    func_item=curr_item;
    if (func_item->no_of_params != 0)
    { insymbol(); load_func_params(func_item); }
    /* call it */
    if ((libnum=check_for_ace_lib(func_item->libname)) == NEGATIVE) 
       make_library_base(func_item->libname);
    else
       strcpy(librarybase,acelib[libnum].base);
    gen("move.l",librarybase,"a6");
    itoa(func_item->address,func_address,10);
    strcat(func_address,"(a6)");
    gen("jsr",func_address,"  ");
    if (restore_a4) { gen("move.l","_a4_temp","a4"); restore_a4=FALSE; }
    if (restore_a5) { gen("move.l","_a5_temp","a5"); restore_a5=FALSE; }
   }
   else
   {
    /* subprogram, machine code subroutine or external function? */
    strcpy(sub_name,"_SUB_");
    strcat(sub_name,id);

    if (!exist(sub_name,subprogram)) 
    {
     /* make external variable name 
        by removing qualifier and 
        adding an underscore prefix 
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

      if (exist(ext_name,extfunc))
      { 
       /* external function? */
       insymbol();
       call_external_function(ext_name,&need_symbol);
      }
     else
     { 
      /* machine code subroutine? */
      if (exist(id,variable) && (curr_item->type == longtype))
      {
       mc_item=curr_item;
       insymbol();
       if (sym == lparen) { load_mc_params(mc_item); need_symbol=TRUE; } 
       else 
           { mc_item->no_of_params=0; need_symbol=FALSE; }

       /* call routine */
       itoa(-1*mc_item->address,addrbuf,10);
       strcat(addrbuf,frame_ptr[lev]);
       gen("move.l",addrbuf,"a0");
       gen("jsr","(a0)","  ");
       /* pop parameters? */
       if (mc_item->no_of_params != 0)
       {
         popcount=0;
         for (i=0;i<mc_item->no_of_params;i++) 
         {
          if (mc_item->p_type[i] == shorttype) 
	    popcount += 2;
    	  else
	    popcount += 4;
         }
        /* add popcount to sp */
        strcpy(buf,"#\0");
        itoa(popcount,numbuf,10);
        strcat(buf,numbuf);
        gen("add.l",buf,"sp");
       }
      }
      else _error(37); /* undeclared subprogram */
     }
    }
    else
       {
        /* user-defined subprogram */
        if (curr_item->no_of_params != 0) 
           { insymbol(); load_params(curr_item); }
        gen("jsr",sub_name,"  ");
       }
   }
  }
  if (need_symbol) insymbol();
 }
 else
 /* case */
 if (sym == casesym) { check_for_event(); case_statement(); }
 else
 /* chdir */
 if (sym == chdirsym) chdir();
 else
 /* circle */
 if (sym == circlesym) circle();
 else
 /* clear */
 if (sym == clearsym) 
 { 
	insymbol(); 
	if (sym == allocsym) 
	   { gen("jsr","_clear_alloc","  "); enter_XREF("_clear_alloc"); }
	insymbol();
 }
 else
 /* close */
 if (sym == closesym) close_a_file();
 else
 /* cls */
 if (sym == clssym) 
 { 
  gen("jsr","_cls","  "); 
  enter_XREF("_cls");
  enter_XREF("_DOSBase"); /* need dos library */
  insymbol(); 
 }
 else
 /* color */
 if (sym == colorsym) color();
 else
 /* common */
 if (sym == commonsym) define_common_or_global_variable(sym);
 else
 /* const */
 if (sym == constsym) define_constant();
 else
 /* data */
 if (sym == datasym) get_data();
 else
 /* declare */
 if (sym == declaresym) declare();
 else
 /* defint,deflng,defsng,defdbl,defstr -> global effects */
 if (sym == defintsym) change_id_type(shorttype);
 else
 if (sym == deflngsym) change_id_type(longtype);
 else
 if (sym == defsngsym) change_id_type(singletype);
 else
 if (sym == defdblsym) change_id_type(singletype);
 else
 if (sym == defstrsym) change_id_type(stringtype);
 else
 /* dim */
 if (sym == dimsym) dim();
 else
 /* end & stop */
 if ((sym == endsym) || (sym == stopsym))
 {
  gen("jmp","_EXIT_PROG","  ");
  insymbol();
 }
 else
 /* exit (ie: EXIT SUB/FOR) */
 if (sym == exitsym)
 { 
  insymbol();

  if (sym == forsym)
  {
  	/* EXIT FOR */
	gen("nop","  ","  ");
	exit_for_cx = curr_code;
	insymbol();
  }
  else
  if (lev == ONE)
  {  
	/* EXIT SUB */
   	if (sym != subsym) 
      	   _error(35);
   	else
      	   gen("jmp",exit_sub_name,"  ");

   	insymbol();
  }
  else
     {
      	_error(36); /* can only use EXIT SUB in a subprogram! */
      	insymbol();
     }
 }
 else
 /* external */
 if (sym == externalsym) define_external_object();
 else
 /* files */
 if (sym == filessym) files();
 else
 /* fix */
 if (sym == fixsym) 
 {
  insymbol();
  if (make_integer(expr()) != longtype) make_long();
  gen("move.l","(sp)+","d0");
  gen("jsr","_fix","  ");
  enter_XREF("_fix");
 }
 else
 /* font */
 if (sym == fontsym) text_font();
 else
 /* for.. */
 if (sym == forsym) for_statement();
 else
 /* forward */
 if (sym == forwardsym)
 {
  insymbol();
  gen_Flt(expr());
  gen("move.l","(sp)+","d0");
  gen("jsr","_forward","  ");
  enter_XREF("_forward");
  enter_XREF("_MathBase");
  enter_XREF("_MathTransBase");
  enter_XREF("_GfxBase"); 
 }  
 else
 /* gadget */
 if (sym == gadgetsym) gadget();
 else
 /* get */
 if (sym == getsym)
 {
 	insymbol();
	if (sym == lparen) 
	{
		/* Graphics GET */
	}
	else
	{
		/* Random File GET */
		random_file_get();
	}
 }	
 else
 /* global */
 if (sym == globalsym) define_common_or_global_variable(sym);
 else
 /* goto or gosub */
 if ((sym == gotosym) || (sym == gosubsym))
 {
  check_for_event();
  oldlevel=lev; /* labels are defined at level ZERO only */
  lev=ZERO;
  commandsym=sym;
  insymbol();
  if (sym == ident || sym == shortconst || sym==longconst)
  {
   if (sym != ident) make_label_from_linenum(sym,id);   
   strcpy(buf,id);
   strcat(buf,":\0");
   if (!exist(buf,label)) 
      strcpy(destbuf,"* "); /* mark for later check */
   else 
      strcpy(destbuf,"  ");

   /* generate approriate branch */
   switch(commandsym)
   {
    case gotosym  : gen("jmp",id,destbuf); break;
    case gosubsym : gen("jsr",id,destbuf); break;
   }
  }
  lev=oldlevel;
  insymbol(); 
 }
 else
 /* home */
 if (sym == homesym)
 {
  gen("jsr","_home","  ");
  enter_XREF("_home");
  enter_XREF("_GfxBase");
  insymbol();
 }
 else
 /* if...then...else... */
 if (sym == ifsym) { check_for_event(); if_statement(); }
 else
 /* IFF */
 if (sym == iffsym) iff();
 else
 /* kill */
 if (sym == killsym) kill();
 else
 /* input */
 if (sym == inputsym) 
 { 
  check_for_event(); 
  insymbol();
  if (sym == hash) input_from_file(); else input(); 
 }
 else
 /* library */
 if (sym == librarysym) library();
 else
 /* line or line input */
 if (sym == linesym) 
 {
  insymbol();
  if (sym == inputsym) line_input(); else draw_line();
 }
 else
 /* locate */
 if (sym == locatesym)
 {
  insymbol();
  make_sure_short(expr());  /* ROW */

  if (sym == comma)
  {
   insymbol();
   make_sure_short(expr());
  }
  else gen("move.w","#1","-(sp)");  /* COLUMN */

  gen("move.w","(sp)+","d1");  /* pop COLUMN */
  gen("move.w","(sp)+","d0");  /* pop ROW */  

  gen("jsr","_locate","  ");
  enter_XREF("_locate");
  enter_XREF("_DOSBase");
 }
 else
 /* longint */
 if (sym == longintsym || sym == addresssym) declare_variable(longtype);
 else
 /* menu */
 if (sym == menusym) menu();
 else
 /* message */
 if (sym == messagesym) message();
 else
 /* msgbox */
 if (sym == msgboxsym) MsgBox();
 else
 /* name */
 if (sym == namesym) osrename();
 else
 /* next */
 if ((sym == nextsym) && (lastsym == colon)) 
 {
  lastsym=undefined;
  return;  /* eg: for i=1 to 10:next */
 }
 else
 /* on <event> | <integer-expression> */
 if (sym == onsym) 
 {
  insymbol();
  if (sym==breaksym || sym==mousesym || sym==menusym || 
      sym==timersym || sym==errorsym || sym==windowsym || 
      sym==gadgetsym)
     get_event_trap_label();
  else
     on_branch();    
 }
 else
 /* open */
 if (sym == opensym) open_a_file();
 else
 /* option */
 if (sym == optionsym) parse_option_list();
 else
 /* paint */
 if (sym == paintsym) paint();
 else
 /* palette */
 if (sym == palettesym)
 {
   insymbol();
   make_sure_short(expr()); /* color-id */
   if (sym != comma) _error(16);
   else
   {
    insymbol();
    gen_Flt(expr()); /* red */
    if (sym != comma) _error(16);
    else
    {
     insymbol();
     gen_Flt(expr()); /* green */
     if (sym != comma) _error(16);
     else
     {
       insymbol();
       gen_Flt(expr()); /* blue */
       
       /* pop parameters */
       gen("move.l","(sp)+","d3"); /* blue */
       gen("move.l","(sp)+","d2"); /* green */
       gen("move.l","(sp)+","d1"); /* red */
       gen("move.w","(sp)+","d0"); /* color-id  (0-31) */

       /* open the screen */
       gen("jsr","_palette","  ");
       enter_XREF("_palette");
       enter_XREF("_GfxBase");
       enter_XREF("_MathBase"); /* must convert 0-1 values to bytes: 0-15 */
     }
    }
   }
 }
 else
 /* pattern */
 if (sym == patternsym) pattern();
 else
 /* pendown */
 if (sym == pendownsym)
 {
  gen("jsr","_pendown","  ");
  enter_XREF("_pendown");
  insymbol();
 }
 else
 /* penup */
 if (sym == penupsym)
 {
  gen("jsr","_penup","  ");
  enter_XREF("_penup");
  insymbol();
 }
 else
 /* poke */
 if (sym == pokesym) poke();
 else
 /* pokew */
 if (sym == pokewsym) pokew();
 else
 /* pokel */
 if (sym == pokelsym) pokel();
 else
 /* print */
 if ((sym == printsym) || (sym == question)) 
 { 
  check_for_event(); 
  print_statement(); 
  if (sym == hash && (lastsym == printsym || lastsym == question)) 
     print_to_file();
 }
 else
 /* prints */
 if (sym == printssym)
    { check_for_event(); prints_statement(); }    
 else
 /* pset */
 if (sym == psetsym) pset(); 
 else
 /* put */
 if (sym == putsym)
 {
 	insymbol();
	if (sym == stepsym || sym == lparen) 
	{
		/* Graphics PUT */
	}
	else
	{
		/* Random File PUT */
		random_file_put();
	}
 }	
 else
 /* read */
 if (sym == readsym) { check_for_event(); read_data(); }
 else
 /* rem */
 if (sym == remsym)
 {
  while ((sym != endofline) && (!end_of_source)) nextch();
  insymbol();
 }
 else
 /* randomize */
 if (sym == randomizesym)
 {
  insymbol();
  statetype = expr();
  if ((statetype = make_integer(statetype)) == notype) _error(4);
  if (statetype == shorttype) make_long();
  gen("move.l","(sp)+","d0");
  gen("jsr","_randomise","  ");
  enter_XREF("_randomise");
  enter_XREF("_MathBase");
 }
 else
 /* repeat */
 if (sym == repeatsym) repeat_statement();
 else
 /* restore */
 if (sym == restoresym) { gen("move.l","#_BASICdata","_dataptr"); insymbol(); }
 else
 /* return */
 if (sym == returnsym)
 {
  check_for_event();
  gen("rts","  ","  ");
  insymbol();
 }
 else
 /* say */
 if (sym == saysym)
 {
  insymbol();
  if (expr() != stringtype) _error(4);  /* phoneme string on stack */

  if (sym == comma)
  {
   insymbol();
   if ((sym == ident) && (obj == variable)) 
   {
    if (!exist(id,array)) _error(28); 
    else
        if (curr_item->type != shorttype) _error(28); 
        else
           {
	    /* get address of array from stack frame */
            itoa(-1*curr_item->address,addrbuf,10);
            strcat(addrbuf,frame_ptr[lev]);
	    gen("move.l",addrbuf,"-(sp)"); /* push address of mode-array */
	    /* SIZE of array not checked here! (must be >= 9 elements) */
           } 
   insymbol();
   }
   else _error(28); 
  }
  else gen("move.l","#0","-(sp)");  /* no mode-array -> push NULL */

  gen("jsr","_say","  ");
  gen("addq","#8","sp");  /* pop two parameters */
  enter_XREF("_say");
  enter_XREF("_cleanup_async_speech");
  narratorused=TRUE;
 }
 else
 /* screen */
 if (sym == screensym) { screen(); check_for_event(); }
 else
 if (sym == scrollsym) scroll();
 else
 /* serial command */
 if (sym == serialsym) { check_for_event(); serial_command(); }
 else
 /* setheading */
 if (sym == setheadingsym)
 {
  insymbol();
  make_sure_short(expr());
  gen("move.w","(sp)+","d0");
  gen("jsr","_setheading","  ");
  enter_XREF("_setheading");
 }
 else
 /* setxy */
 if (sym == setxysym)
 {
  insymbol();
  make_sure_short(expr()); /* x */
  if (sym != comma) _error(16);
  else
  {
   insymbol();
   make_sure_short(expr()); /* y */
   /* pop operands */
   gen("move.w","(sp)+","d1"); /* y */
   gen("move.w","(sp)+","d0"); /* x */
   gen("jsr","_setxy","  ");
   enter_XREF("_setxy");
   enter_XREF("_GfxBase");
  }
 }
 else
 /* shared */
 if (sym == sharedsym && lev == ZERO) { _error(69); insymbol(); }
 else
 /* shortint */
 if (sym == shortintsym) declare_variable(shorttype);
 else
 /* single */
 if (sym == singlesym) declare_variable(singletype);
 else
 /* sleep */
 if (sym == sleepsym) 
 {
    insymbol();

    if (sym != forsym)
    { 
	  /* SLEEP */
	  gen("jsr","_sleep","  "); enter_XREF("_sleep");
    }
    else
    { 
	  /* SLEEP FOR <seconds> */ 
	  insymbol();
	  stype = expr();
	  if (stype == stringtype) _error(4);
	  else
	  {
		gen_Flt(stype); 
	  	gen("jsr","_sleep_for_secs","  "); gen("addq","#4","sp");
	  	enter_XREF("_sleep_for_secs"); enter_XREF("_MathBase");
	  }
    }
 }
 else
 /* string */
 if (sym == stringsym) declare_variable(stringtype);
 else
 /* sound */
 if (sym == soundsym) sound();
 else
 /* struct */
 if (sym == structsym) define_structure();
 else
 /* style */
 if (sym == stylesym) text_style();
 else
 /* swap */
 if (sym == swapsym) swap();
 else
 /* system */
 if (sym == systemsym)
 {
  insymbol();
  stype = make_integer(expr());
  if (stype == shorttype || stype == longtype)
  {
     /* SYSTEM returncode */
     if (stype == shorttype) make_long()  ; /* get short integer exit value */
     gen("move.l","(sp)+","_returncode");
     gen("jmp","_EXIT_PROG","  ");
     enter_XREF("_returncode");
  }
  else
  {
     /* SYSTEM command-string */
     gen("jsr","_system_call","  ");
     gen("addq","#4","sp");
     enter_XREF("_system_call");
  }
 }
 else
 /* turn */
 if (sym == turnsym)
 {
  insymbol();
  make_sure_short(expr());
  gen("move.w","(sp)+","d0");
  gen("jsr","_turn","  ");
  enter_XREF("_turn");
 }	
 else
 /* turnleft */
 if (sym == turnleftsym)
 {
  insymbol();
  make_sure_short(expr());
  gen("move.w","(sp)+","d0");
  gen("jsr","_turnleft","  ");
  enter_XREF("_turnleft");
 }	
 else
 /* turnright */
 if (sym == turnrightsym)
 {
  insymbol();
  make_sure_short(expr());
  gen("move.w","(sp)+","d0");
  gen("jsr","_turnright","  ");
  enter_XREF("_turnright");
 }	
 else
 /* until */
 if ((sym == untilsym) && (lastsym == colon)) 
 {
  lastsym=undefined;
  return; /* eg: repeat:..:until i>10 */
 }
 else
 /* wave */
 if (sym == wavesym) 
 {
  /* voice */
  insymbol();
  make_sure_short(expr());  /* voice (short) 0..3 */

  /* wave definition */
  if (sym != comma) _error(16);
  else
  {
   insymbol();
   if (sym == sinsym) 
   {
    gen("move.l","#0","a0");  /* SIN wave = 0 -> flag for _wave */
    insymbol();
   }
   else
   {
    /* now expect an address -> pointer to a block of bytes */
    if (expr() != longtype) _error(4);
    
    /* number of bytes? */
    if (sym != comma) _error(16);
    else
    {
     insymbol();
     if ((statetype=make_integer(expr())) == shorttype) make_long();  

     if (statetype == notype) _error(4); /* string -> type mismatch */
    }   

    gen("move.l","(sp)+","d1");  /* pop # of bytes of waveform data */
    gen("move.l","(sp)+","a0");  /* pop address of waveform data */
   }
  }
  gen("move.w","(sp)+","d0");  /* pop voice */
  gen("jsr","_wave","  "); 
  enter_XREF("_wave");
 }
 else
 /* while.. */
 if (sym == whilesym) while_statement();
 else
 /* wend */
 if ((sym == wendsym) && (lastsym == colon)) 
 {
  lastsym=undefined;
  return; /* eg: while i>2:wend */
 }
 else
 /* window */
 if (sym == windowsym) { window(); check_for_event(); }
 else
 /* write */
 if (sym == writesym) { check_for_event(); write_to_file(); }
 else
 /* ++ */
 if (sym == increment)
 { 
   insymbol();
                if (sym != ident)
     		   _error(7);
  	        else
  		{
		  /* it may be an external variable */
		  strcpy(buf,ut_id);
		  remove_qualifier(buf);
		  if (buf[0] != '_')
		  {
			sprintf(ext_name,"_%s",buf);
		  }
		  else
		    	strcpy(ext_name,buf);

		  if ((!exist(id,variable)) && (!exist(ext_name,extvar)))
		     _error(19); /* simple variable expected */
		  else
		  {
		   inc_item=curr_item;
		   if (inc_item->type == stringtype)
		      _error(4);
		   else
		   {
		    /* get address of variable */
		    address_of_object();
		    gen("move.l","(sp)+","a0");

		    /* increment it by 1 */
		    switch(inc_item->type)
		    {
		     case shorttype  : gen("add.w","#1","(a0)");
		     		       break;

		     case longtype   : gen("add.l","#1","(a0)");
		     		       break;

		     case singletype : gen("movea.l","_MathBase","a6");
				       gen("move.l","(a0)","d0");
				       gen("move.l","#$80000041","d1");
				       gen("jsr","_LVOSPAdd(a6)","  ");
				       gen("move.l","d0","(a0)");
				       enter_XREF("_MathBase");
				       enter_XREF("_LVOSPAdd");
				       break;
		    }
 		   }
 		  }
		 insymbol();
		} 
 }		 
 else
 /* -- */
 if (sym == decrement)
 { 
   insymbol();
                if (sym != ident)
     		   _error(7);
  	        else
  		{
		  /* it may be an external variable */
		  strcpy(buf,ut_id);
		  remove_qualifier(buf);
		  if (buf[0] != '_')
		  {
			sprintf(ext_name,"_%s",buf);
		  }
		  else
		    	strcpy(ext_name,buf);

		  if ((!exist(id,variable)) && (!exist(ext_name,extvar)))
		     _error(19); /* simple variable expected */
		  else
		  {
		   dec_item=curr_item;
		   if (dec_item->type == stringtype)
		      _error(4);
		   else
		   {
		    /* get address of variable */
		    address_of_object();
		    gen("move.l","(sp)+","a0");

		    /* increment it by 1 */
		    switch(dec_item->type)
		    {
		     case shorttype  : gen("sub.w","#1","(a0)");
		     		       break;

		     case longtype   : gen("sub.l","#1","(a0)");
		     		       break;

		     case singletype : gen("movea.l","_MathBase","a6");
				       gen("move.l","(a0)","d0");
				       gen("move.l","#$80000041","d1");
				       gen("jsr","_LVOSPSub(a6)","  ");
				       gen("move.l","d0","(a0)");
				       enter_XREF("_MathBase");
				       enter_XREF("_LVOSPSub");
				       break;
		    }
 		   }
 		  }
 		 insymbol();
		} 
 }		 
 else
 /* *%<address> = <expr> */
 if (sym == shortpointer) 
 { 
  insymbol();
  if (expr() != longtype)  /* address */
     _error(4);
  else
  {
   if (sym != becomes)
      _error(5);
   else
   {
    insymbol();
    make_sure_short(expr());  
    gen("move.w","(sp)+","d0");  /* pop expression */ 
    gen("move.l","(sp)+","a0");  /* pop address */
    gen("move.w","d0","(a0)");   /* store expression */
   }
  }
 }
 else
 /* *&<address> = <expr> */
 if (sym == longpointer) 
 { 
  insymbol();
  if (expr() != longtype)  /* address */
     _error(4);
  else
  {
   if (sym != becomes)
      _error(5);
   else
   {
    insymbol();
    if ((statetype=make_integer(expr())) == notype)
       _error(4);
    else 
    {
     /* statetype is either short or long now */
     if (statetype == shorttype) make_long();
     gen("move.l","(sp)+","d0");  /* pop expression */ 
     gen("move.l","(sp)+","a0");  /* pop address */
     gen("move.l","d0","(a0)");   /* store expression */
    }
   }
  }
 }
 else
 /* *!<address> = <expr> */
 if (sym == singlepointer) 
 { 
  insymbol();
  if (expr() != longtype)  /* address */
     _error(4);
  else
  {
   if (sym != becomes)
      _error(5);
   else
   {
    insymbol();
    gen_Flt(expr());
    gen("move.l","(sp)+","d0");  /* pop expression */ 
    gen("move.l","(sp)+","a0");  /* pop address */
    gen("move.l","d0","(a0)");   /* store expression */
   }
  }
 }
 else
 /* feature not implemented? */  
 if (obj == rsvd_word) { _error(68); insymbol(); }
 else
 /* unknown */
 insymbol();
}
