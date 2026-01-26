/* << ACE >> 

   -- Amiga BASIC Compiler --

   ** Parser Variables ** 
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
     Date: 19th October-30th November, 3rd-12th December 1991,
	   14th,27th January 1992, 5th,7th-17th, 
           23rd-24th February 1992,
           14th,22nd March 1992,
	   21st April 1992,
	   2nd,11th,15th May 1992,
	   7th,8th,9th,11th,13th,14th,28th June 1992,
	   2nd-6th,8th,14th-19th,26th,28th,29th July 1992,
	   1st,9th August 1992,
	   6th,7th,22nd,28th December 1992,
	   28th February 1993,
	   6th,13th June 1993,
	   1st July 1993,
	   25th September 1993,
	   25th,26th October 1993,
	   2nd November 1993,
	   18th,25th December 1993,
	   2nd,5th January 1994,
	   12th June 1994,
	   19th,22nd August 1994,
	   11th March 1995
*/

#include "acedef.h"

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	int	obj;
extern	int	typ;
extern	int	errors;
extern	char   	id[MAXIDSIZE]; 
extern	char   	ut_id[MAXIDSIZE];
extern	SHORT  	shortval;
extern	LONG   	longval; 
extern	LONG   singleval;
extern	char   	stringval[MAXSTRLEN];
extern	SYM	*curr_item;
extern	SYM	*structdef_item;
extern	CODE	*curr_code;
extern	STRUCM	*curr_structmem;
extern	SHORT	dimsize[255];
extern	BOOL	end_of_source;
extern	FILE	*dest;
extern	char	ch;

char   string_const_start[7] = { 'd','c','.','b',' ','"','\0' };
char   string_const_end[4] = { '"',',','0','\0' };

/* --parser-- */
int  table_mem[2]={0,0};
int  addr[2]; 
int  lev;

char exit_sub_name[80];

ACELIBS acelib[NUMACELIBS],otherlib[NUMLIBS];

char librarybase[MAXIDSIZE+6];
char libraryname[MAXIDSIZE+20];
char bmapname[MAXIDSIZE+20];
BOOL restore_a4=FALSE;
BOOL restore_a5=FALSE;
CODE *exit_for_cx=NULL;

/* --expression type holders-- */
int  storetype,eqvtype,ortype,andtype,nottype,simptype;
int  modtype,idivtype,prodtype,negtype,exptype,factype;

/* --miscellaneous parser variables-- */
int  fstrcount=0;		/* PRINT format string counter */
int  strconstcount=0;           /* string constant counter */
int  strstorecount=0;           /* string storage counter */
int  stringvarcount=0;		/* string variable counter */
int  tempstrcount=0;	        /* temporary string store counter */
int  tempshortcount=0;		/* temporary short store counter */
int  templongcount=0;		/* temporary long store counter */
int  labelcount=0;              /* label counter */
int  arraycount=0;    		/* array counter */
int  structcount=0;		/* structure counter */
int  gttagcount=0;		/* GadTools tag array counter */
 	
char strstorename[80],strstorelabel[80];
char tempstrname[80],tempstrlabel[80];
char tempshortname[80],tempshortlabel[80];
char templongname[80],templonglabel[80];

char numbuf[80];                /* temporary ffp/int # buffer */
int  exitvalue=0;               /* compiler exit value */

BOOL mathffpused=FALSE;		/* are these libs/devs used? */
BOOL mathtransused=FALSE;       
BOOL dosused=FALSE;              
BOOL gfxused=FALSE;
BOOL intuitionused=FALSE;
BOOL translateused=FALSE;
BOOL narratorused=FALSE;

BOOL iffused=FALSE;		/* create+delete ILBM.library? */
BOOL gadtoolsused=FALSE;	/* GadTools gadgets used? */
BOOL oldgadgetused=FALSE;	/* old-style gadgets used? */

BOOL basdatapresent=FALSE;	/* DATA statement(s)? */
BOOL readpresent=FALSE;		/* READ statement(s)? */

BOOL cli_args=FALSE;		/* any CLI arguments? */

/* event trapping */
BOOL break_event=FALSE;
BOOL menu_event=FALSE;
BOOL mouse_event=FALSE;
BOOL timer_event=FALSE;
BOOL error_event=FALSE;
BOOL wdw_event=FALSE;
BOOL gad_event=FALSE;

BOOL break_event_label_exists=FALSE;
BOOL menu_event_label_exists=FALSE;
BOOL mouse_event_label_exists=FALSE;
BOOL timer_event_label_exists=FALSE;
BOOL error_event_label_exists=FALSE;
BOOL wdw_event_label_exists=FALSE;
BOOL gad_event_label_exists=FALSE;

char break_event_label[80];
char menu_event_label[80];
char mouse_event_label[80];
char timer_event_label[80];
char error_event_label[80];
char wdw_event_label[80];
char gad_event_label[80];

int  break_event_branch;
int  menu_event_branch;
int  mouse_event_branch;
int  timer_event_branch;
int  error_event_branch;
int  wdw_event_branch;
int  gad_event_branch;

float timer_event_seconds;
char  ontimer_seconds[40];
BOOL  ontimerused=FALSE;

/* compiler option flags */
BOOL break_opt=FALSE;		/* ctrl-c trapping */

BOOL optimise_opt=FALSE;	/* peephole optimisation */

BOOL make_icon=FALSE;		/* make icon for executable */

BOOL error_log=FALSE;		/* send all error messages to ace.err */

BOOL asm_comments=FALSE;	/* 
				** Make each ACE source line a comment
				** in the assembly source file.
				*/

BOOL list_source=FALSE;		/* 
				** List each line of source code as it is
				** being compiled. 
				*/

BOOL wdw_close_opt=FALSE;	/* window close trapping */

BOOL module_opt=FALSE;		/*
				** Determines whether A68K source file
				** is a code module or a complete ACE program.
				*/

BOOL cpu020_opt=FALSE;		/* 68020+ code generation */

/* misc. flags */
BOOL have_lparen=FALSE;
BOOL have_equal=FALSE;	        /* see assign() & push_indices() */

BOOL early_exit=FALSE;		/* set to TRUE if ctrl-c break detected */
