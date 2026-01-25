/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: library and machine code function handling **
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
	   6th,7th,22nd December 1992,
	   28th February 1993,
	   12th April 1993,
	   16th,17th December 1993,
	   2nd,3rd,13th January 1994,
	   12th June 1994,
	   5th,20th,28th August 1994,
	   1st,10th September 1994,
	   8th,9th March 1995
*/

#include "acedef.h"

/* locals */
static 	char 	*reg[] = { "  ","d0","d1","d2","d3","d4","d5","d6","d7",
			   "a0","a1","a2","a3","a4","a5" };

/* externals */
extern	int	sym;
extern	int	lastsym;
extern	int	typ;
extern	int	lev;
extern	char   	id[MAXIDSIZE]; 
extern	char   	ut_id[MAXIDSIZE];
extern	char 	tempshortname[80];
extern	char 	templongname[80];
extern	char	stringval[MAXSTRLEN];
extern	SYM	*curr_item;
extern	ACELIBS acelib[NUMACELIBS];
extern	ACELIBS otherlib[NUMLIBS];
extern	char 	librarybase[MAXIDSIZE+6];
extern	char 	libraryname[MAXIDSIZE+20];
extern	char	bmapname[MAXIDSIZE+20];
extern	BOOL 	restore_a4;
extern	BOOL 	restore_a5;
extern	BOOL	early_exit;

/* ------------------------- */
/* Library Function routines */
/* ------------------------- */

BYTE check_for_ace_lib(libname)
char *libname;
{
int c=0;
/* 
** If libname is a library used by ACE 
** open & close it in the normal way.
*/ 

 while(acelib[c].name[0] != '\0' && 
       strcmp(acelib[c].name,"SENTINEL") !=0) 
 {
  if (strcmp(acelib[c].name,libname)==0) 
     { enter_XREF(acelib[c].base); return(c); }
  c++;
 } 
 return(NEGATIVE);
}

void enter_new_library(libname)
char *libname;
{
int  cc=0;
/*
** Enter a library into the list 
** for future reference by function
** declarations which don't specify
** the library to be used.
*/

  /* 
  ** Find libname, first free or maximum entry.
  ** If it's already in the list, libname will
  ** be ignored.  
  */
  while (otherlib[cc].name[0] != '\0' && 
     	 strcmp(otherlib[cc].name,libname) != 0 &&
	 strcmp(otherlib[cc].name,"SENTINEL") != 0) cc++;

  /* maximum? */
  if (strcmp(otherlib[cc].name,"SENTINEL") == 0) 
     _error(76);  /* can't add another library */   
  else
  if (otherlib[cc].name[0] == '\0')
  {
	/* add a new entry */
	strcpy(otherlib[cc].name,libname);
	make_library_base(libname);
	strcpy(otherlib[cc].base,librarybase);
  }
}

void make_library_base(libname)
char *libname;	
{
 strcpy(librarybase,"_\0");
 strcat(librarybase,libname);
 strcat(librarybase,"Base");
 enter_BSS(librarybase,"ds.l 1");
}

void make_library_name(libname)
char *libname;
{
 strcpy(libraryname,libname);
 strcat(libraryname,".library");
}

void make_bmap_name(libname)
char *libname;
{
 strcpy(bmapname,"ACEbmaps:");
 strcat(bmapname,libname);
 strcat(bmapname,".bmap");
}

void get_libname(libname,ut_libname)
char *libname,*ut_libname;
{
char *tmp,*ut_tmp;

   /* get raw library name (uppercase and untouched) */
   if (sym == ident) 
   {
      strcpy(ut_libname,ut_id);
      strcpy(libname,id);
   }
   else
   {
      strcpy(ut_libname,stringval);
      strcpy(libname,(char*)strupr(stringval));
   }

   /* chop off extension if ".bmap" or ".library" */ 
   tmp=libname;
   ut_tmp=ut_libname;
   while (*tmp && *tmp != '.') { tmp++; ut_tmp++; }
   if (*tmp == '.' && 
       (strcmp(tmp,".BMAP") == 0 || strcmp(tmp,".LIBRARY") == 0))
   {
	*tmp = '\0';
	*ut_tmp = '\0';
   }
}
 
void library()
{
char libname[MAXIDSIZE],ut_libname[MAXIDSIZE];
char lab[80],lablabel[80];

 /* open or close a shared library */

 insymbol();
 if (sym == closesym) closelibrary();
 else
 {
  if (sym != ident && sym != stringconst) 
     _error(7);  /* identifier expected */
  else
  {
   get_libname(libname,ut_libname);  /* without extension! */

   if (check_for_ace_lib(libname) == NEGATIVE)
   {
     make_library_name(ut_libname); /* exec names are case sensitive */
     make_string_const(libraryname);
     gen("move.l","(sp)+","a1");   /* address of library name in a1 */
     gen("jsr","_open_library","  ");
     make_library_base(libname);
     gen("move.l","d0",librarybase);
     gen("cmpi.l","#0","d0");
     make_label(lab,lablabel);
     gen("bne.s",lab,"  ");
     gen("jmp","_EXIT_PROG","  "); /* quit program if can't open library */
     gen(lablabel,"  ","  ");
     enter_XREF("_open_library");

     /* enter new library info' into "other libraries" list */
     enter_new_library(libname);
   }
  }
  insymbol();
 }
}       

void closelibrary()
{
char libname[MAXIDSIZE],ut_libname[MAXIDSIZE];
int  cc;
 /* close one or more shared libraries */ 

 insymbol();
 if (sym != ident && sym != stringconst) 
 {
   /* 
   ** Close all open shared libraries not 
   ** normally closed by ACE at the end of
   ** the program run.
   */
   cc=0;
   while (otherlib[cc].name[0] != '\0' &&
	  strcmp(otherlib[cc].name,"SENTINEL") != 0)
   {
    	gen("move.l",otherlib[cc].base,"a1");  /* library base in a1 */
    	gen("jsr","_close_library","  ");
	gen("move.l","#0",otherlib[cc].base);
        enter_XREF("_close_library");
	cc++;
   }  	
 }   
 else
 {
  /* close a single shared library */
  get_libname(libname,ut_libname);  /* without extension! */

  if (check_for_ace_lib(libname) == NEGATIVE)
  {
    make_library_base(libname);
    gen("move.l",librarybase,"a1");  /* library base in a1 */
    gen("jsr","_close_library","  ");
    gen("move.l","#0",librarybase);
    enter_XREF("_close_library");
  }
  insymbol();
 }
}
  
void remove_qualifier(funcname)
char *funcname;
{
/* remove any trailing data type qualifier (%&#!$) @=& [=! */
int cc=0;

 /* find end of string */
 while (funcname[cc] != '\0') cc++;
 /* is the last character a qualifier? */
 if ((funcname[cc-1] == '%')||(funcname[cc-1] == '@')||(funcname[cc-1] == '#')
    ||(funcname[cc-1] == '[')||(funcname[cc-1] == '$')) funcname[cc-1]='\0';
}

BOOL search_func(bmap,func,declared_func)
char *bmap;
char *func;
SYM  *declared_func;
{
/* 
** Search for function in .bmap file, recording register usage
** and library base offset in symbol table entry for function. 
*/

unsigned char		*buf;
struct FileHandle	*f;
unsigned char		ch,name[MAXIDSIZE];
LONG	 		bmap_size,count,cc,rc;
SHORT			offset=0;
BOOL     		found=FALSE;

unsigned char *tmp;

 if ((bmap_size=fsize(bmap)) == -1L)  /* if not -1 -> file exists and
					 we get size of file in bytes. */
    { _error(50); return(FALSE); }
 else
 {
  /* read whole bmap file into a buffer */
  buf = (unsigned char *)alloc(bmap_size,MEMF_ANY);
  f = (struct FileHandle *)Open(bmap,MODE_OLDFILE);
  Read(f,buf,bmap_size);
  Close(f);

  count=0;  /* start of buffer */

  while (!found && count < bmap_size)
  {
   /* build function name */
   cc=0;
   while (count < bmap_size && cc < MAXIDSIZE)
   {
    ch=name[cc++]=buf[count++];
    if (ch == '\0') break;  /* exit loop when EOS reached */
   }

   name[cc-1]='\0';  /* make sure we have an EOS symbol (may exit early) */

   if (strcmp((char*)name,func) != 0)
   {
    /* skip 2-byte offset */
    count += 2;
    /* skip to next name */
    while (count < bmap_size && (ch=buf[count++]) != '\0');
   }
   else found=TRUE;  /* that's it! -> get the info' */
  }

  if (!found) return(FALSE);

  /* get library base offset (2 bytes) */
  if (count < bmap_size)
  {
   ch=buf[count++];
   offset += ch*256;
  }
  else 
      return(FALSE);

  if (count < bmap_size)
  {
   ch=buf[count++];
   offset += ch;
  }
  else 
      return(FALSE);

  declared_func->address = (SHORT)offset;  /* record library base offset */

  /* get n bytes of register data */
  declared_func->reg = (UBYTE *)sym_alloc(15,MEMF_ANY);
  if (declared_func->reg == NULL)
  {
	puts("Can't allocate memory for function register info!");
	early_exit=TRUE;
	kill_all_lists();
       	cleanup();
  }
  
  rc=0;
  while (count < bmap_size && 
        (ch=buf[count++]) != '\0') declared_func->reg[rc++]=ch;

  declared_func->no_of_params=rc;  /* record no. of parameters */

  if (ch != '\0') return(FALSE);  /* last character should be NULL */   

  /* we found it -> return */
  return(TRUE);
 }
}

BOOL found_func(libname,ut_funcname,declared_func)
char *libname;
char *ut_funcname;
SYM  *declared_func;
{
     /* 
     ** Search for function in bmap file and record register usage
     ** and library base offset in symbol table entry for function.
     */

     make_bmap_name(libname);

     if (search_func(bmapname,ut_funcname,declared_func))
     {
      /* store library name */
      declared_func->libname = (char *)sym_alloc(MAXIDSIZE+8,MEMF_ANY);
      if (declared_func->libname == NULL)
      {
	puts("Can't allocate memory for library name in symbol table!");
	early_exit=TRUE;
	kill_all_lists();
       	cleanup();
      }
      else
      {
	/* found the function */  
        strcpy(declared_func->libname,libname);
	return(TRUE);
      }
     }  
     else
	 /* didn't find the function */
    	 return(FALSE); 
}

void declare()
{
/* - declare a library function -- NOT optional. 
   - declare an external function -- NOT optional.
   - declare a forward reference to a SUB. 
   - declare an instance of a structure. 
*/

char funcname[MAXIDSIZE],ut_funcname[MAXIDSIZE];
char libname[MAXIDSIZE],ut_libname[MAXIDSIZE];
char extfuncname[MAXIDSIZE+1];
BYTE libnum;
int  oldlevel,cc;
int  functype=undefined;
SYM  *declared_func;
BOOL found;

 /* all functions and structures must be declared at level ZERO */

 oldlevel=lev;
 lev=ZERO;

 insymbol();

 if (sym == subsym) { lev=oldlevel; forward_ref(); return; }

 if (sym == structsym) { lev=oldlevel; declare_structure(); return; }

 if (sym != functionsym) _error(47);
 else
 {
  insymbol();

  /* type identifiers */
  if (sym == shortintsym || sym == longintsym || sym == addresssym ||
      sym == singlesym || sym == stringsym)
  {
   switch(sym)
   {
    case shortintsym : functype = shorttype;  break;
    case longintsym  : functype = longtype;   break;
    case addresssym  : functype = longtype;   break;
    case singlesym   : functype = singletype; break;
    case stringsym   : functype = stringtype; break;
   }
   insymbol();
  }

  /* Accept keywords GETATTR/SETATTR as function names (for Intuition funcs) */
  if (sym == getattrsym)
  {
   strcpy(id,"getattr");
   strcpy(ut_id,"GetAttr");
  }
  else if (sym == setattrsym)
  {
   strcpy(id,"setattr");
   strcpy(ut_id,"SetAttr");
  }

  if (sym != ident && sym != getattrsym && sym != setattrsym) _error(7);
  else
  {
   /* get the function's name */
   strcpy(funcname,id);
   strcpy(ut_funcname,ut_id);  /* case sensitive version for search! */
   remove_qualifier(funcname);
   remove_qualifier(ut_funcname);
   if (functype == undefined) functype = typ;

   /* get the LIBRARY symbol and/or parameter list */ 
   insymbol();

   /* parse parameter list? */
   if (sym == lparen)
   {    
    do
    {   
        insymbol();

	if (sym == rparen && lastsym == lparen) break;  /* FuncName() */

	/* type indentifier? */
        if (sym == shortintsym || sym == longintsym || sym == addresssym ||
      	    sym == singlesym || sym == stringsym) 
	insymbol();

	/* parameter */
	if (sym != ident) _error(7);
	else
	    insymbol();
    }
    while (sym == comma);

    if (sym != rparen) _error(9);
    else
        insymbol();
   }

   /* EXTERNAL or LIBRARY function? */
   if (sym == externalsym) 
   {
	if (ut_funcname[0] != '_')
	{
	   	strcpy(extfuncname,"_\0");
		strcat(extfuncname,ut_funcname);
	}
	else
		strcpy(extfuncname,ut_funcname);

	enter(extfuncname,functype,extfunc,0);
	enter_XREF(extfuncname);	

	insymbol();
   }
   else
   if (sym != librarysym) _error(48);
   else
   {
    enter(funcname,functype,function,0); /* enter into symbol table */ 
    declared_func=curr_item;

    insymbol();

    if (sym != ident && sym != stringconst)
    {
	/* 
	** Search all bmap files found in acelib and otherlib arrays 
	** for function since no library was specified.
  	*/

	found=FALSE;

	/* acelib array */
	cc=0;
	while (!found && acelib[cc].name[0] != '\0' &&
	       strcmp(acelib[cc].name,"SENTINEL") != 0)
	{
	  found = found_func(acelib[cc].name,ut_funcname,declared_func);
	  cc++;
	}

	if (found) { lev=oldlevel; return; }

	/* otherlib array */
	cc=0;
	while (!found && otherlib[cc].name[0] != '\0' &&
	       strcmp(otherlib[cc].name,"SENTINEL") != 0)
	{
	  found = found_func(otherlib[cc].name,ut_funcname,declared_func);
	  cc++;
	}	

	if (!found) _error(49);
    }
    else
    {
     	/* 
	** Search specified library (bmap file) for the declared function.
	*/
     	get_libname(libname,ut_libname);  /* without extension! */

	if (!found_func(libname,ut_funcname,declared_func)) 
	  _error(49); 

        insymbol();
    }
   }  
  }    
 }
 lev=oldlevel;
}

void load_func_params(func_item)
SYM *func_item;
{
/* 
** Parse a shared library function's actual parameter-list 
** and call the function.
*/
SHORT i,n;
char  ptemp[14][80];

 if (sym != lparen) { _error(14); return; }
 else
 {
  /* get parameters */
  i=0;
  do
  {
   insymbol();

   /*
   ** Make ALL parameters longints! 
   */
   if (expr() == shorttype) make_long();

   /* 
   ** Store parameter information temporarily 
   ** since expression evaluation may corrupt 
   ** data in registers later if loaded now.
   */
   make_temp_long();
   strcpy(ptemp[i],templongname);  /* later -> move.l srctemp,addrbuf */

   /* store it */
   gen("move.l","(sp)+",templongname);
   
   i++;
  }
  while ((i < func_item->no_of_params) && (sym == comma));

  if ((i < func_item->no_of_params) || (sym == comma)) 
     _error(39); /* parameter count mismatch - too few or too many. */
  else
  {
   /* load parameters into regs */
   for (n=0;n<func_item->no_of_params;n++)
   {
    /* does reg (a4 or a5 ONLY) need to be preserved? */
    if (func_item->reg[n] == 13)   /* a4 */ 
    { 
     restore_a4=TRUE; 
     gen("move.l","a4","_a4_temp");
     enter_BSS("_a4_temp:","ds.l 1");
    }
    else
    if (func_item->reg[n] == 14)   /* a5 */
    { 
     restore_a5=TRUE; 
     gen("move.l","a5","_a5_temp");
     enter_BSS("_a5_temp:","ds.l 1");
    }
 
    /*
    ** Store value in register.
    */ 
    gen("move.l",ptemp[n],reg[func_item->reg[n]]);
   }
  }

  if (sym != rparen) _error(9);
 }
}

/* ----------------- */
/* Machine Code CALL */
/* ----------------- */

void load_mc_params(sub_ptr)
SYM *sub_ptr;
{
SHORT i,n;
int   ptype;
char  p_temp[MAXPARAMS][80];
int   p_type[MAXPARAMS];

  /* 
  ** Store parameters in stack space of MC subroutine 
  ** which is about to be CALLed ala C parameter passing 
  ** convention.
  */

  i=0;
  do
  {
   insymbol();
   ptype=expr();

   /* store parameters temporarily */  
   if (ptype == shorttype)
   {
    /* save parameter type */
    p_type[i]=shorttype; /* not DATA type but STORE type (2 or 4 bytes) */

    /* create a temporary store */
    make_temp_short();
    strcpy(p_temp[i],tempshortname);  /* later -> move.w srctemp,-(sp) */

    /* store it */
    gen("move.w","(sp)+",tempshortname);
   }
   else
   /* long,single,string or array */   
   {
    /* save parameter type */
    p_type[i]=longtype;  /* storage requirement is 4 bytes */

    /* create a temporary store */
    make_temp_long();
    strcpy(p_temp[i],templongname);

    /* store it */
    gen("move.l","(sp)+",templongname);
   }
   
   i++;
  }
  while ((i < MAXPARAMS) && (sym == comma));

  /* push parameters onto stack ala C (see AmigaBASIC manual 6-11) */
  for (n=i-1;n>=0;n--)
  {
   if (p_type[n] == shorttype) 
   { 
    gen("move.w",p_temp[n],"-(sp)"); /* short */
    sub_ptr->p_type[n] = shorttype;
   }
   else
   {
    gen("move.l",p_temp[n],"-(sp)"); /* long,string,single,array */
    sub_ptr->p_type[n] = longtype;
   }
  }

  sub_ptr->no_of_params = i; /* record number of parameters pushed! */

  if (sym != rparen) _error(9);
}
