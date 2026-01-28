/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: miscellaneous functions **
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
	   12th February 1993,
	   1st March 1993,
	   20th,30th June 1993,
	   1st,2nd July 1993,
	   26th October 1993,
	   14th,16th,17th,24th,25th December 1993,
	   2nd,5th,7th-9th,13th,14th January 1994,
	   6th,7th,15th,16th,26th,27th February 1994,
	   4th,13th,30th April 1994,
	   14th,15th May 1994,
	   12th,21st,22nd,25th June 1994,
	   10th,14th,24th July 1994,
	   3rd,22nd August 1994,
	   2nd,3rd,10th September 1994,
	   6th October 1995
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	BOOL	report_errors;
extern	int	sym;
extern	int	lastsym;
extern	int	lev;
extern	SHORT	shortval;
extern	LONG	longval;
extern	char   	id[MAXIDSIZE]; 
extern	char   	ut_id[MAXIDSIZE]; 
extern	char	lastline[MAXLINELEN];
extern	char   	string_const_start[7];
extern	char   	string_const_end[4];
extern	BOOL	have_lparen;
extern	BOOL	end_of_source;
extern	BOOL	break_opt;
extern	BOOL	asm_comments;
extern	BOOL	error_log;
extern	BOOL	make_icon;
extern	BOOL	list_source;
extern	BOOL	optimise_opt;
extern	BOOL	wdw_close_opt;
extern	BOOL	module_opt;
extern	BOOL	cpu020_opt;
extern	FILE	*err_log;
extern	int	idtype[31];
extern	int  	strconstcount;
extern	int  	tempstrcount;
extern	int  	tempshortcount;
extern	int  	templongcount;
extern	char 	tempstrname[80],tempstrlabel[80];
extern	char 	tempshortname[80],tempshortlabel[80];
extern	char 	templongname[80],templonglabel[80];

/* redefine ZC's CTRL-C testing function to do nothing */ 
long	Chk_Abort() { return 0; }

/* functions */
void make_temp_long()
{
 /* make a long integer BSS object for temporary storage
    of actual value parameters */
char numbuf[40],storesize[40];

 itoa(templongcount++,numbuf,10);
 strcpy(templongname,"_templong");
 strcat(templongname,numbuf);

 strcpy(templonglabel,templongname);
 strcat(templonglabel,":\0");

 strcpy(storesize,"ds.l 1 ");
 enter_BSS(templonglabel,storesize);
}

void make_temp_short()
{
 /* make a short integer BSS object for temporary storage
    of actual value parameters */
char numbuf[40],storesize[40];

 itoa(tempshortcount++,numbuf,10);
 strcpy(tempshortname,"_tempshort");
 strcat(tempshortname,numbuf);

 strcpy(tempshortlabel,tempshortname);
 strcat(tempshortlabel,":\0");

 strcpy(storesize,"ds.l 1 ");
 enter_BSS(tempshortlabel,storesize);
}

void make_temp_string()
{
/* need a unique BSS string store for ALL string functions to prevent 
   overwriting of string data */
char numbuf[40],sizebuf[40],storesize[40];

 itoa(tempstrcount++,numbuf,10);
 strcpy(tempstrname,"_tempstring");
 strcat(tempstrname,numbuf);

 strcpy(tempstrlabel,tempstrname);
 strcat(tempstrlabel,":\0");

 strcpy(storesize,"ds.b ");
 itoa(MAXSTRLEN,sizebuf,10);
 strcat(storesize,sizebuf);
 enter_BSS(tempstrlabel,storesize);
}

void make_string_const(string)
char *string;
{
char *strbuf,buf[80],strlabel[80],strname[80];

 itoa(strconstcount++,buf,10);
 /* label for DATA section */
 strcpy(strlabel,"_stringconst");
 strcat(strlabel,buf);
 /* name for reference in code */
 strcpy(strname,strlabel);
 /* complete string label */
 strcat(strlabel,":\0");
 /* actual string constant */
 strbuf=(char *)alloc(strlen(string)+10,MEMF_ANY); 
                             /* +10 is for string_const_start/end (9) & '\0' */ 
 strcpy(strbuf,string_const_start);
 strcat(strbuf,string);
 strcat(strbuf,string_const_end);
 enter_DATA(strlabel,strbuf);
 /*FreeMem(strbuf,strlen(string)+10);*/
 /* push its address onto stack */
 gen("pea",strname,"  ");
}

void make_label_from_linenum(intconst,buf)
int  intconst;
char *buf;
{
/* turns a line number into a label */

 switch(intconst)
 {
  case shortconst : sprintf(buf,"_LINE%d",shortval); break;
  case longconst  : sprintf(buf,"_LINE%ld",longval); break;
 }
}

LONG max_array_ndx(curr)
SYM *curr;
{
/* Returns # of linear elements in an array.
   eg: DIM X(10,10) yields 121 elements: 0..10, 0..10 -> 11 * 11 
*/
int  i;
LONG max=1;

 for (i=curr->dims;i>=0;i--) max *= curr->index[i];
 return(max);
}

void push_indices(curr)
SYM *curr;
{
/* put array indices onto stack */
int ndxcount=0;

 if (!have_lparen) 
    insymbol(); 
 else 
    have_lparen=FALSE; /* don't want to leave this as TRUE, else if
			  push_indices() called from factor() etc, 
			  insymbol() won't be called here! */
 if (sym != lparen)
    _error(14);
 else
 {
  do
  {
   insymbol();
   make_sure_short(expr());
   ndxcount++;
  }
  while ((sym == comma) && (ndxcount <= curr->dims));
  
  /* too few indices: comma expected (ndxcount should now be > curr->dims) */
  if (ndxcount <= curr->dims) _error(16);  

  /* too many indices or syntax error */
  if (sym != rparen) _error(9);  
 }
}
  
void get_abs_ndx(curr)
SYM *curr;
{
/* calculate absolute pointer into array from multiple dimensions */
int  i,ndx_mult=1;
char mulbuf[40],srcbuf[40];

 gen("moveq","#0","d7");
 
 /* pop indices from stack one at a time */ 
 for (i=curr->dims;i>=0;i--)
 {
  sprintf(mulbuf,"#%ld",ndx_mult);

  gen("move.w","(sp)+","d1");  	 
  gen("ext.l","d1","  "); 
  gen("move.l","d1","-(sp)");   /* push next index after coercing to long */
  gen("move.l",mulbuf,"-(sp)"); /* push cumulative index */
  gen("jsr","lmulu","  ");
  gen("add.l","#8","sp");
  
  gen("add.l","d0","d7");  
  ndx_mult *= curr->index[i];
 }

 /* multiply offset by data type size */
 if (curr->type == stringtype)
 {
  /* multiply d7 (containing absolute index) by string element size */

  /* #string_element_size */
  sprintf(srcbuf,"#%ld",curr->numconst.longnum);

  /* calculate absolute offset */  
  gen("move.l","d7","-(sp)");
  gen("move.l",srcbuf,"-(sp)");
  gen("jsr","lmulu","  ");	/* d7*MAXSTRLEN */
  gen("add.l","#8","sp");
  gen("move.l","d0","d7");
 }
 else
 if (curr->type == shorttype)
    gen("lsl.l","#1","d7");  /* d7*2 */
 else
    /* long or single */
    gen("lsl.l","#2","d7");  /* d7*4 */

 /* unsigned multiplication XREF */
 enter_XREF("lmulu");
}

void push_num_constant(typ,item)
int typ;
SYM *item;
{
/* push a numeric
   constant onto 
   the stack. 
*/
char buf[40],numbuf[40];

 strcpy(numbuf,"#\0");
 switch(typ)
 {
  case shorttype  : itoa(item->numconst.shortnum,buf,10); break;
  case longtype   : ltoa(item->numconst.longnum,buf,10); break;
  case singletype : sprintf(buf,"%lx",item->numconst.singlenum);
                    strcat(numbuf,"$");
  		    break;
 }

 strcat(numbuf,buf);

 if (typ == shorttype)
    gen("move.w",numbuf,"-(sp)");
 else
    gen("move.l",numbuf,"-(sp)");
}

int push_struct(item)
SYM *item;
{
/* push either the address of 
   a structure variable or the
   value of one of its members.
*/
SYM    *structype;
char   addrbuf[40],absbuf[40],numbuf[40];
STRUCM *member;
BOOL   found=FALSE;
int    mbr_type=undefined;

 insymbol();

 if (sym == memberpointer)
 {
  /* push value of a member */
  structype = item->other;  /* pointer to structure type definition */

  insymbol();

  if (sym != ident) 
     _error(7);
  else
  {
   /* does member exist? */
   member = structype->structmem->next;
   while ((member != NULL) && (!found)) 
   {
    if (strcmp(member->name,id) == 0)
       found=TRUE;
    else
       member = member->next;
   }
   
   /* dereference it? */
   if (!found) 
      _error(67);  /* not a member! */
   else
   {
    /* save member type */
    mbr_type = member->type;

    /* address of structure */
    itoa(-1*item->address,addrbuf,10);
    strcat(addrbuf,frame_ptr[lev]);

    if (item->shared && lev == ONE)
    {
       gen("movea.l",addrbuf,"a0");  /* struct variable address */
       gen("movea.l","(a0)","a0");   /* start address of struct */    	
    }
    else
        gen("movea.l",addrbuf,"a0"); /* start address of struct */

    /* offset from struct start */ 
    if (mbr_type != stringtype)
    {
     ltoa(member->offset,absbuf,10);
     strcat(absbuf,"(a0)");
    }

    /* push value */
    if (mbr_type == bytetype)
    {
     gen("move.b",absbuf,"d0");
     gen("ext.w","d0","  ");
     gen("move.w","d0","-(sp)");
     mbr_type=shorttype;              /* byte */
    }
    else
    if (mbr_type == shorttype)
       gen("move.w",absbuf,"-(sp)");  /* short */
    else
    if (mbr_type == stringtype)
    {
     sprintf(numbuf,"#%ld",member->offset);
     gen("adda.l",numbuf,"a0");
     gen("move.l","a0","-(sp)");  /* push string address */
    }
    else
       gen("move.l",absbuf,"-(sp)");  /* long, single */ 
   }
  }
  insymbol();
  return(mbr_type);
 }
 else
 {
  /* push address of structure */
  itoa(-1*item->address,addrbuf,10);
  strcat(addrbuf,frame_ptr[lev]);

  if (item->shared && lev == ONE) 
  {
     gen("movea.l",addrbuf,"a0"); /* address of structure variable */
     gen("move.l","(a0)","-(sp)");  /* start address of structure */
  }
  else
      gen("move.l",addrbuf,"-(sp)");

  return(longtype);
 }
}

void change_id_type(newtype)
int newtype;
{
int i,first,last;

 /* 
 ** Change the data type of a range.
 **
 ** Note that "A-_" is acceptable
 ** since ASC("_") > ASC("Z"). 
 */
 do
 {
  insymbol();
  if (sym == ident) first=id[0]-'A'; else _error(7);
  insymbol();
  if (sym == minus)
  {
   /* range */
   insymbol();
   if (sym == ident) last=id[0]-'A'; else _error(7);
   if (first > last) 
      	_error(31);
   else
   	for (i=first;i<=last;i++) idtype[i]=newtype;
   insymbol();
  }
  else
  /* just a single one (letter or underscore) */
  idtype[first]=newtype;
 }
 while (sym == comma);
}

void gen_branch(branch,labname)
char *branch,*labname;
{
char lablabel[MAXIDSIZE+1],destbuf[3];

 /* generate a jsr/jmp instruction */

 sprintf(lablabel,"%s:",labname);

 if (!exist(lablabel,label))
    strcpy(destbuf,"* ");  /* for later check */
 else
    strcpy(destbuf,"  ");  /* label already defined */

 gen(branch,labname,destbuf);
}

void assem()
{
/* 
** ASSEM..END ASSEM -- inline assembly code inclusion.
*/

 report_errors = FALSE;	/* suppress "unknown symbol" errors. */

 do
 {
  insymbol();

  /* generate code? */
  if (sym == endofline && !end_of_source &&
      lastsym != assemsym) gen(lastline,"  ","  ");  
 }
 while (sym != endsym && !end_of_source);

 insymbol();
 if (sym != assemsym) _error(73);
 else
     insymbol();

 report_errors = TRUE;
}

void parse_option_list()
{
char letter;
BOOL activate;
/* OPTION <switch>+|-[,<switch>+|-..] */

  do
  {
   insymbol();

   if ((sym == ident && strlen(ut_id) == 1) ||
       (sym == shortconst && shortval >= 0 && shortval <= 9))
   {
    if (sym == ident)
       letter=ut_id[0];
    else
       letter='0'+(char)shortval;

    insymbol();
    if (sym == plus || sym == minus)
    {
     switch(sym) 
     {
      case plus  : activate=TRUE; break;
      case minus : activate=FALSE; break; 
     }

     switch(letter)
     {
      case 'b' : break_opt=activate; break;
      case 'c' : asm_comments=activate; break;
      case 'E' : if (activate && !error_log)
	         {
	 	  err_log = fopen("ace.err","w");
		  if (err_log == NULL) 
		     puts("Unable to open error log: ace.err!");
		  else
		      error_log=TRUE;
	         }
		 else
		 if (!activate && error_log)
		 {
		  if (err_log) 
		  { 
		   fclose(err_log);
		   err_log=NULL;
		   error_log=FALSE;
		  }
		  else
		      puts("Error log: ace.err not open!");
		 }
	         break;
      case 'i' : make_icon=activate; break;
      case 'l' : list_source=activate; break;
      case 'm' : module_opt=activate; break;
      case 'O' : optimise_opt=activate; break;
      case 'w' : wdw_close_opt=activate; break;
      case '2' : cpu020_opt=activate; break;

      default  : _error(74); break;
     }
    }
    else _error(74);
   }
   else _error(74);  /* compiler directive expected */

   insymbol();
  }
  while (sym == comma);
}

void MsgBox()
{
/*
** MsgBox _statement_.
**
**	MSGBOX <message>,<button-text>
**
** See also basfun.c for MsgBox *function*. 
*/

	insymbol();
	
	if (expr() != stringtype)     /* message */
		_error(4);
	else
	{
   		if (sym != comma)
      			_error(16);
   		else
   		{
    			insymbol();
    			if (expr() != stringtype)  /* response text */
				_error(4);
			else
        		{
				/* no second button! (pass NULL) */
	     			gen("move.l","#0","-(sp)");
		     
	    			/* call the function */
	    			gen("jsr","_sysrequest","  ");
	    			gen("add.l","#12","sp");
	    			enter_XREF("_sysrequest");
	    			enter_XREF("_IntuitionBase");
	   		}
	  	}
	 }
}
