/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Lexical Analyser **
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
     Date: 18th October-30th November, 1st-13th December 1991,
    	   14th,20th,26th January 1992, 
           2nd-17th, 23rd-24th February 1992,
	   21st April 1992,
	   7th,11th,13th June 1992,
	   2nd,3rd,4th,5th,8th,14th,15th,16th,19th,26th,28th,29th July 1992,
	   2nd,8th August 1992,
	   6th,22nd,27th-30th December 1992,
	   4th,5th,7th,19th,31st January 1993,
	   2nd,6th,11th-15th,19th,28th February 1993,
	   1st,24th March 1993,
	   12th,17th April 1993,
	   6th,13th June 1993,
	   1st,2nd,10th July 1993,
	   5th,26th September 1993,
	   15th November 1993,
	   14th,16th,17th,25th,26th December 1993,
	   2nd,5th,7th-9th January 1994,
	   7th,15th February 1994,
	   20th,22nd,28th August 1994,
	   4th,10th,11th September 1994,
	   7th August 1995,
	   6th October 1995,
	   10th March 1996,
	   11th June 1996,
	   4th September 1996
*/

#include "lexvar.c"

/* globals */
ULONG 	MathBase = NULL;
ULONG 	MathTransBase = NULL;
ULONG	IntuitionBase = NULL;
BOOL 	inside_string = FALSE;	/* see last line of nextch() */

/* functions */
void open_shared_libs()
{
 if ((MathBase = OpenLibrary("mathffp.library",0)) == NULL) 
 {
  printf("Unable to open mathffp.library!\n");
  exit(10);
 }

 if ((MathTransBase = OpenLibrary("mathtrans.library",0)) == NULL)
 {
  printf("Unable to open mathtrans.library!\n");
  exit(10);
 }

 if ((IntuitionBase = OpenLibrary("intuition.library",0)) == NULL)
 {
  printf("Unable to open intuition.library!\n");
  exit(10);
 }
}

void close_shared_libs()
{
 if (IntuitionBase != NULL) CloseLibrary(MathTransBase);
 if (MathTransBase != NULL) CloseLibrary(MathTransBase);
 if (MathBase != NULL) CloseLibrary(MathBase);
}
 
void setup()
{
int i;

 /* initialize nextch() variables */
 column=linelen=-1; 
 line[0]='\0';
 
 /* 
 ** All id's default to singletype (A..Z + "_" 
 ** with 4 bytes wasted between Z and "_").
 */ 
 for (i=0;i<=30;i++) idtype[i]=singletype; 

 /* libraries used by ACE */
 strcpy(acelib[0].name,"DOS");
 strcpy(acelib[0].base,"_DOSBase");
 strcpy(acelib[1].name,"INTUITION");
 strcpy(acelib[1].base,"_IntuitionBase");
 strcpy(acelib[2].name,"GRAPHICS");
 strcpy(acelib[2].base,"_GfxBase");
 strcpy(acelib[3].name,"MATHFFP");
 strcpy(acelib[3].base,"_MathBase");
 strcpy(acelib[4].name,"MATHTRANS");
 strcpy(acelib[4].base,"_MathTransBase");
 strcpy(acelib[5].name,"TRANSLATOR");
 strcpy(acelib[5].base,"_TransBase");
 /* sentinel ACE library entry */
 strcpy(acelib[6].name,"SENTINEL");
 
 /* make "other library" entries null */ 
 for (i=0;i<NUMLIBS-1;i++)
 {
	otherlib[i].name[0] = '\0';
	otherlib[i].base[0] = '\0';
 }
 /* sentinel for "other libraries" */
 strcpy(otherlib[NUMLIBS-1].name,"SENTINEL");

 /* open error log? */
 if (error_log)
 {
  err_log = fopen("ace.err","w");
  if (err_log == NULL) 
     { puts("Unable to open error log: ace.err!"); exit(10); }
 }
}

void cleanup()
{
 /* close files */
 if (!std_in && src != NULL) fclose(src);
 if (dest != NULL) fclose(dest);
 if (err_log != NULL) fclose(err_log);

 free_alloc();
 
 close_shared_libs();

 /* exit with return value */
 if (early_exit) exitvalue=10;
 exit(exitvalue);
}

void _warn(n)
int n;
{
char *msg;

 printf("Warning: ");
 if (error_log) fprintf(err_log,"Warning: ");

 switch(n)
 {
  case 0 : /* dummy */ break;
  case 1 : msg="Exponent out of range"; break;
 }
 printf("%s",msg);
 if (error_log) fprintf(err_log,"%s",msg);
 printf(" in line %d.\n",lineno);
 if (error_log) fprintf(err_log," in line %d.\n",lineno);
}

void _error(n)
int n;
{
int  i,spot,badline,length;
char *msg;

 /* display an error and the line in which it occurs */

 if (!report_errors) return;	/* eg. see assem() in misc.c */

 if (n > 1 && n != 8)
 {
  if (n!=12 && n!=15 && n!=17 && n!=25 && n!=34 && 
      n!=51 && n!=52 && n!=64 && n!=73)
  {
   /* show the offending line */
   if (column != 0)
   {
    length=strlen(line);
    if (length > 0) 
    {
     printf("\n%s\n",line); 
     if (error_log) fprintf(err_log,"\n%s\n",line);
     spot=column;
    }
    badline=lineno;
   }
   else
   {
    length=strlen(lastline);
    if (length > 0) 
    {
     printf("\n%s\n",lastline);
     if (error_log) fprintf(err_log,"\n%s\n",lastline); 
     spot=length;
    }
    badline=lineno-1;
   }
     
   if (length > 0)
   {
    /* point to the error */
    for (i=1;i<spot;i++) { putchar(' '); if (error_log) fputc(' ',err_log); }
    printf("^\n");
    if (error_log) fprintf(err_log,"^\n");    
   }

   /* ignore rest of line */
   column=linelen;
   ch=' ';   /* force a call to nextch() when insymbol() next invoked */
  }
  else
  {
   putchar('\n');
   if (error_log) fputc('\n',err_log);
   badline=lineno;
  }

  printf("** ");
  if (error_log) fprintf(err_log,"** ");

  if (!early_exit) early_exit=TRUE;
 }

 switch(n)
 {
  case 0  : /* dummy */ break;
  case 1  : msg="Unexpected end of source\n"; break;
  case 2  : msg="Unknown symbol"; break;
  case 3  : msg="Decimal digit expected"; break;
  case 4  : msg="Type mismatch"; break;
  case 5  : msg="'=' expected"; break;
  case 6  : msg="Duplicate label"; break;
  case 7  : msg="Identifier expected"; break;
  case 8  : msg="\nUndefined label: "; break;
  case 9  : msg="')' expected"; break;
  case 10 : msg="Expression expected"; break;
  case 11 : msg="IF without THEN"; break;
  case 12 : msg="WHILE without WEND"; break;
  case 13 : msg="Illegal expression"; break;
  case 14 : msg="'(' expected"; break;
  case 15 : msg="IF without END IF"; break;
  case 16 : msg="',' expected"; break;
  case 17 : msg="FOR without NEXT"; break;
  case 18 : msg="String constant expected"; break;
  case 19 : msg="Variable expected"; break;
  case 20 : msg="'b' or 'bf' expected"; break;
  case 21 : msg="'-' expected"; break;
  case 22 : msg="Array already dimensioned"; break;
  case 23 : msg="Illegal array index"; break;
  case 24 : msg="Illegal use of identifier"; break;
  case 25 : msg="READ without DATA"; break;
  case 26 : msg="Constant expected"; break;
  case 27 : msg="Numeric constant expected"; break;
  case 28 : msg="Short integer array expected"; break;
  case 29 : msg="Radius expected"; break;
  case 30 : msg="No start angle specified"; break;
  case 31 : msg="Illegal letter-range"; break;
  case 32 : msg="Subprogram name expected"; break;
  case 33 : msg="Duplicate subprogram/function name"; break;
  case 34 : msg="SUB without END SUB"; break;
  case 35 : msg="SUB expected"; break;
  case 36 : msg="EXIT SUB illegal outside subprogram"; break;
  case 37 : msg="CALL to undeclared subprogram"; break;
  case 38 : msg="Parameter already declared"; break;
  case 39 : msg="Parameter count mismatch"; break;
  case 40 : msg="Object cannot be shared"; break;
  case 41 : msg="Zero or negative string size"; break;
  case 42 : msg="Too many parameters in SUB"; break;
  case 43 : msg="Invalid object"; break;
  case 44 : msg="'#' expected"; break;
  case 45 : msg="Library already open"; break;
  case 46 : msg="Library not open"; break;
  case 47 : msg="FUNCTION expected"; break;
  case 48 : msg="LIBRARY expected"; break;
  case 49 : msg="Unknown library function"; break;
  case 50 : msg="Can't open bmap file"; break;
  case 51 : msg="REPEAT without UNTIL"; break;
  case 52 : msg="CASE without END CASE"; break;
  case 53 : msg="Unable to reassign a constant"; break;
  case 54 : msg="Variable exists"; break;
  case 55 : msg="Event specifier expected"; break;
  case 56 : msg="GOSUB, GOTO or CALL expected"; break;
  case 57 : msg="Label, line number or SUB name expected"; break;
  case 58 : msg="ON, OFF or STOP expected"; break;
  case 59 : msg="No event trapping label or SUB defined for this event"; break;
  case 60 : msg="Identifier or Type expected"; break;
  case 61 : msg="Duplicate structure member"; break;
  case 62 : msg="Structure type already defined"; break; 
  case 63 : msg="Member type declaration expected"; break;
  case 64 : msg="STRUCT without END STRUCT"; break;
  case 65 : msg="Unknown structure type"; break;
  case 66 : msg="Structure already declared"; break;
  case 67 : msg="Not a structure member"; break;
  case 68 : msg="Unrecognised or incorrectly used command/function"; break;
  case 69 : msg="SHARED can only be used inside a subprogram"; break;
  case 70 : msg="FOR loop index cannot be a shared variable"; break;
  case 71 : msg="Undefined function or array not dimensioned"; break;
  case 72 : msg="AS expected"; break;
  case 73 : msg="ASSEM without END ASSEM"; break;
  case 74 : msg="Compiler directive expected"; break;
  case 75 : msg="OPEN, CLOSE, READ, WRITE or NAME expected"; break;
  case 76 : msg="Unable to open another library"; break;
  case 77 : msg="OPEN, CLOSE, READ, WRITE, WAIT or CLEAR expected"; break;
  case 78 : msg="An event trapping SUB may not have a parameter list"; break;
  case 79 : msg="Structure variable expected"; break;
  case 80 : msg="BLOCK without END BLOCK"; break;
  case 81 : msg="Cannot mix old-style and GadTools gadgets"; break;
 }

 /* show the error */
 printf("%s",msg);
 if (error_log) fprintf(err_log,"%s",msg);
 if (n > 1 && n != 8)
 {
  printf(" in line %d.\n",badline);
  if (error_log) fprintf(err_log," in line %d.\n",badline);
 }

 if (n != 0) errors++;
}

void _abort(n)
int n;
{
 _error(n);
 printf("*** compilation aborted with %d error(s).\n",errors);
 early_exit=TRUE;
 kill_all_lists();
 cleanup();
}

void open_files(source)
char *source;
{
int  cc;
char *xtn;

 /* 
 ** Open source file: allocate memory for extension in case required.
 */
 srcfile = (char *)alloc(strlen(source)+3,MEMF_ANY); /* 3 = 2*Xtn + EOS */
 if (srcfile == NULL)
 {
  puts("can't allocate memory for source file name.");
  early_exit=TRUE;
  cleanup();
 }

 /* copy source file name */
 strcpy(srcfile,source);

 /* 
 ** Does source file name already have an extension (.b or .bas)? 
 ** If not, add one. 
 */
 cc=0;
 while (srcfile[cc] && srcfile[cc] != '.') cc++;

 xtn = &srcfile[cc];

 /*
 ** Allow an extension of ".bas",".BAS",
 ** ".b" or ".B". If none is present -> append ".b".
 */
 if (strcmp(xtn,".bas") != 0 && strcmp(xtn,".BAS") != 0 && 
     strcmp(xtn,".b") != 0 && strcmp(xtn,".B") != 0) 
 strcat(srcfile,".b");

 /* open source file */
 if ((src = fopen(srcfile,"r")) == NULL) 
 { 
  printf("can't open %s.\n",srcfile);
  early_exit=TRUE;
  cleanup();
 }

 /* 
 ** Open object file. 
 */
 destfile = (char *)alloc(strlen(srcfile)+1,MEMF_ANY);
 if (destfile == NULL)
 {
  puts("can't allocate memory for object file name.");
  early_exit=TRUE;
  cleanup();
 }

 /* copy source file name and change extension to ".s" */
 cc=0;
 while (srcfile[cc] != '.') { destfile[cc] = srcfile[cc]; cc++; }
 destfile[cc] = '\0';
 strcat(destfile,".s");

 /* open target file */
 if ((dest = fopen(destfile,"w")) == NULL)
 {
  printf("can't write to %s.\n",destfile);
  early_exit=TRUE;
  cleanup();
 }
}

void nextch()
/* character handler */
{
char lineno_buf[15], *tmp;
int  i,n;
BOOL continue_line;

 /* if user hits ctrl-c clean up and abort. */
 if (SetSignal(0L,SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C)
 {
  puts("\n*** Break: ACE terminating.");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 if (column == linelen)
 {
  strcpy(lastline,line);

  /* refill line buffer */
  column = linelen = -1;

  do
  {
  	line[++linelen]=(ch=getc(src));
  }
  while ((ch != '\n') && (ch != EOF) && (linelen < MAXLINELEN));

  /* next line of source code */
  line[linelen] = '\0';

  /* 
  ** !!! eoln for previous line [PRINT statement etc] !!! 
  **
  ** Having just refilled the line buffer means we've
  ** run out of characters, so reached the eoln. The last
  ** character was '\0' which will be treated as whitespace
  ** but which is required for string literal parsing.
  **
  ** If the previous line's last non-whitespace character is '~' the line 
  ** should be continued (ie. the eoln should be ignored) and the '~' 
  ** character should be seen as whitespace.
  **
  ** Geez this whole EOLN thing is _messy_!!
  */
  tmp = lastline;
  while (*tmp) tmp++; 				/* find EOS */
  while (tmp > lastline && *tmp <= ' ') tmp--;	/* find '~' */
  if (*tmp != '~') sym=endofline;

  /* advance line counter */  
  lineno++;

  /* 
  ** Check for EOF -> Due to some editors, last line may not have 
  **     	      a LF, but parse it! Next time nextch() is called
  **		      EOF will be detected immediately. 
  */
  if (ch == EOF && linelen == 0)
  {
   if ((lineno == 0) && (linelen == 0)) _abort(1);
   else
       end_of_source = TRUE; 
  }

  /* line count display */
  if (!list_source && ((lineno % 10 == 0) || end_of_source))
  {
	  n=lineno;
	  if (end_of_source && linelen == 0) --n;
      	  printf("\rCompiling line %s",itoa(n,lineno_buf,10));
	  for (i=1;i<=strlen(lineno_buf);i++) putchar('\b');
	  fflush(stdout);
  }

  if (!end_of_source)
  {
   /* use source code line as a comment? */
   if (asm_comments) gen("; *** ",line,"  ");

   /* show each source code line before compilation? */
   if (list_source) printf("%ld: %s\n",lineno,line);
  }
 }

 /* next character */
 column++;
 ut_ch = ch = line[column];
 if (ch == '~' && !inside_string) ut_ch = ch = ' ';  /* '~' == whitespace */
}

BOOL letter()
{
 if ((ch >= 'A') && (ch <= 'Z')) return(TRUE);
 if ((ch >= 'a') && (ch <= 'z')) { ch -= 32; return(TRUE); }
 return(FALSE);
}

BOOL digit()
{
 if ((ch >= '0') && (ch <= '9')) return(TRUE);
 else
     return(FALSE);
}

BYTE hex_digit()
{
 if ((ch >= '0') && (ch <= '9')) return(ch-'0');
 letter(); /* make sure it's uppercase */
 if ((ch >= 'A') && (ch <= 'F')) return(10+ch-'A');
 return(-1);
}

BYTE octal_digit()
{
 if ((ch >= '0') && (ch <= '7')) return(ch-'0');
 return(-1);
}

void convert_special_ident()
{
/* 
** If the current identifier is one of a special 
** group, modify it by prefixing an underscore.
**
** This is a kludge to get around problems with
** certain names (eg: 68000 register names)
** which cause A68K to generate errors when
** encountered as labels. 
*/
char chr0,chr1;
 
  chr0 = id[0];
  chr1 = id[1];

  /* 
  ** Address or data register name? (A0..A7, D0..D7 or SP)
  ** If so -> convert to _Dn, _An or _SP.
  */
  if (((chr0 == 'A' || chr0 == 'D') &&
       (chr1 >= '0' && chr1 <= '7' && id[2] == '\0')) ||
      (chr0 == 'S' && chr1 == 'P' && id[2] == '\0'))
  {
	/* convert id */
	id[3] = '\0';
	id[2] = chr1;
	id[1] = chr0;
	id[0] = '_';
  }   
}

BOOL qualifier()
{
 /* - Attach a qualifier character (%&$!#).
    - The default object (variable) can be overriden by
      the later declaration of an array, subprogram etc.
 */

 switch(ch)
 {
  case '$' : obj = variable;  typ = stringtype; return(TRUE);
  case '%' : obj = variable;  typ = shorttype;  return(TRUE);  
  case '&' : obj = variable;  typ = longtype;   return(TRUE);
  case '!' : obj = variable;  typ = singletype; return(TRUE);
  case '#' : obj = variable;  typ = singletype; return(TRUE);
  default  : obj = undefined; typ = undefined;  return(FALSE);
 }
}

BOOL ssymbol()
{
int  i=0;
BOOL found=FALSE;
 
 /* if (ch == '"') return(TRUE); */
 while ((spec_sym[i] != '\0')&&(!found)) if (ch == spec_sym[i++]) found=TRUE;
 return(found);
}

int rsvd_wd(id)
char *id;
{
BOOL found=FALSE;
int first,last,this;

   /* search the reserved word
      list using a binary search 
      for AmigaBASIC and then ACE 
      keywords.
   */

   /* AmigaBASIC keyword? */
   first=abssym; last=xorsym;
   do
   {
    this = (first+last) / 2;
    if (strcmp(id,rword[this]) <= 0) last  = this-1;  /* id <= rword[this] ? */
    if (strcmp(id,rword[this]) >= 0) first = this+1;  /* id >= rword[this] ? */
   }   
   while (first <= last);
   if (first-1 > last) found=TRUE;

   /* ACE keyword? */
   if (!found)
   {
    first=addresssym; last=ycorsym;
    do
    {
     this = (first+last) / 2;
     if (strcmp(id,rword[this]) <= 0) last  = this-1;  /* id <= rword[this] ? */
     if (strcmp(id,rword[this]) >= 0) first = this+1;  /* id >= rword[this] ? */
    }   
    while (first <= last);
    if (first-1 > last) found=TRUE;
   }

   if (found) return(this); else return(undefined);
}

int rsvd_sym(id)
char *id;
{
BOOL found=FALSE;
int cc=0;

   /* reserved symbol? */
   do
   {
    if (strcmp(id,rsym[cc++]) == 0) found=TRUE;
   }
   while ((!found) && (strcmp(rsym[cc],"SENTINEL")!=0));
   if (found) return(500+cc-1); else return(undefined); 
}

void reclassify_number()
{
 /* reclassify a number as a short, long or floating point value
    if a qualifying character (%&!#) follows the numeric literal.
 */
  if (ch == '%')
  {
   /* coerce to a SHORT constant */
   nextch();
   switch(typ)
   {
    case longtype   : shortval=(SHORT)longval; break;
    case singletype : if (SPCmp(0.5,SPSub(SPFloor(singleval),singleval)) == 1) 
     			 shortval=(SHORT)SPFix(SPFloor(singleval));
		      else
     			 shortval=(SHORT)SPFix(SPCeil(singleval));
		      break; /*if fnum-fix(fnum)<0.5 round_down else round_up*/
   }
   sym=shortconst;
   typ=shorttype;
  }
  else
  if (ch == '&')  
  {
   /* coerce to a LONG constant */
   nextch(); 
   switch(typ)
   {
    case shorttype  : longval=(LONG)shortval; break;
    case singletype : if (SPCmp(0.5,SPSub(SPFloor(singleval),singleval)) == 1) 
     			 longval=(LONG)SPFix(SPFloor(singleval));
		      else
     			 longval=(LONG)SPFix(SPCeil(singleval));
		      break; /*if fnum-fix(fnum)<0.5 round_down else round_up*/
   }
   sym=longconst;
   typ=longtype; 
  }
  else
  if (ch == '!' || ch == '#')
  {
   /* coerce to a SINGLE constant */
   nextch();
   switch(typ)
   {
    case shorttype : singleval=SPFlt((LONG)shortval); break;
    case longtype  : singleval=SPFlt(longval); break;    
   }
   sym=singleconst;
   typ=singletype;
  }  
}

void classify_integer(n)
LONG n;
{
 /* classify as a long or short integer value */
 if (n >= 0 && n <= MAXSHORT)
 {
   /* SHORT constant */
   shortval=(SHORT)n;
   sym=shortconst; 
   typ=shorttype;
 }
 else
 {
   /* LONG constant */
   longval=n;  
   sym=longconst;
   typ=longtype; 
 }
}

void insymbol()
/* lexical analyser */
{
int  i,cc=0;
BOOL found;
char ssym[3];
LONG n[2],n0,n1;
int  index;
int  periods;
BOOL period;
LONG places;
int  placecount;
char ffpbuf[20];
int  ex;
LONG val;
BYTE num;
int  sign;
char lastch=' ';
BOOL ans;

 lastsym=sym;   
 sym = undefined;
 obj = undefined;
 typ = undefined;
 found = FALSE;

 if (!end_of_source)
 {
  /* skip whitespace */
  while (ch <= ' ') 
  { 
   nextch(); 
   if (end_of_source) return; 
   if (sym == endofline) return;  /* for PRINT */
  }

  /* single-line comment? */
  if (ch == '\'') 
  {
   do
   {
    nextch();
   }
   while ((sym != endofline) && (!end_of_source));
   if (end_of_source) return;
   if (sym == endofline) return;  /* for PRINT '... */
  }

  /* block comment? */
  if (ch == '{')
  {
   do
   {
    nextch();
   }
   while ((ch != '}') && (!end_of_source));

   if (!end_of_source) nextch();  /* character after "}" */
   else
       return;

   if (sym == endofline) return;  /* for PRINT {..} */

   /* skip whitespace */
   while (ch <= ' ') 
   { 
    nextch(); 
    if (end_of_source) return; 
    if (sym == endofline) return;  /* for PRINT {..} eoln */
   }
  }

  /* identifier or reserved word? */
  if (letter() || (ch == '_'))
  {
   do
   {
    ut_id[cc]=ut_ch; /* keep an "untouched" version (ie: upper/lower case) 
			for DATA statements, library function searches 
			and external functions */
    id[cc++]=ch;
    nextch();
   }
   while ((letter() || digit() || (ch == '.') || (ch == '_')) && 
	  (cc < MAXIDSIZE-2));  
 
   id[cc]='\0';
   ut_id[cc]='\0';
  
   /* is there a qualifier? %&$!# */
   if (qualifier()) 
   {
    if (ch == '&') ch='@';   
    if (ch == '!') ch='[';   /* this is ONLY because a jsr SUB_name& or
				SUB_name! gives an error in A68K, whereas
			  	SUB_name@ and SUB_name[ don't!! */
    id[cc++]=ch;
    nextch();
   }

   id[cc] = '\0';
   ut_id[cc] = '\0';
   
   /* reserved word? */
   if ((sym = rsvd_wd(id)) == undefined)
   { 
    /* no, it's an identifier */
    convert_special_ident();

    sym=ident; 

    if (typ == undefined) 
    { 
    	/* 
	** Data type = ASCII value of 1st char in id minus 'A'.
	** Note that the underscore character is also catered
	** for here since it is higher in the ASCII table than
	** "Z". See lexvar.c, misc.c and setup() (above) for 
	** more info.
    	*/
	typ=idtype[id[0]-'A']; 

        obj=variable;        
    }
   }
   else
    {
     /* 
     ** It's a reserved word, so typ & obj mean nothing, but may
     ** have been set by qualifier() if qualifier character was a '$' 
     */
     typ=undefined;
     obj=rsvd_word;
    }
  }
  else
  /* string constant? */
  if (ch == '"')
  {
   inside_string = TRUE;
   cc=0;
   do
   {
    nextch();
    stringval[cc++] = ch;
   }
   while ((ch != '"') && (ch != '\0') && (cc < MAXSTRLEN));
   if (ch == '"') --cc;
   if (ch == '"') nextch();
   stringval[cc]='\0';
   sym=stringconst; typ=stringtype; obj=constant;
   inside_string = FALSE;
  }
  else
  /* numeric literal? */
  if (digit() || (ch == '.'))
  {
   n[0]=n[1]=0;
   index=0;
   period=FALSE;
   periods=0;
   placecount=0;
   
   /* is first char '.'? */
   if (ch == '.')
   {
    period=TRUE;
    placecount=0;
    index=1;
    periods++;
   }
   /* get the value */
   if (!period) n[0]=10*n[0]+(ch-'0');
   do
   {
    nextch();
    if (digit()) n[index]=10*n[index]+(ch-'0');
    if (digit() && period) placecount++;
    if (ch == '.') periods++;
    if ((ch == '.') && (!period))
    {
     period=TRUE;
     placecount=0;
     index=1;
    }
   }
   while ((digit() || ch == '.') && (periods <= 1));
 
   /* integer or real? */
   if (period && (periods == 1))
   {
    /* make FFP */
    sym = singleconst; typ=singletype;
    places=1;
    for (i=1;i<=placecount;i++) places *= 10;
    n0=n[0];
    n1=n[1];
    singleval= SPAdd(SPFlt(n0),SPDiv(SPFlt(places), SPFlt(n1)));
    /*ex = fpa(singleval,ffpbuf);
    ffpbuf[14]='\0'; 
    printf("FFP: %s\t%lx\t",ffpbuf,singleval);
    ffprint(ex,ffpbuf);*/
   }  
  else 
      classify_integer(n[0]);

  reclassify_number();

  /* is it a real in scientific format? */
  if ((ch == 'e') || (ch == 'E'))
  {
   ex=0;
   sign=1;
   nextch();
   if (ch == '+') { sign=1; nextch(); }
   else
      if (ch == '-') { sign=-1; nextch(); }
   if (!digit()) _error(3);  /* expect a digit */ 
   /* get digits */
   while (digit()) { ex = 10*ex + (ch-48); nextch(); }
   ex *= sign;
   /* convert to FFP */
   if ((ex >= -20) && (ex <= 18))
   {

    /* mantissa */
    if (sym != singleconst) 
    { 
     singleval = SPFlt(n[0]); 
     sym=singleconst; typ=singletype;
    }

    /* if exponent is zero: 10^ex = 1 -> num*1 = num 
       so just return singleval as it is. */
    if (ex != 0) singleval = SPMul(SPPow(SPFlt(ex),10.0),singleval);

    reclassify_number();
   }
   else { singleval = 0.0; _warn(1); }
  }    
  obj=constant;
 }
 else
  /* reserved symbol? */
  if (ch == '\\') /* backslash */
  { 
   sym=idiv;  
   nextch();
  }
  else
  if (ssymbol() || (ch == '&') || (ch == '#'))
  {
   /* one character symbol? */
   ssym[0]=ch;
   ssym[1]='\0';
   sym = rsvd_sym(ssym);  /* tentatively */

   lastch=ch;  /* might be '&' or '*' */
   nextch();   

   /* multiple character symbol? (++,--,->,<>,<=,>=,:=,&H,&O,*%,*&,*!) */

   /* ++ */
   if (sym==plus && ch=='+') 
      { ssym[1]=ch; ssym[2]='\0'; sym=rsvd_sym(ssym); nextch(); }
   else 
   /* --,-> */
   if (sym==minus && (ch=='-' || ch=='>')) 
      { ssym[1]=ch; ssym[2]='\0'; sym=rsvd_sym(ssym); nextch(); }
   else
   /* <>,<= */
   if (sym==lessthan && (ch=='>' || ch=='=')) 
      { ssym[1]=ch; ssym[2]='\0'; sym=rsvd_sym(ssym); nextch(); }
   else
   /* >=,:= */
   if ((sym==gtrthan || sym==colon) && ch=='=') 
      { ssym[1]=ch; ssym[2]='\0'; sym=rsvd_sym(ssym); nextch(); }
   else
   /* &H,&O */
   if (lastch=='&' && (ch=='H' || ch=='O')) 
      { ssym[1]=ch; ssym[2]='\0'; sym=rsvd_sym(ssym); nextch(); }
   else
   /* *%,*&,*! */
   if (lastch=='*' && (ch=='%' || ch=='&' || ch=='!'))
      { ssym[1]=ch; ssym[2]='\0'; sym=rsvd_sym(ssym); nextch(); }
  
 
       /* hexadecimal constant? */
       if (sym == hexprefix)
       {
        val=0;
	if (hex_digit() == -1)
	   _error(2);
	else
        while ((num = hex_digit()) != -1)
        {
         val = 16*val + num;
         nextch();
        }
        classify_integer(val); 
	reclassify_number();
       }
       else
      /* octal constant? */
      if ((sym == octalprefix) || ((ssym[0] == '&') && (strlen(ssym)==1)))
      {
       val=0;
       if (octal_digit() == -1) 
           _error(2); 
       else
       {
        while ((num = octal_digit()) != -1)
        {
         val = 8*val + num;
         nextch();
        }
        classify_integer(val);
	reclassify_number();
       }
      }
    }
    /*
    ** Unknown symbol.
    */
    if (sym == undefined) { _error(2); nextch(); }
    /*showsym(sym); lf();*/
 } 
}

/*
void showsym(sym)
int sym;
{
 if (sym == undefined) printf("undefined");
 else
 if (sym <= RWSENTINEL) printf("%s -> %d",rword[sym],sym);
 else
 if (sym <= RSSENTINEL) printf("%s",rsym[sym-500]);
 else
     printf("%s",symbol[sym-1000]);
}

void showobj(obj)
int obj;
{
 if (obj == undefined) printf(" undefined");
 else
     printf("%10s",object[obj-3000]);
}

void showtyp(typ)
int typ;
{
 if (typ == undefined) printf(" undefined");
 else
     printf("%10s",type[typ-2000]);
}
 
void tab()
{
 putchar('\t');
}

void lf()
{
 putchar('\n');
}
*/

/*
void main(argc,argv)
int  argc;
char *argv[];
{
 if (argc == 1) { src = stdin; std_in=TRUE; }
 else
    open_files(argv[1]);
 setup();
 while (!end_of_source) 
 { 
  insymbol(); 
  puts("                             ");
  showsym(sym); tab(); 
  showobj(obj); tab(); 
  showtyp(typ); lf(); 
  switch(sym)
  {
   case stringconst : printf("-->>%s\n",stringval); break;
   case shortconst  : printf("-->>%d\n",shortval);  break;
   case longconst   : printf("-->>%ld\n",longval);  break;
   case singleconst : printf("-->>%x\n",singleval); break;
  }
 }
 cleanup();
}
*/
