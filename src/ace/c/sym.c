/* << ACE >>
 
   -- Amiga BASIC compiler --

   ** Symbol Table Management & Code Generation **
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
     Date: 26th October-25th November, 2nd-13th December 1991,
	   27th January 1992, 8th-9th, 25th February 1992,
	   21st April 1992,
	   8th,9th,13th,14th,28th June 1992,
	   2nd,3rd,4th,5th,17th,26th,28th,29th July 1992,
	   1st-3rd,8th,9th August 1992,
	   6th,22nd,29th December 1992,
	   13th January 1993,
	   2nd,28th February 1993,
	   12th,20th April 1993,
	   15th-18th,28th December 1993,
	   7th January 1994,
	   26th February 1994,
	   12th June 1994,
	   20th August 1994,
	   10th September 1994
*/

#include "symvar.c"

/* -- general functions -- */
void kill_all_lists()
{
  lev=ONE;
  while (lev >= ZERO) { kill_symtab(); --lev; }
  puts("freeing code list...");
  kill_code();  /* all other lists are freed by cleanup() */
}

/* -- symbol table functions -- */
void new_symtab()
{
/* create a new symbol table
   at current level.
*/
 
 if ((tab_head[lev] = (SYM *)sym_alloc(sizeof(SYM),MEMF_ANY)) == NULL)
 {
  printf("Can't allocate memory for symbol table!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }
 tab_head[lev]->next = NULL;
}

void kill_symtab()
{
/* free memory held by 
   symbol table. 
*/
BOOL past_head=FALSE;
SYM  *curr,*temp;

 free_sym_alloc();
}

void find_tab_tail()
{
/* find the end of the 
   symbol table at current
   level.
*/
   
 tab_tail = tab_head[lev];
 while (tab_tail->next != NULL) tab_tail = tab_tail->next;
}

BOOL exist(name,obj)
char  *name;
int   obj;
{
int oldlevel;

 oldlevel=lev;

 if ((obj == subprogram) || (obj == function) || 
     (obj == definedfunc) || (obj == extfunc) || (obj == extvar) || 
     (obj == constant) || (obj == structdef)) lev=ZERO; 

 curr_item = tab_head[lev]->next;
 while (curr_item != NULL) 
 {
  if ((strcmp(curr_item->name,name) == 0) && (curr_item->object == obj))
     { lev=oldlevel; return(TRUE); }
  else
     curr_item = curr_item->next;
 }

 lev=oldlevel;
 return(FALSE);
}
 
void enter(name,typ,obj,dims)
/* enter a symbol into symbol table */
char  *name;
int   typ,obj;
int   dims;
{
int i;

 /* allocate memory for info' */
 if ((new_item = (SYM *)sym_alloc(sizeof(SYM),MEMF_ANY)) == NULL)
{
  printf("Can't allocate memory for symbol table item!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 if ((new_item->name = (char *)sym_alloc(strlen(name)+1,MEMF_ANY)) == NULL)
 {  
  printf("Can't allocate memory for symbol table item!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 /* fill the node with info' */
 strcpy(new_item->name,name);
 new_item->type = typ;
 new_item->object = obj;
 new_item->dims = dims;

 /* string defaults */
 if ((typ == stringtype) && (obj != array)) 
 {
  new_item->new_string_var=TRUE;
  new_item->decl=undeclared;
  new_item->size=MAXSTRLEN;
 }

 if ((obj != label) && (obj != function) && (obj != constant) &&
     (obj != extvar) && (obj != extfunc) && (obj != structdef))
 {
  /* how many bytes to reserve? */
  if ((typ == shorttype) && (obj != array)) 
     addr[lev] += 2;
  else
     addr[lev] += 4; /* long, single, string, array, sub, structure */

  new_item->address = addr[lev];
 }
 else 
     new_item->address = 0; 

 new_item->level = lev; 
 new_item->shared = FALSE;  /* shared may be explicitly SET later */

 /* array? -> store index maxima */
 if (obj == array)
 {
  if ((new_item->index = (SHORT *)sym_alloc((dims+1)*2,MEMF_ANY)) == NULL)
  {
   printf("Array index storage allocation error.\n");
   early_exit=TRUE;
   kill_all_lists();  
   cleanup();
  }
  else
      for (i=0;i<=dims;i++) new_item->index[i] = dimsize[i];
 }

 /* setup for structure definition */
 if (obj == structdef)
 {
  if ((new_item->structmem = 
                 (STRUCM *)sym_alloc(sizeof(STRUCM),MEMF_ANY)) == NULL)
  {
   printf("Can't allocate memory for an initial structdef node!\n");
   early_exit=TRUE;
   kill_all_lists();  
   cleanup();
  }
  else
  {
   new_item->structmem->next = NULL;
   new_item->size = 0;
  }
 }
 
 /* link item into symbol table */
 find_tab_tail(tab_head[lev]);
 tab_tail->next = new_item;
 new_item->next = NULL;
 curr_item = new_item;
}

/*
void show_table_item(item)
SYM *item;
{
 printf("%10s\t",item->name);
 showtyp(item->type);
 showobj(item->object);
 printf("%5d\t%5d\t%5d\n",item->dims,item->address,item->level);
}
*/

/* --code generator functions-- */

void create_lists()
{
/* create code, DATA, BSS, XREF and BASIC DATA lists */

 data = (DATA *)alloc(sizeof(DATA),MEMF_ANY);
 if (data == NULL) 
 { 
  cleanup(); 
 }
 else
    { curr_data = data; data->next = NULL; }

 bss = (BSS *)alloc(sizeof(BSS),MEMF_ANY);
 if (bss == NULL) 
 { 
  cleanup(); 
 } 
 else
    { curr_bss = bss; bss->next = NULL; }

 xref = (XREF *)alloc(sizeof(XREF),MEMF_ANY);
 if (xref == NULL)
 {
  cleanup();
 }
 else 
     { curr_xref = xref; xref->next = NULL; }

 basdata = (BASDATA *)alloc(sizeof(BASDATA),MEMF_ANY);
 if (basdata == NULL)
 {
  cleanup();
 }
 else
    { curr_basdata = basdata; basdata->next = NULL; }

 code = (CODE *)alloc_code("  ","  ","  ");  /* first node is a dummy */
 if (code == NULL) 
 {
    cleanup();
 }
 else
     { curr_code = code; code->next = NULL; }
}

BOOL is_a_label(opc)
char *opc;
{
int cc=0;

 while (opc[cc] != '\0') cc++;
 if (opc[cc-1] == ':') 
    return(TRUE);
 else
    return(FALSE);
}

void write_code(line)
CODE *line;
{
 if (strcmp(line->opcode,"nop") != 0)
 {
  if (!is_a_label(line->opcode))
  {
   fprintf(dest,"\t%s",line->opcode);  
   fprintf(dest,"\t%s",line->srcopr); 
   if (line->destopr[0] != ' ')  
      fprintf(dest,",%s\n",line->destopr);  /* comma & destopr */
   else
      fprintf(dest,"\n");  /* no destopr, so just LF */
  }
  else fprintf(dest,"%s\n",line->opcode);  /* label starts in 1st column */
 }
}

BOOL label_undef(node)
CODE *node;
{
char buf[50];

 if ((strcmp(node->opcode,"jmp") == 0) ||
    (strcmp(node->opcode,"jsr") == 0))
 {
  if (strcmp(node->destopr,"* ")==0)
  {
   /* undefined label at time of jmp/jsr */
   strcpy(buf,node->srcopr);
   strcat(buf,":\0");
   /* has it been defined since jmp/jsr? */
   if (exist(buf,label)) 
      { 
        strcpy(node->destopr,"  "); 
        return(FALSE); 
      }               /* not UNdefined */
   else
   {
      early_exit = TRUE;
      return(TRUE);   /* undefined */
   }
  }
  else return(FALSE); /* not UNdefined */
 }
 else return(FALSE);  /* not a branch instruction */
}

void undef_label_check()
{
BOOL past_head=FALSE;
 
 /* check for undefined labels */
 curr_code = code;
 while (curr_code->next != NULL) 
 {
  if (past_head)
  {
   if (label_undef(curr_code)) 
      { _error(8); printf("'%s'\n",curr_code->srcopr); }
  }
  curr_code = curr_code->next;
  if (!past_head) past_head=TRUE;
 }
 if (label_undef(curr_code)) 
    { _error(8); printf("'%s'\n",curr_code->srcopr); }
}
  
void kill_code()
{
BOOL past_head=FALSE;
CODE *curr,*temp;
 
 curr=code;

 do
 {
  temp=curr;
  curr=curr->next;
  if (past_head) 
  {
   if (!early_exit) write_code(temp);

   /* free all the struct's memory */
   free_code(temp);
  }

  if (!past_head) past_head=TRUE;
 }
 while (curr != NULL);

 /* free the dummy head node's memory */
 free_code(code);
}

void gen(opcode,srcopr,destopr)
char *opcode;
char *srcopr;
char *destopr;
{
 /* allocate memory for a new node & each field */
 if ((new_code = (CODE *)alloc_code(opcode,srcopr,destopr)) == NULL)
 {
  printf("Can't allocate memory for code node!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 /* fill code struct */
 strcpy(new_code->opcode,opcode);
 strcpy(new_code->srcopr,srcopr);
 strcpy(new_code->destopr,destopr);
 
 new_code->next = NULL;
 curr_code->next = new_code;
 curr_code = curr_code->next;
}

void change(cx,opcode,srcopr,destopr)
CODE *cx;
char *opcode;
char *srcopr;
char *destopr;
{
 /* free the old fields */
 free_code_members(cx);

 /* allocate memory & insert new instruction & operands */
 if ((BOOL)alloc_code_members(cx,opcode,srcopr,destopr))
 {
 	strcpy(cx->opcode,opcode);
 	strcpy(cx->srcopr,srcopr);
 	strcpy(cx->destopr,destopr);
 }
 else
 {
  printf("Can't allocate memory for CODE node fields!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }
}

/* --DATA list functions-- */

BOOL exist_DATA(name)
char *name;
{
DATA *curr;
 curr = data->next;
 while (curr != NULL) 
 {
  if (strcmp(curr->name,name) == 0)
     return(TRUE);
  else
     curr = curr->next;
 }
 return(FALSE);
}

void enter_DATA(name,literal)
char *name;
char *literal;
{
 if (exist_DATA(name)) return;  /* already exists */

 /* allocate memory for a new node & each field */
 if ((new_data = (DATA *)alloc(sizeof(DATA),MEMF_ANY)) == NULL)
 {
  printf("Can't allocate memory for DATA node!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }
 
 if ((new_data->name=(char *)alloc(strlen(name)+1,MEMF_ANY))==NULL)
 {
  printf("Can't allocate memory for DATA node name field!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 if ((new_data->literal=(char *)alloc(strlen(literal)+1,MEMF_ANY))==NULL)
 {
  printf("Can't allocate memory for DATA node literal field!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 /* fill DATA struct */
 strcpy(new_data->name,name);
 strcpy(new_data->literal,literal);
 
 new_data->next = NULL;
 curr_data->next = new_data;
 curr_data = curr_data->next;
}

void write_data()
{
BOOL past_head=FALSE;
DATA *curr,*temp;

 curr=data;
 if (curr->next != NULL)
 {
  fprintf(dest,"\n\tSECTION data,DATA\n\n");
 }

 do
 {
  temp=curr;
  curr=curr->next;
  if (past_head) 
  {
   fprintf(dest,"%s\t%s\n",temp->name,temp->literal);
  }
  if (!past_head) past_head=TRUE; 
 }
 while (curr != NULL);
}
      
/* --BSS list functions-- */

BOOL exist_BSS(name)
char *name;
{
BSS *curr;
 curr = bss->next;
 while (curr != NULL) 
 {
  if (strcmp(curr->name,name) == 0)
     return(TRUE);
  else
     curr = curr->next;
 }
 return(FALSE);
}

void enter_BSS(name,store)
char *name;
char *store;
{
 /* ignore if already exists, except if name is "  " 
    which is used for structure declarations */ 
 if ((exist_BSS(name)) && (strcmp(name,"  ") != 0)) return; 

 /* allocate memory for a new node & each field */
 if ((new_bss = (BSS *)alloc(sizeof(BSS),MEMF_ANY)) == NULL)
 {
  printf("Can't allocate memory for BSS node!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }
 
 if ((new_bss->name=(char *)alloc(strlen(name)+1,MEMF_ANY))==NULL)
 {
  printf("Can't allocate memory for BSS node name field!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 if ((new_bss->store=(char *)alloc(strlen(store)+1,MEMF_ANY))==NULL)
 {
  printf("Can't allocate memory for BSS node literal field!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 /* fill BSS struct */
 strcpy(new_bss->name,name);
 strcpy(new_bss->store,store);
 
 new_bss->next = NULL;
 curr_bss->next = new_bss;
 curr_bss = curr_bss->next;
}

void write_bss()
{
BOOL past_head=FALSE;
BSS  *curr,*temp;

 curr=bss;
 if (curr->next != NULL)
 { 
  fprintf(dest,"\n\tSECTION mem,BSS\n\n");
 }

 do
 {
  temp=curr;
  curr=curr->next;
  if (past_head) 
  {
   fprintf(dest,"%s\t%s\n",temp->name,temp->store);
  }
  if (!past_head) past_head=TRUE; 
 }
 while (curr != NULL);
}

/* --XREF list functions-- */

BOOL exist_XREF(name)
char *name;
{
XREF *curr;

 curr = xref->next;
 while (curr != NULL) 
 {
  if (strcmp(curr->name,name) == 0)
     return(TRUE);
  else
     curr = curr->next;
 }
 return(FALSE);
}

void enter_XREF(name)
char *name;
{
 if (exist_XREF(name)) return;   /* already exists */

 if (strcmp(name,"_DOSBase") == 0) dosused=TRUE;
 if (strcmp(name,"_MathBase") == 0) mathffpused=TRUE;
 if (strcmp(name,"_MathTransBase") == 0) mathtransused=TRUE;
 if (strcmp(name,"_GfxBase") == 0) gfxused=TRUE;
 if (strcmp(name,"_IntuitionBase") == 0) intuitionused=TRUE;
 if (strcmp(name,"_TransBase") == 0) translateused=TRUE;
 
 /* allocate memory for a new node & name field */
 if ((new_xref = (XREF *)alloc(sizeof(XREF),MEMF_ANY)) == NULL)
 {
  printf("Can't allocate memory for XREF node!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }
 
 if ((new_xref->name=(char *)alloc(strlen(name)+1,MEMF_ANY))==NULL)
 {
  printf("Can't allocate memory for XREF node name field!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 /* fill XREF struct */
 strcpy(new_xref->name,name);
 
 new_xref->next = NULL;
 curr_xref->next = new_xref;
 curr_xref = curr_xref->next;
}

void write_xrefs()
{
BOOL past_head=FALSE;
XREF *curr,*temp;

 fprintf(dest,"\n");

 curr=xref;
 do
 {
  temp=curr;
  curr=curr->next;
  if (past_head)
  { 
   /* xdef or xref? */
   if (temp->name[0] != '*')
   {
	/* XREF */
   	fprintf(dest,"\txref %s\n",temp->name);
   }
   else
   {
	/* XDEF -> first replace '*' with '_' */
	temp->name[0] = '_';
	fprintf(dest,"\txdef %s\n",temp->name);
   }
  }
  if (!past_head) past_head=TRUE; 
 }
 while (curr != NULL);
}

/* --BASIC DATA list functions-- */

void enter_BASDATA(literal)
char *literal;
{
 basdatapresent=TRUE;

 /* allocate memory for a new node & data */
 if ((new_basdata = (BASDATA *)alloc(sizeof(BASDATA),MEMF_ANY)) == NULL)
 {
  printf("Can't allocate memory for BASIC DATA node!\n");
  early_exit=TRUE;  
  kill_all_lists();
  cleanup();
 }

 if ((new_basdata->literal=(char *)alloc(strlen(literal)+1,MEMF_ANY))==NULL)
 {
  printf("Can't allocate memory for BASIC DATA node literal field!\n");
  early_exit=TRUE;
  kill_all_lists();
  cleanup();
 }

 /* fill BASDATA struct */
 strcpy(new_basdata->literal,literal);
 
 new_basdata->next = NULL;
 curr_basdata->next = new_basdata;
 curr_basdata = curr_basdata->next;
}

void write_basdata()
{
BOOL	past_head=FALSE;
BASDATA *curr,*temp;

 curr=basdata;

 if (curr->next != NULL)
 {
  fprintf(dest,"\n_BASICdata:\n");
 }

 do
 {
  temp=curr;
  curr=curr->next;
  if (past_head) 
  {
   fprintf(dest,"\t%s\n",temp->literal);
  }
  if (!past_head) past_head=TRUE; 
 }
 while (curr != NULL);
}


/* --structure functions-- */

void find_structmem_tail(symtabitem)
SYM *symtabitem;
{
/* find end of structdef member list. */
 tail_structmem = symtabitem->structmem;
 while (tail_structmem->next != NULL) tail_structmem = tail_structmem->next;
}

BOOL structmem_exist(symtabitem,name)
SYM  *symtabitem;
char *name;
{
/* seek a structure 
   member. 
*/

 curr_structmem = symtabitem->structmem->next; /* head has no member data */

 while (curr_structmem != NULL)
 {
  if (strcmp(curr_structmem->name,name) == 0) 
     return(TRUE);
  else
     curr_structmem = curr_structmem->next;
 }

 return(FALSE);   
}

void add_struct_member(symtabitem,name,mtype,structtype)
SYM  *symtabitem;
char *name;
int  mtype;
SYM  *structtype;
{
/* add a member to a
   structure definition.
*/

 if (structmem_exist(symtabitem,name))
    _error(61);
 else
 {
  /* add a unique member */
  if ((new_structmem = (STRUCM *)alloc(sizeof(STRUCM),MEMF_ANY)) == NULL)
  {
   printf("Can't allocate memory for structdef node!\n");
   early_exit=TRUE;
   kill_all_lists();  
   cleanup();
  }
  else
  {
   /* enter member data */
   strcpy(new_structmem->name,name);
   new_structmem->type = mtype;
   new_structmem->offset = symtabitem->size;
   
   /* link member into list */
   find_structmem_tail(symtabitem);

   new_structmem->next = NULL;
   tail_structmem->next = new_structmem;
   curr_structmem = new_structmem;
      
   /* increment size of structure 
      and hence, find next offset. 
   */
   switch(mtype)
   {
    case bytetype   : symtabitem->size += 1; break;
    case shorttype  : symtabitem->size += 2; break;
    case longtype   : symtabitem->size += 4; break;
    case singletype : symtabitem->size += 4; break;
    case stringtype : symtabitem->size += MAXSTRLEN; 
		      curr_structmem->strsize = MAXSTRLEN;
		      break;
    case structure  : symtabitem->size += structtype->size; 
		      curr_structmem->strsize = structtype->size;
		      break;
   }
  }     
 }
}
