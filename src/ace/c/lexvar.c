/* << ACE >> 

   -- Amiga BASIC Compiler --

   ** Lexical Analyser Variable Declarations ** 
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
	   6th,22nd,27th-29th December 1992,
	   2nd,14th February 1993,
	   6th June 1993,
	   1st July 1993,
	   5th,26th September 1993,
	   26th October 1993,
	   17th,24th,26th December 1993,
	   2nd,3rd January 1994,
	   6th February 1994,
	   10th July 1994,
	   22nd August 1994,
	   6th October 1995,
	   22nd June 1996,
	   4th September 1996
*/

#include "acedef.h"

/* globals */
BOOL	report_errors = TRUE;	/* eg. see assem() in misc.c */

/* externals */
extern	ACELIBS	acelib[NUMACELIBS],otherlib[NUMLIBS];

extern	int 	exitvalue;

extern	BOOL 	early_exit;
extern	BOOL	error_log;
extern	BOOL	asm_comments;
extern	BOOL	list_source;

/* sorted list of reserved words */
char *rword[] = 
  { 
    /* AmigaBASIC reserved words */
    "ABS","ALL","AND","APPEND","AREA","AREAFILL",
    "AS","ASC","ATN","BASE","BEEP","BREAK","CALL","CDBL",
    "CHAIN","CHDIR","CHR$","CINT","CIRCLE","CLEAR","CLNG",
    "CLOSE","CLS","COLLISION","COLOR","COMMON","CONT",
    "COS","CSNG","CSRLIN","CVD","CVI","CVL","CVS","DATA",
    "DATE$","DECLARE","DEF","DEFDBL","DEFINT","DEFLNG",
    "DEFSNG","DEFSTR","DELETE","DIM","ELSE","ELSEIF","END",
    "EOF","EQV","ERASE","ERL","ERR","ERROR","EXIT","EXP",
    "FIELD","FILES","FIX","FN","FOR","FRE","FUNCTION",
    "GET","GOSUB","GOTO","HEX$","IF","IMP","INKEY$",
    "INPUT","INPUT$","INSTR","INT","KILL","LBOUND","LEFT$",
    "LEN","LET","LIBRARY","LINE","LIST","LLIST","LOAD","LOC",
    "LOCATE","LOF","LOG","LPOS","LPRINT","LSET","MENU","MERGE",
    "MID$","MKD$","MKI$","MKL$","MKS$","MOD","MOUSE","NAME",
    "NEW","NEXT","NOT","OBJECT.AX","OBJECT.AY","OBJECT.CLIP",
    "OBJECT.CLOSE","OBJECT.HIT","OBJECT.OFF","OBJECT.ON",
    "OBJECT.PLANES","OBJECT.PRIORITY","OBJECT.SHAPE",
    "OBJECT.START","OBJECT.STOP","OBJECT.VX","OBJECT.VY",
    "OBJECT.X","OBJECT.Y","OCT$","OFF","ON","OPEN","OPTION","OR",
    "OUTPUT","PAINT","PALETTE","PATTERN","PEEK","PEEKL","PEEKW",
    "POINT","POKE","POKEL","POKEW","POS","PRESET","PRINT","PSET",
    "PTAB","PUT","RANDOMIZE","READ","REM","RESTORE","RESUME",
    "RETURN","RIGHT$","RND","RSET","RUN","SADD","SAVE","SAY",
    "SCREEN","SCROLL","SGN","SHARED","SIN","SLEEP","SOUND",
    "SPACE$","SPC","SQR","STATIC","STEP","STICK","STOP","STR$",
    "STRIG","STRING$","SUB","SWAP","SYSTEM","TAB","TAN","THEN",
    "TIME$","TIMER","TO","TRANSLATE$","TROFF","TRON","UBOUND",
    "UCASE$","USING","VAL","VARPTR","WAIT","WAVE","WEND","WHILE",
    "WIDTH","WINDOW","WRITE","XOR",

    /* ACE-specific reserved words */
    "ADDRESS","ALLOC","ARG$","ARGCOUNT","ASSEM","ASSERT","BACK","BEVELBOX","BIN$",
    "BIND","BLOCK","BUTTON","BUTTON_KIND","BYTE",
    "CASE","CHECKBOX_KIND","CHIPSET","CONST","CSTR","CYCLE_KIND",
    "DAY","EXTERNAL","FILEBOX$",
    "FONT","FORWARD","GADGET","GETATTR","GLOBAL","HANDLE","HEADING","HOME","IFF","INPUTBOX",
    "INPUTBOX$","INTEGER_KIND","INVOKE","LISTVIEW_KIND","LONGINT",
    "MESSAGE","MSGBOX","MX_KIND","NUMBER_KIND","PALETTE_KIND",
    "PENDOWN","PENUP","POTX",
    "POTY","PRINTS","REPEAT","SCROLLER_KIND","SERIAL","SETATTR","SETHEADING","SETXY","SHL",
    "SHORTINT","SHR","SINGLE","SIZE","SIZEOF","SLIDER_KIND",
    "STRING","STRING_KIND","STRUCT","STYLE","TEXT_KIND","TURN",
    "TURNLEFT","TURNRIGHT","TURTLE","UNTIL","XCOR","YCOR",

    "SENTINEL" };

/* reserved symbols */
char *rsym[] = 
  { "++","--","*%","*&","*!","->","+\0","-\0","*\0","/\0","\\\0","^\0",
    "(\0",")\0",",\0","'\0",";\0",":=",":\0","?\0","<>","<=",">=",
    "=\0","<\0",">\0","#\0","&O","&H","@\0","eoln\0","SENTINEL" };

/* special characters (for reserved symbols) */
char spec_sym[] = "=+-*/\\^(),.';:?<>@";

/* other symbols apart from reserved words */
char *symbol[] = { "shortconst","longconst","singleconst","doubleconst",
                   "stringconst","ident" };

/* objects */
char *object[] = { "variable","array","subprogram","function","extfunc",
                   "extvar","label","constant","structdef","structure",
		   "reserved word" };

/* data types */
char *type[] = { "bytetype","shorttype","longtype","singletype","doubletype",
                 "stringtype","notype" };

/* --character handler-- */
char   *srcfile,*destfile;	 /* source and destination file names */
FILE   *src;                     /* source file handle */
FILE   *dest;                    /* object file handle */
int    column,linelen;           /* current column & length of char buffer */ 
int    lineno=0;                 /* current line of source */
int    errors=0;                 /* # of errors generated */
char   line[MAXLINELEN];         /* Nth line buffer */
char   lastline[MAXLINELEN];  	 /* (N-1)th line buffer */
char   ch=' ';                   /* last character returned by nextch */
char   ut_ch; 			 /* same as ch, but not forced to upper case */
BOOL   end_of_source=FALSE;      /* indicates whether EOF reached */
BOOL   std_in=FALSE;		 /* is source file stdin? (used for testing) */
   
/* --scanner-- */
FILE   *err_log;		 /* error log file */
int    sym=undefined;		 /* last symbol returned by scanner */
int    lastsym;                  /* symbol from LAST scanner call */
int    obj;            		 /* kind of object (label,variable...) */
int    typ;                      /* type (short,long,string...) */
char   id[MAXIDSIZE];            /* identifier */
char   ut_id[MAXIDSIZE];	 /* untouched identifier for DATA statement */ 
char   stringval[MAXSTRLEN];     /* string literal */
SHORT  shortval;                 /* short literal */
LONG   longval;                  /* long literal */
LONG  singleval;                /* single precision literal */
double doubleval;                /* double precision literal */ 
SHORT  dimsize[255];		 /* array indices holder */

int    idtype[31]; 		 /* 
				 ** Type of ident starting with a given letter 
				 ** or an underscore which is ASCII 95, hence
				 ** 31 positions: 0..25 = A..Z and 30 = "_"
				 ** 
				 ** Although positions 26..29 are wasted,
				 ** this scheme is elegant.
				 **
				 ** The default datatype is SINGLE.
				 */
