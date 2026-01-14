/* << ACE >>

   -- Amiga BASIC Compiler --

   ** Parser: variable, structure, constant and external object 
   ** declaration/definition code **
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
	   14th February 1993,
	   12th,16th April 1993,
	   20th,30th June 1993,
	   15th December 1993,
	   2nd January 1994,
	   26th February 1994,
	   12th June 1994,
	   8th,9th September 1994,
	   1st,2nd October 1994,
	   11th,22nd June 1996
*/

#include "acedef.h"

/* locals */
static	char 	*frame_ptr[] = { "(a4)","(a5)" };

/* externals */
extern	int	sym;
extern	int	typ;
extern	int	lev;
extern	int  	structcount;
extern	char   	id[MAXIDSIZE]; 
extern	char   	ut_id[MAXIDSIZE];
extern	SHORT  	shortval;
extern	LONG   	longval; 
extern	LONG    singleval;
extern	SYM	*curr_item;
extern	SYM	*structdef_item;
extern	STRUCM	*curr_structmem;
extern	BOOL	end_of_source;


/* functions */
void define_structure()
{
/* define a structure data type */

SHORT mem_count=0;
SYM   *structdef_item,*struct_mbr_def;
int   mem_type;
int   oldlevel;
LONG  string_size;

/* define all structures 
   at level ZERO */
oldlevel=lev;
lev=ZERO;

insymbol();
if (sym != ident)
   _error(7);
else
{
 if (exist(id,structdef))
    _error(62);
 else
 {
  /* create symbol table entry */
  enter(id,notype,structdef,0);
  structdef_item=curr_item;

  /* get structure members */
  insymbol();
  while (sym == endofline) insymbol();  /* skip blank line(s) */

  do
  {
   if ((sym != bytesym) && (sym != shortintsym) && (sym != addresssym) &&
       (sym != longintsym) && (sym != singlesym) && (sym != stringsym) &&
       (sym != ident))
      { _error(63); insymbol(); }
   else
   {
    struct_mbr_def = NULL;

    /* type of member? */
    switch(sym)
    {
     case bytesym     : mem_type=bytetype; break;
     case shortintsym : mem_type=shorttype; break;
     case longintsym  : mem_type=longtype; break;
     case addresssym  : mem_type=longtype; break;
     case singlesym   : mem_type=singletype; break;
     case stringsym   : mem_type=stringtype; break;    
     case ident       :	mem_type=structure; 
			if (!exist(id,structdef) || 
			    strcmp(id,structdef_item->name) == 0)
			{
				_error(65); /* unknown or current structdef */
				mem_type = undefined;
			}
			else
				/* structure definition */
			   	struct_mbr_def = curr_item;
			break;
    }
    
    if (mem_type == undefined)
	insymbol();
    else
    {
      insymbol();
      if (sym != ident)
	  { _error(7); insymbol(); }
      else
      { 
     	add_struct_member(structdef_item,id,mem_type,struct_mbr_def); 
      	mem_count++; 
      }
    }

    insymbol();

    /* specify optional string size? */
    if ((mem_type == stringtype) && (sym == sizesym))
    {
     insymbol();
     if (sym == shortconst) string_size=(LONG)shortval;
     else
     if (sym == longconst) string_size=longval;
     else 
     if (sym == ident && exist(id,constant))
     {
	/* short or long defined constant? */
	if (curr_item->type == shorttype)
	   string_size=(LONG)curr_item->numconst.shortnum;
	else
	if (curr_item->type == longtype)
	   string_size=curr_item->numconst.longnum;
	else
	    _error(4);  /* needed a short or long constant */
     }
     else
         _error(27); /* numeric constant expected */

     if (string_size <= 0L) _error(41);  /* non-positive string size! */
 
     insymbol();

     /* change member and struct info */
     curr_structmem->strsize = string_size;
     structdef_item->size -= MAXSTRLEN;  /* subtract default string size */
     structdef_item->size += string_size; 
    } 
   }
   while (sym == endofline) insymbol();  /* skip blank line(s) */
  }
  while (sym != endsym && sym != structsym && !end_of_source);
	
  if (sym != endsym)
     _error(64);
  else
  {				 
   insymbol();
   if (sym != structsym) _error(64); else insymbol();
  }
    
  /* don't want to free memory if no member list! */
  if (mem_count == 0) structdef_item->object = undefined;
 }
}
lev=oldlevel;  /* restore level */
}

void declare_structure()
{
/* declare one or more instances
   of a structure (at level ZERO).
 
   syntax: DECLARE STRUCT <struct-type> [*] <ident> [,[*] <ident>..]

*/
STRUCM *curr_member;
BOOL   struct_pointer=FALSE;
char   addrbuf[40],numbuf[40];
char   structname[80],structlabel[80];
char   strsize[20],bss_spec[40];

 insymbol();

 if (sym != ident)
    { _error(7); insymbol(); }
 else
 {
  if (!exist(id,structdef))
     { _error(65); insymbol(); }  /* unknown structdef */
  else
  {
   structdef_item = curr_item; /* pointer to structdef info */
 
   do
   {
    insymbol();
    if (sym == multiply) { struct_pointer=TRUE; insymbol(); }

    if (sym != ident)
       _error(7);
    else
    {
     if (exist(id,structure))
        _error(66);
     else
     {
      /* enter instance of structure in
         symbol table and get stack frame
         address.
      */
      enter(id,notype,structure,0);
      curr_item->other = structdef_item; /* ptr to structdef node in symtab */

      itoa(-1*curr_item->address,addrbuf,10);
      strcat(addrbuf,frame_ptr[lev]);

      /* if a pointer to a structure
         make it NULL otherwise create 
         a BSS object.
      */
      if (struct_pointer)
         gen("move.l","#0",addrbuf); /* pointer to structure */
      else
      {
       /* BSS structure name */
       strcpy(structname,"_structure");
       itoa(structcount++,numbuf,10);
       strcat(structname,numbuf); 

       /* BSS structure label */
       strcpy(structlabel,structname);
       strcat(structlabel,":\0");

       /* create BSS object - long word aligned! */
       enter_BSS("  ","CNOP 0,4");
       enter_BSS(structlabel,"  ");

       curr_member = structdef_item->structmem->next; /* head has no mbr data */
       while (curr_member != NULL)
       {
        switch(curr_member->type)
        {
         case bytetype   : enter_BSS("  ","ds.b 1"); break;
         case shorttype  : enter_BSS("  ","ds.w 1"); break;
         case longtype   : enter_BSS("  ","ds.l 1"); break;
         case singletype : enter_BSS("  ","ds.l 1"); break;

	 case stringtype : 
	 case structure  : ltoa(curr_member->strsize,strsize,10);
			   strcpy(bss_spec,"ds.b ");
			   strcat(bss_spec,strsize);
			   enter_BSS("  ",bss_spec);
			   break; 
        }
        curr_member = curr_member->next;
       }

       enter_BSS("  ","  ");  /* place a space before next BSS object! */

       /* store address of BSS object 
          in stack frame.
       */
       gen("pea",structname,"  ");
       gen("move.l","(sp)+",addrbuf); 
      }
     }     
    }
    insymbol();
   }
   while (sym == comma);  
  }
 } 
}

void define_constant()
{
/* define a NUMERIC constant 
   syntax: CONST <ident>=[-|+]<numconst>[,..] 
*/
char  const_id[MAXIDSIZE];
BOOL  numconstant;
int   consttyp;
SHORT shortc;
LONG  longc;
LONG  singlec;
BOOL  negate;
int   oldlevel;

 /* define all constants 
    at level ZERO */
 oldlevel=lev;
 lev=ZERO;

 do
 {
  numconstant=FALSE;
  negate=FALSE;

  insymbol();
  if (sym != ident)
     _error(7);
  else
  {
   strcpy(const_id,id); /* save name */
   insymbol();
   if (sym != equal)
      _error(5);
   else
   {
    insymbol();
    if (exist(const_id,constant)) /* don't try to reassign it! */
       _error(53);
    else
    {
     /* unary minus or plus? (optional) */
     if ((sym == minus) || (sym == plus))
     { 
      switch(sym)
      {
       case minus : negate=TRUE;  break;
       case plus  : negate=FALSE; break;
      }
      insymbol();
     }

     /* literal constant? */
     if ((sym == shortconst) || (sym == longconst) || (sym == singleconst))
     { 
      numconstant=TRUE; 
      consttyp=typ; 
      switch(consttyp)
      {
       case shorttype  : shortc=shortval; break;
       case longtype   : longc=longval; break;
       case singletype : singlec=singleval; break;
      }
     }
     else
     /* defined constant? */
     if ((sym == ident) && (exist(id,constant))) 
     {
      consttyp=curr_item->type;
      if (consttyp != stringtype) 
      {
       numconstant=TRUE;
       switch(consttyp)
       {
        case shorttype  : shortc=curr_item->numconst.shortnum;   break;
        case longtype   : longc=curr_item->numconst.longnum;     break;
        case singletype : singlec=curr_item->numconst.singlenum; break;
       }
      }
      else _error(27);
     }  
     else _error(27);
    }

    /* create a new numeric constant? */
    if (numconstant)
    {          
     switch(consttyp) 
     {
      case shorttype   : enter(const_id,shorttype,constant,0); 
			 if (negate) shortc *= -1;
 		         curr_item->numconst.shortnum=shortc;
		         break;

      case longtype    : enter(const_id,longtype,constant,0);
			 if (negate) longc *= -1;
       		         curr_item->numconst.longnum=longc;
		         break;

      case singletype  : enter(const_id,singletype,constant,0);
			 if (negate) singlec = SPMul(singlec,-1.0);
		         curr_item->numconst.singlenum=singlec;
		         break;
     }
     insymbol();
    }
   }
  }
 }
 while (sym == comma);

 /* restore level */
 lev=oldlevel;
}

void declare_variable(vartype)
int vartype;
{
/* declare a variable 
   and initialise it. 
*/
char addrbuf[40];
LONG string_size=MAXSTRLEN;
BOOL normal_string_variable=TRUE;
SYM  *str_item;

 do
 {
  insymbol();
  if (sym != ident) _error(7);
  else
  {
   if (exist(id,variable)) { _error(54); insymbol(); }
   else
   {
    enter(id,vartype,variable,0);

    itoa(-1*curr_item->address,addrbuf,10);
    strcat(addrbuf,frame_ptr[lev]);
    
    insymbol();

    switch(vartype)
    {
     case shorttype  :  gen("move.w","#0",addrbuf); break;

     case longtype   :  gen("move.l","#0",addrbuf); break;

     case singletype :  gen("move.l","#0",addrbuf); break; 

     case stringtype :  str_item = curr_item;
			if (sym == addresssym)
			{
			 normal_string_variable=FALSE;
			 /* don't want to create a BSS object! */
			 str_item->new_string_var=FALSE; 

 		 	 insymbol();
			 if (expr() != longtype)
        		    _error(4);
     			 else
         		     /* store address of string in stack frame */
         		     gen("move.l","(sp)+",addrbuf);	    
			}
			else
			if (sym == sizesym)
			{
			 insymbol();
			 if (sym == shortconst) string_size=(LONG)shortval;
			 else
			 if (sym == longconst) string_size=longval;
			 else 
			 if (sym == ident && exist(id,constant))
			 {
			  if (curr_item->type == shorttype)
			     string_size=(LONG)curr_item->numconst.shortnum;
			  else	
			  if (curr_item->type == longtype)
			     string_size=curr_item->numconst.longnum;
			  else
			      _error(4);
			 }
			 else
			 if (sym == singleconst) 
			     _error(4);
			 else
			     _error(27); /* numeric constant expected */

			 if (string_size <= 0L) _error(41); /* not positive! */

			 insymbol();
			}
			
			if (normal_string_variable)
			{
			 /* initialise with the NULL string */
			 enter_DATA("_nullstring:","dc.b 0");
			 gen("pea","_nullstring","  ");
			 assign_to_string_variable(str_item,string_size);
			}
			
			str_item->decl=declared;
			str_item->size=string_size; 

			break;       
    }
   }
  }
 }
 while (sym == comma); 
}

void define_external_object()
{
 /* declare an external 
    function or variable 
 */
 
 insymbol();
 if (sym  == functionsym) 
    define_external_function();
 else
    define_external_variable();
}
  
void define_external_variable()
{
/* declare an external variable */
char buf[MAXIDSIZE],extvarid[MAXIDSIZE+1];
int  oldlevel;
int  vartype=undefined;

 /* all external variables are at level ZERO */
 oldlevel=lev;
 lev=ZERO;

 /* type identifiers */
 if (sym == shortintsym || sym == longintsym || sym == addresssym ||
     sym == singlesym || sym == stringsym)
 {
   switch(sym)
   {
    case shortintsym : vartype = shorttype;  break;
    case longintsym  : vartype = longtype;   break;
    case addresssym  : vartype = longtype;   break;
    case singlesym   : vartype = singletype; break;
    case stringsym   : vartype = stringtype; break;
   }
   insymbol();
 }

 /* get the variable's name */
 if (sym != ident)
 	_error(7);
 {
 	/* 
	** Add an underscore prefix 
   	** if one is not present.
	*/
	strcpy(buf,ut_id);
	remove_qualifier(buf);
	if (buf[0] != '_')
	{
   		strcpy(extvarid,"_\0");
   		strcat(extvarid,buf);
  	}
  	else 
      		strcpy(extvarid,buf);

  	/* enter variable into symbol table */
 	if (vartype == undefined) vartype = typ;
  	if (exist(extvarid,extvar))
		_error(54);	/* variable exists */
	else
	{
  		enter(extvarid,vartype,extvar,0);

  		/* make an external reference to it */
  		enter_XREF(extvarid);
	}

  	insymbol();
 } 

 lev=oldlevel;
}

void define_external_function()
{
/* declare an external function */
char buf[MAXIDSIZE],extfuncid[MAXIDSIZE+1];
int  oldlevel;
int  functype=undefined;

 /* all external functions are at level ZERO */
 oldlevel=lev;
 lev=ZERO; 

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

 /* get the function's name */
 if (sym != ident)
    _error(7);
 {
  /* add an underscore prefix 
     if one is not present 
  */
  strcpy(buf,ut_id);
  remove_qualifier(buf);
  if (buf[0] != '_')
  {
   strcpy(extfuncid,"_\0");
   strcat(extfuncid,buf);
  }
  else 
      strcpy(extfuncid,buf);
  
  /* enter function into symbol table */
  if (functype == undefined) functype = typ; 
  if (exist(extfuncid,extfunc))
	_error(33);	/* duplicate function name */
  else
  {
  	enter(extfuncid,functype,extfunc,0);
  
  	/* make an external reference to it */
  	enter_XREF(extfuncid);
  }

  insymbol();
 } 

 lev=oldlevel;
}

void call_external_function(extfuncid,need_symbol)
char *extfuncid;
BOOL *need_symbol;
{
/* CALL an external function -- level ZERO */
SYM   *extfunc_item;
int   i;
SHORT popcount=0;
char  buf[40],numbuf[40];

  if (exist(extfuncid,extfunc)) /* preserve case */
  {
   /* save registers */
   gen("movem.l","d1-d7/a0-a6","-(sp)");

   extfunc_item=curr_item;
   /* insymbol() is called before entry to this function */
   if (sym == lparen) { load_mc_params(extfunc_item); *need_symbol=TRUE; } 
   else
      { extfunc_item->no_of_params=0; *need_symbol=FALSE; }

     /* call routine */
     gen("jsr",extfunc_item->name,"  ");

     /* pop parameters? */
     if (extfunc_item->no_of_params != 0)
     {
      popcount=0;
      for (i=0;i<extfunc_item->no_of_params;i++) 
      {
       if (extfunc_item->p_type[i] == shorttype) 
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

     /* restore registers */
     gen("movem.l","(sp)+","d1-d7/a0-a6"); 
  }
}

void define_common_or_global_variable(varsym)
int varsym;
{
/*
** Declare a common or global variable.
** Treated internally as an external variable.
*/
char buf[MAXIDSIZE];
char extvarid[MAXIDSIZE+2],extvarlabel[MAXIDSIZE+3];
int  oldlevel;
int  vartype=undefined;
SYM  *str_item;
LONG string_size = MAXSTRLEN;
BOOL normal_string_variable = TRUE;
char bss_size[20];

 insymbol();

 /* all common variables are at level ZERO */
 oldlevel=lev;
 lev=ZERO;

 /* optional type identifiers */
 if (sym == shortintsym || sym == longintsym || sym == addresssym ||
     sym == singlesym || sym == stringsym)
 {
   switch(sym)
   {
    case shortintsym : vartype = shorttype;  break;
    case longintsym  : vartype = longtype;   break;
    case addresssym  : vartype = longtype;   break;
    case singlesym   : vartype = singletype; break;
    case stringsym   : vartype = stringtype; break;
   }

   insymbol();
 }

 /* get the variable's name */
 if (sym != ident)
 	_error(7);
 {
 	/* 
	** Add an underscore prefix 
   	** if one is not present.
	*/
	strcpy(buf,ut_id);
	remove_qualifier(buf);
	if (buf[0] != '_')
	{
		sprintf(extvarid,"_%s",buf);
  	}
  	else 
      		strcpy(extvarid,buf);
	
  	/* enter variable into symbol table */
 	if (vartype == undefined) vartype = typ;
  	if (exist(extvarid,extvar))
		_error(54);	/* variable exists  */
	else
	{
		enter(extvarid,vartype,extvar,0);
		
		/* 
		** Make an appropriate BSS object.
		*/
		sprintf(extvarlabel,"%s:",extvarid);
		switch(vartype)
		{
			case shorttype:	 enter_BSS(extvarlabel,"ds.w 1"); 
					 gen("move.w","#0",extvarid);
					 insymbol(); break;

			case longtype: 	 enter_BSS(extvarlabel,"ds.l 1");
					 gen("move.l","#0",extvarid); 
					 insymbol(); break;

			case singletype: enter_BSS(extvarlabel,"ds.l 1"); 
					 gen("move.l","#0",extvarid); 
					 insymbol(); break;

			case stringtype: insymbol();
				 	 if (sym == sizesym)
					 { 
			 			insymbol();

						/* create own BSS object */
			 			str_item->new_string_var = FALSE; 

			 			if (sym == shortconst) string_size=(LONG)shortval;
			 			else
			 			if (sym == longconst) string_size=longval;
			 			else 
			 			if (sym == ident && exist(id,constant))
			 			{
			  				if (curr_item->type == shorttype)
			     				  string_size=(LONG)curr_item->numconst.shortnum;
			  				else	
			  				if (curr_item->type == longtype)
			     				  string_size=curr_item->numconst.longnum;
			  				else
			      				  _error(4);
			 		 	}
			 		 	else
			 		 	if (sym == singleconst) 
			     				_error(4);
			 		 	else
			     				_error(27); /* numeric constant expected */

			 		 	if (string_size <= 0L) _error(41); /* not positive! */

			 		 	insymbol();
				 	}
			
					str_item->decl=declared;
					str_item->size=string_size; 

					/*
					** Create BSS object.
					*/
					sprintf(bss_size,"ds.l %d",string_size);
					enter_BSS(extvarlabel,bss_size);

				 	if (normal_string_variable)
				 	{
			 			/* initialise with the NULL string */
			 			enter_DATA("_nullstring:","dc.b 0");
			 			gen("lea",extvarid,"a0");
			 			gen("lea","_nullstring","a1");
			 			gen("jsr","_strcpy","  ");
						enter_XREF("_strcpy");
				 	}
			
					break;       
		}

		/*
		** Only make it externally referenceable if it's a COMMON variable
		** not a GLOBAL variable.
		*/
		if (varsym == commonsym)
		{
  			/* 
			** Make it externally referenceable.
			** The '*' is used by enter_XREF() 
			** to make this an XDEF.
			*/
			extvarid[0] = '*';
  			enter_XREF(extvarid);
		}
	}
 } 

 lev=oldlevel;
}
