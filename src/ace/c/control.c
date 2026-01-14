/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: control constructs **
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
	   11th,12th,14th,15th,28th February 1993,
	   1st,3rd March 1993,
	   2nd,5th January 1994,
	   20th August 1994,
	   4th,9th September 1996
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };
static 	CODE	*option[255];

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	int	obj;
extern	int	typ;
extern	int  	lev;
extern	int	storetype;
extern	char   	id[MAXIDSIZE]; 
extern	SYM	*curr_item;
extern	CODE	*curr_code;
extern	CODE	*exit_for_cx;
extern	BOOL	end_of_source;
extern	BOOL	have_equal;
extern	BOOL	have_lparen;

/* functions */
void block_if(cx1)
CODE *cx1;
{
char labname1[80],lablabel1[80];
char labname2[80],lablabel2[80];
char labname3[80],lablabel3[80];
CODE *cx2;

 /* statement block after THEN */
 insymbol();
 do
 {
  statement();
 }
 while ((sym != elsesym) && (sym != endsym) && (!end_of_source));  
       /* ELSE or END IF */

   /* ELSE? */
   if (sym == elsesym)
   {
    gen("nop","  ","  ");  /* jump after THEN statement block */
    cx2=curr_code;

    /* execute ELSE code section if expression false */
    make_label(labname1,lablabel1);
    gen(lablabel1,"  ","  ");
    change(cx1,"jmp",labname1,"  ");
    
    insymbol();
    do
    {	
     statement();
    }
    while ((sym != endsym) && (!end_of_source));

    insymbol();
    if (sym == ifsym)
    {
     /* branch after THEN */
     make_label(labname2,lablabel2);
     gen(lablabel2,"  ","  ");
     change(cx2,"jmp",labname2,"  ");
     insymbol();
    }
    else _error(15);  /* END IF expected */
   }
   else  
       /* no ELSE */
       {
	insymbol();
	if (sym == ifsym)
        {
 	 make_label(labname3,lablabel3);
 	 gen(lablabel3,"  ","  ");
 	 change(cx1,"jmp",labname3,"  ");
	 insymbol();
        }
	else _error(15);  /* END IF expected */
       }
}   

void if_statement()
{
/* IF..THEN..ELSE..
   IF..GOTO..ELSE..
   IF..THEN..ELSE..END IF  [block IF]
*/
CODE *cx1,*cx2,*cx[3];
char labname1[80],lablabel1[80];
char labname2[80],lablabel2[80];
char labname3[80],lablabel3[80];
char labname4[80],lablabel4[80];
char buf[50],destbuf[3],idholder[50];
int  targettype=longtype;
int  i,oldobj,oldtyp;
int  exprtype;

 insymbol();
 exprtype=expr();

 /* make sure it's a LONG! */
 exprtype=make_integer(exprtype);
 for (i=0;i<=2;i++) 
 {
  gen("nop","  ","  ");
  cx[i]=curr_code;
 }
 coerce(&exprtype,&targettype,cx);
 
 if (exprtype == longtype)
 {
  if ((sym == thensym) || (sym == gotosym))
  {
   gen("move.l","(sp)+","d0");
   gen("cmpi.l","#0","d0");
   make_label(labname1,lablabel1);
   gen("bne.s",labname1,"  ");
   gen("nop","  ","  ");  /* jump past THEN code section */
   cx1=curr_code;
   gen(lablabel1,"  ","  "); /* execute THEN code */

  if (sym == gotosym) 
     statement();  /* IF..GOTO */
  else  /* IF..THEN */ 
  {	
   /* block-if, implied GOTO or assignment statement? */   
   insymbol();
   if (sym == endofline) { block_if(cx1); return; } /* block IF statement */
   
   if (sym==ident || sym==shortconst || sym==longconst)  /* label? */ 
   {
     /* assume implied GOTO at first */
     if (sym != ident) make_label_from_linenum(sym,id);
     strcpy(buf,id);
     strcat(buf,":\0");
 
     if (!exist(buf,label)) 
        strcpy(destbuf,"* "); /* mark for later label check (see sym.c) */
     else 
        strcpy(destbuf,"  "); /* it's a declared label */

     strcpy(idholder,id);  /* save info for possible "jmp" or assign */
     oldobj=obj;
     oldtyp=typ;

     insymbol();
    
     /* variable or array element or implicit branch? */
     if (lastsym != ident ||
        (lastsym == ident && 
         sym != equal && sym != lparen && sym != memberpointer)) 
     {
 	/* NOT an assignment statement */
	strcpy(id,idholder);  /* restore id */
    	gen("jmp",id,destbuf);
     }
     else 
       if (lastsym == ident)
       {
	/* assignment */
	strcpy(id,idholder); /* restore info for assign() */
	obj=oldobj;
	typ=oldtyp;
	if (sym == equal) have_equal=TRUE;
	if (sym == lparen) 
            if (!exist(id,array)) { _error(71); insymbol(); return; } 
	else
 	    have_lparen=TRUE;
 	assign();	   
	have_lparen=FALSE;
	have_equal=FALSE;
        if (sym == colon) statement();  /* multi-statement */
       }
    }
    else
       /* not an ident or line number */
       {
        statement();	
        if (sym == colon) statement();  /* multi-statement */
       }  
   } /* END THEN code */

   if (sym == elsesym)
   {
    gen("nop","  ","  ");  /* jump past ELSE code section */
    cx2=curr_code;

    /* execute ELSE code section if expression false */
    make_label(labname2,lablabel2);
    gen(lablabel2,"  ","  ");
    change(cx1,"jmp",labname2,"  ");
    
    insymbol();
    statement();
    if (sym == colon) statement();  /* multi-statement */

    /* unconditional branch after THEN */
    make_label(labname3,lablabel3);
    gen(lablabel3,"  ","  ");
    change(cx2,"jmp",labname3,"  ");
   }
   else
       {
 	make_label(labname4,lablabel4);
 	gen(lablabel4,"  ","  ");
 	change(cx1,"jmp",labname4,"  ");
       }
  }
   else _error(11);
 }
  else _error(4);
}   

void while_statement()
{
/* WHILE...WEND */
CODE *cx1,*cx2,*cx[3];
char labname1[80],lablabel1[80];
char labname2[80],lablabel2[80];
char labname3[80],lablabel3[80];
int  targettype=longtype;
int  i;
int  exprtype;

 make_label(labname1,lablabel1);
 gen(lablabel1,"  ","  ");
 cx1=curr_code;
 
 insymbol();
 exprtype=expr();

 /* make sure it's a LONG! */
 exprtype=make_integer(exprtype);
 for (i=0;i<=2;i++) 
 {
  gen("nop","  ","  ");
  cx[i]=curr_code;
 }
 coerce(&exprtype,&targettype,cx);  /* cx necessary if change from SHORT */

 if (exprtype == longtype)
 {
  gen("move.l","(sp)+","d0");
  gen("cmpi.l","#0","d0");
  make_label(labname2,lablabel2);
  gen("bne.s",labname2,"  "); 
  gen("nop","  ","  ");  /* jump out of loop when condition is FALSE */
  cx2=curr_code;
  gen(lablabel2,"  ","  ");  

  while ((sym != wendsym) && (!end_of_source)) statement();

  if (sym != wendsym) _error(12);

  check_for_event();

  gen("jmp",labname1,"  ");

  make_label(labname3,lablabel3);
  gen(lablabel3,"  ","  ");
  change(cx2,"jmp",labname3,"  ");
 }
 else _error(4);

 insymbol();
}

void repeat_statement()
{
/* REPEAT...UNTIL */
char labname1[80],lablabel1[80];
char labname2[80],lablabel2[80];
int  exprtype;

 make_label(labname1,lablabel1);
 gen(lablabel1,"  ","  ");

 insymbol();
 while ((sym != untilsym) && (!end_of_source)) statement();

 /* UNTIL condition */
 if (sym == untilsym)
 {
  check_for_event();
  insymbol();
  exprtype = make_integer(expr());
  if (exprtype == shorttype) { make_long(); exprtype=longtype; }

  if (exprtype == longtype)
  {
   gen("move.l","(sp)+","d0");
   gen("cmpi.l","#0","d0");
   make_label(labname2,lablabel2);
   gen("bne.s",labname2,"  ");
   gen("jmp",labname1,"  ");	/* loop until condition is TRUE */
   gen(lablabel2,"  ","  ");
  }
  else _error(4);
 }
 else _error(51);
}

void case_statement()
{
/* CASE...END CASE */
CODE  *cx;
CODE  *case_ptr[MAXCASES];
char  labname1[80],lablabel1[80];
char  labname2[80],lablabel2[80];
char  case_end_labname[80],case_end_lablabel[80];
SHORT casecount=0;
int   exprtype=undefined;
SHORT i;

 insymbol();
 while (sym == endofline) insymbol(); /* skip blank line(s) */
 
 do
 {
  exprtype = make_integer(expr());
  if (exprtype == shorttype) { make_long(); exprtype=longtype; }

  if (sym == colon) 
  {
   insymbol();
   
   if (exprtype == longtype)
   {
    gen("move.l","(sp)+","d0");
    gen("cmpi.l","#0","d0");
    make_label(labname1,lablabel1);
    gen("bne.s",labname1,"  "); 
    gen("nop","  ","  ");	/* try next case */
    cx = curr_code;
    gen(lablabel1,"  ","  ");   /* execute code for THIS case */
    
    statement();
    if (sym == colon) statement(); /* multi-statement */

    gen("jmp","  ","  ");
    case_ptr[casecount++] = curr_code; /* branch to end of CASE */
    
    /* label for next case */
    make_label(labname2,lablabel2);
    gen(lablabel2,"  ","  ");
    change(cx,"jmp",labname2,"  ");
   }
   else _error(4); /* type mismatch */
  }
  else _error(24); /* colon expected */

  while (sym == endofline) insymbol(); /* skip empty line(s) */
 }
 while ((exprtype == longtype) && (sym != endsym) &&
        (casecount < MAXCASES) && (!end_of_source));

 /* END CASE */
 if (sym != endsym) 
    _error(52);
 else 
 {
  insymbol();
  if (sym != casesym)
     _error(52);
  else
  {
   make_label(case_end_labname,case_end_lablabel);
   gen(case_end_lablabel,"  ","  ");
   for (i=0;i<casecount;i++) change(case_ptr[i],"jmp",case_end_labname,"  ");
   insymbol();
  }
 }
}

int for_assign(addr)
char *addr;
{
char numbuf[80];
SYM  *storage_item;
int  exprtype;
 
 /* does it exist? */
 if (!exist(id,obj)) 
    enter(id,typ,obj,0);

 storage_item = curr_item;

 /* don't allow a shared variable to be the index */
 if (storage_item->shared) { _error(70); insymbol(); return(undefined); }

 /* assign it */
 insymbol(); 
 if (sym == equal) 
 { 
  insymbol(); 
  exprtype = expr();

  /* can't use a stringtype! */
  if (exprtype == stringtype) { _error(4); return(undefined); }
  /* expression not successfully parsed */
  if (exprtype == undefined) { _error(0); return(undefined); } 

  storetype = assign_coerce(storage_item->type,exprtype);
  if (storetype == notype) 
     _error(4);   /* type mismatch */
  else
     {
      /* get address of object */ 
      itoa(-1*storage_item->address,addr,10);
      strcat(addr,frame_ptr[lev]);

      if (storage_item->type == shorttype)
      gen("move.w","(sp)+",addr);
      else
      /* longtype or singletype */
      gen("move.l","(sp)+",addr);
     }
 } 
 else _error(5); /* '=' expected */
 return(storage_item->type);  /* -> type for WHOLE for..next statement */
}

void for_statement()
{
/* FOR variable=x to y [STEP [+|-]z]
       Statement Block
   NEXT [variable]
*/
CODE *cx1,*cx2;
char labname1[80],lablabel1[80],labname2[80],lablabel2[80];
char labname3[80],lablabel3[80];
char counteraddr[10],limitaddr[10],stepaddr[10];
char for_id[50],cntbuf[10],limbuf[10],stpbuf[10];
int  countertype,limittype,steptype;

 /* counter */
 insymbol();
 if (sym != ident) { _error(7); return; }
 strcpy(for_id,id);
 countertype=for_assign(counteraddr);

 if (countertype == undefined) return;
 else
 {
  if (sym == tosym)
  {
   /* limit */
   insymbol();
   limittype=expr();
   limittype=assign_coerce(countertype,limittype);
   if (limittype == notype) { _error(4); return; }
   if (limittype == shorttype)
      strcpy(limitaddr,"2(sp)");
   else
      strcpy(limitaddr,"4(sp)");
   if (sym == stepsym)
   {
    /* step */
    insymbol();
    steptype=expr();
    steptype=assign_coerce(countertype,steptype);
    if (steptype == notype) { _error(4); return; }
   }
   else
   {
    switch(countertype)   /* default step = 1 */
    {
     case shorttype  : gen("move.w","#1","-(sp)"); break;
     case longtype   : gen("move.l","#1","-(sp)"); break;
     case singletype : gen("move.l","#$80000041","-(sp)"); break;
    }
    steptype=countertype;
   }
   strcpy(stepaddr,"(sp)");  /* step is on stack top */

    /* top of for..next loop */
    make_label(labname1,lablabel1);
    gen(lablabel1,"  ","  ");
    
    /* compare start & limit values */
    strcpy(cntbuf,counteraddr);
    strcpy(limbuf,limitaddr);
    strcpy(stpbuf,stepaddr);
   
    if (countertype == shorttype)
    {
     gen("move.w",cntbuf,"d0");   /* counter */
     gen("move.w",limbuf,"d1");   /* limit */
     gen("cmpi.w","#0",stepaddr);
     make_label(labname2,lablabel2);
     gen("blt",labname2,"  ");
     gen("cmp.w","d1","d0");
     gen("bgt","  ","  ");	  /* if STEP +ve -> counter>limit? */
     cx1=curr_code;
     make_label(labname3,lablabel3); /* don't want to do -ve step test too! */
     gen("jmp",labname3,"  ");
     gen(lablabel2,"  ","  ");
     gen("cmp.w","d1","d0");
     gen("blt","  ","  ");      /* if STEP -ve -> counter<limit? */
     cx2=curr_code;
     gen(lablabel3,"  ","  ");    /* label for bypassing -ve step test */
    }
    else
    if (countertype == longtype)
    {
     gen("move.l",cntbuf,"d0");   /* counter */
     gen("move.l",limbuf,"d1");   /* limit */
     gen("cmpi.l","#0",stepaddr);
     make_label(labname2,lablabel2);
     gen("blt",labname2,"  ");
     gen("cmp.l","d1","d0");
     gen("bgt","  ","  ");	  /* if STEP +ve -> counter>limit? */
     cx1=curr_code;
     make_label(labname3,lablabel3); /* don't want to do -ve step test too! */
     gen("jmp",labname3,"  ");
     gen(lablabel2,"  ","  ");
     gen("cmp.l","d1","d0");
     gen("blt","  ","  ");      /* if STEP -ve -> counter<limit? */
     cx2=curr_code;
     gen(lablabel3,"  ","  ");    /* label for bypassing -ve step test */
   }
    else
    if (countertype == singletype)
    { 
     gen("moveq","#0","d1");
     gen("move.l",stpbuf,"d0");   /* d0 < d1? (where d1=0) */
     gen("move.l","_MathBase","a6");
     gen("jsr","_LVOSPCmp(a6)","  ");
     enter_XREF("_MathBase");
     enter_XREF("_LVOSPCmp");
     make_label(labname2,lablabel2);
     gen("blt",labname2,"  ");  /* test result of ffp Cmp above */
     gen("move.l",cntbuf,"d0");   /* counter */
     gen("move.l",limbuf,"d1");   /* limit */
     gen("move.l","_MathBase","a6");
     gen("jsr","_LVOSPCmp(a6)","  ");
     gen("bgt","  ","  ");	  /* if STEP +ve -> counter>limit? */
     cx1=curr_code;
     make_label(labname3,lablabel3); /* don't want to do -ve step test too! */
     gen("jmp",labname3,"  ");
     gen(lablabel2,"  ","  ");
     gen("move.l",cntbuf,"d0");   /* counter */
     gen("move.l",limbuf,"d1");   /* limit */
     gen("move.l","_MathBase","a6");
     gen("jsr","_LVOSPCmp(a6)","  ");
     gen("blt","  ","  ");      /* if STEP -ve -> counter<limit? */
     cx2=curr_code;
     gen(lablabel3,"  ","  ");    /* label for bypassing -ve step test */
    }

    /* statement block */
    while ((sym != nextsym) && (!end_of_source)) statement();

    if (sym != nextsym) { _error(17); return; }

    /* NEXT -- legally followed by ident, colon or eoln! */
    insymbol();
    if (sym == ident)
    {
     if (strcmp(id,for_id) != 0) { _error(17); insymbol(); return; }
    }
    else
        if ((sym != endofline) && (sym != colon)) 
           { _error(17); insymbol(); return; } 

    if (sym != colon) insymbol();   /* return this sym to statement */

    /* counter=counter+step */
    switch(steptype)
    {
     case shorttype  : 	gen("move.w",stpbuf,"d0");
		     	gen("add.w","d0",counteraddr);
			break;
     case longtype   : 	gen("move.l",stpbuf,"d0");
		     	gen("add.l","d0",counteraddr);
			break;
     case singletype :  gen("move.l",stpbuf,"d0");
			gen("move.l",cntbuf,"d1");
			gen("move.l","_MathBase","a6");
			gen("jsr","_LVOSPAdd(a6)","  ");
			gen("move.l","d0",counteraddr);
     			enter_XREF("_MathBase");
     			enter_XREF("_LVOSPAdd");
			break;
    }

    check_for_event();

    gen("jmp",labname1,"  ");  /* back to top of loop */

    make_label(labname3,lablabel3);
    gen(lablabel3,"  ","  ");

    /* POP the step & limit from stack */ 
    if (countertype == shorttype)
       gen("addq","#4","sp");
    else
       gen("addq","#8","sp");

    change(cx1,"bgt",labname3,"  ");
    change(cx2,"blt",labname3,"  ");

    /* EXIT FOR branch code pointer non-NULL? */
    if (exit_for_cx) 
    {
	change(exit_for_cx,"jmp",labname3,"  ");
	exit_for_cx = NULL;
    }
   }
  }
}

void on_branch()
{
char numbuf[40];
char lab[80],lablabel[80];
int  branch;
int  btype;
long i,opt=0;

/* ON <integer-expression> GOTO | GOSUB <label> | <line> */

 btype=expr();
 if (btype == stringtype) _error(4);
 else
 {
  if (make_integer(btype) == shorttype) make_long();  /* on stack */

  if (sym != gotosym && sym != gosubsym) _error(56);
  else
  { 
   branch = sym;  /* GOTO or GOSUB */

   do
   {
    insymbol();
    /* label or line-number? */
    if (sym != ident && sym != shortconst && sym != longconst)
       _error(57); 
    else   
    {
     if (sym != ident) make_label_from_linenum(sym,id);

     opt++;

     sprintf(numbuf,"#%ld",opt);  
     gen("cmpi.l",numbuf,"(sp)");
     make_label(lab,lablabel);
     gen("bne.s",lab,"  ");  /* is opt equal to value on stack? */

     gen("addq","#4","sp");  /* remove value from stack before branch */

     switch(branch)
     {
      case gotosym  : gen_branch("jmp",id); 
		      break;

      case gosubsym : gen_branch("jsr",id);
		      gen("nop","  ","  ");  /* jump to end of choices */
		      option[opt-1] = curr_code;
		      break;
     }

     gen(lablabel,"  ","  ");
    }

    insymbol();
   }
   while (sym == comma);
  }

  /* if ON..GOSUB -> branch to end of all choices after GOSUB */
  if (branch == gosubsym && opt > 0) 
     for (i=0;i<opt;i++) change(option[i],"jmp",lab,"  ");
 }
}

void block_statement()
{
/*
** BLOCK..END BLOCK
*/
	insymbol(); 
	while (sym == endofline) insymbol(); /* skip blank line(s) */	

	while ((sym != endsym) && (!end_of_source)) statement();

	if (sym != endsym) 
    		_error(80);
 	else 
 	{
  		insymbol();
  		if (sym != blocksym) 
			_error(80);
		else
			insymbol();
	}
}
