/* ACE pre-processor.
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

   functions: 	1. #INCLUDE "name"|<name> -- recursive file inclusion.
		2. '..	-- single-line comment.
		3. {..}	-- block comment.					
				
   Author: David J Benn
     Date: 4th,5th,7th,8th July 1992,
	   27th,29th December 1992,
	   26th,30th January 1993,
	   2nd,6th February 1993,
	   24th,25th December 1993,
	   2nd January 1994
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <stdio.h>

static char *version = "$VER: APP 1.1 (02.01.1994)";

#define MAXCHARS     	80

/* exit codes */
#define OK            	 0
#define ERR          	10

/* errors */
#define SRC_EQ_DEST	 0
#define CANT_OPEN_DEST 	 1
#define CANT_OPEN_SRC    2
#define NODE_ALLOC_ERR	 3
#define NAME_ALLOC_ERR	 4

/* linked-list of #included files */
typedef struct incl_file_list {
				char *filename;
				FILE *src;
				struct incl_file_list *next;
			      } INCL;

INCL 	*incl,*curr_incl,*new_incl;

FILE	*dest;

/* redefine ZC's CTRL-C testing function to do nothing! */
long	Chk_Abort() { return 0; }

/* external functions */
extern	void	*alloc();
extern	void	free_alloc();

/* functions */
void 	usage();
void 	_error();
BOOL 	isalpha();
void	user_break();
void	preprocess();
void	create_incl_list();
BOOL	incl_file_exists();
void	enter_incl_filename();
void	kill_incl_list();
void 	clear_ctrl_c();

void usage()
{
 puts("usage: APP <source> <destination>");
 exit(ERR);
}

void _error(n,filename)
int  n;
char *filename;
{
 switch(n)
 {
  case SRC_EQ_DEST    :	puts("source and destination must be different files.");
			break;

  case CANT_OPEN_DEST : printf("can't open destination file: %s\n",filename);
	   		break;

  case CANT_OPEN_SRC  : printf("can't open source file: %s\n",filename);
	   		break;

  case NODE_ALLOC_ERR : puts("can't allocate memory for file list node."); 
	   		kill_incl_list();
	   		fclose(dest);
	   		break;

  case NAME_ALLOC_ERR : puts("can't allocate memory for file list member.");
 	   		kill_incl_list();
	   		fclose(dest);
	   		break;
 }

 /* clean up and exit */
 free_alloc();
 exit(ERR);
}

void create_incl_list()
{
 /* create head of include file list */
 
 incl = (INCL *)alloc(sizeof(INCL),MEMF_PUBLIC);
 if (incl == NULL) _error(NODE_ALLOC_ERR,"  ");  
 else
     { curr_incl = incl; incl->next = NULL; }
}

BOOL incl_file_exists(name)
char *name;
{
INCL *curr;
 /* report whether an include file is
    on the list.
 */

 curr = incl->next;	/* start with first node after head */

 while (curr != NULL)
 {
  if (strcmp(curr->filename,name) == 0)
     return(TRUE);
  else
     curr = curr->next;
 }
 return(FALSE);  /* name not found */
}

void enter_incl_filename(name,src)
char *name;
FILE *src;
{
 /* add an include filename to the list
    if it doesn't already exist.
 */

 if (incl_file_exists(name)) return;	/* name is already on the list */

 /* allocate memory for a new list node */
 if ((new_incl = (INCL *)alloc(sizeof(INCL),MEMF_PUBLIC))==NULL)
    _error(NODE_ALLOC_ERR,"  ");

 /* allocate memory for a name in the new node */
 if ((new_incl->filename = (char *)alloc(strlen(name)+1,MEMF_PUBLIC))==NULL)
    _error(NAME_ALLOC_ERR,"  ");

 /* fill new node */
 strcpy(new_incl->filename,name);
 new_incl->src=src;
 new_incl->next = NULL;
 curr_incl->next = new_incl;
 curr_incl = curr_incl->next;  
}

void kill_incl_list()
{
INCL *curr,*temp;
BOOL past_head=FALSE;

 /* close #included files */

 curr=incl;	/* head of list */
 
 do
 {
  temp=curr;
  curr=curr->next;
  if (past_head)
     if (temp->src) fclose(temp->src);  /* close the file */

  if (!past_head) past_head=TRUE;
 }
 while (curr != NULL);  
}

BOOL isalpha(ch)
char ch;
{
 if (((ch >= 'a') && (ch <= 'z')) ||
     ((ch >= 'A') && (ch <= 'Z'))) return(TRUE);
 else
     return(FALSE);
}

void user_break()
{
 /* if user has hit ctrl-c, cleanup and abort. */

 if (SetSignal(0L,SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C)
 {
     puts("*** Break: app terminating.");
     kill_incl_list();
     fclose(dest);
     free_alloc();
     exit(ERR);
 }
}

void preprocess(srcfile)
char *srcfile;
{
FILE *src;
char ch,buf[MAXCHARS],incl_name[MAXCHARS],incl_path[MAXCHARS+11];
int  cc,i,blk_comment_lines;
BOOL block_comment,command,incl_dir;
BOOL inside_string_literal=FALSE;

 if (incl_file_exists(srcfile)) return;	 /* file has already been included */
 else
 if ((src=fopen(srcfile,"r")) == NULL) 
    printf("can't open %s\n",srcfile); 
 else
 {
  enter_incl_filename(srcfile,src);  /* record this file as #included */
  do
  {
   /* check for user break */
   user_break();

   block_comment=FALSE;
   command=FALSE;
   incl_dir=FALSE;

   ch=fgetc(src); 

   /* single-line comment */
   if (ch == '\'' && !inside_string_literal) 
      while (((ch=fgetc(src)) != '\n') && (ch != EOF));
   else
   /* multi-line comment */
   if (ch == '{' && !inside_string_literal) 
   {
    blk_comment_lines=0;
    while (((ch=fgetc(src)) != '}') && (ch != EOF)) 
          if (ch == '\n') ++blk_comment_lines;

    block_comment = TRUE;  /* don't want to copy "}" to dest file */

    /* send LF characters to dest file to keep line numbers
       the same as in the source file for errors etc.
    */
    for (i=1;i<=blk_comment_lines;i++) fputc('\n',dest);
   }
   else
   /* start or end of string literal? */
   if (ch == '"')
   {
    if (!inside_string_literal) inside_string_literal = TRUE;  /* start */
    else
        inside_string_literal = FALSE;  /* end */    
   }
   else
   /* pre-processor # command? */
   if (ch == '#')
   {
    /* pre-processor command may follow */
    cc=0;
    do 
    {
     ch=fgetc(src);
     if (isalpha(ch)) buf[cc++]=ch;
    }
    while (isalpha(ch) && (cc < MAXCHARS));

    buf[cc]='\0';
    strupr(buf);

    /* legal command? */
    if ((strcmp(buf,"INCLUDE") == 0) && 
       ((ch == '"') || (ch == '<') || (ch == ' '))) 
    {
     command=TRUE;
     /* get file name */
     cc=0;
     do 
     {
      /* skip whitespace */
      while ((ch <= ' ') && (ch != EOF)) ch=fgetc(src); 

      /* look for file in local include directory? */
      if (ch == '<') incl_dir=TRUE;

      ch=fgetc(src);
      if ((ch != '"') && (ch != '>') && (ch != EOF) && 
          (ch != '\n') && (cc < MAXCHARS)) incl_name[cc++]=ch;
     }
     while ((ch != '"') && (ch != '>') && (ch != EOF) && (ch != '\n') && 
	    (cc < MAXCHARS));
   
     /* use local include directory? */
     if (incl_dir) 
        strcpy(incl_path,"ACEinclude:");
     else
        incl_path[0]='\0';
  
     incl_name[cc]='\0';
     strcat(incl_path,incl_name);

     preprocess(incl_path); 

     /* skip the last '"' */
     ch=fgetc(src);  
    }
    else
        fprintf(dest,"#%s",buf);  /* just copy '#' and characters */
   }
   
   /* just copy character to dest */
   if ((ch != EOF) && !command && !block_comment) fputc(ch,dest);
  }
  while (ch != EOF);
 }
}

main(argc,argv)
int  argc;
char *argv[];
{
FILE *src;
int  result;

 printf("ACE preprocessor version 1.1, copyright ");
 putchar(169);
 printf(" 1992-1994 David Benn.\n");

 if (argc != 3) usage();

 /* are the two arguments the same? */
 if (strcmp(argv[1],argv[2]) == 0) _error(SRC_EQ_DEST,"  ");

 /* test for existence of source file */
 if ((src=fopen(argv[1],"r")) == NULL) _error(CANT_OPEN_SRC,argv[1]);
 fclose(src);  /* this is opened again by preprocess() */

 /* try to open destination file */
 if ((dest=fopen(argv[2],"w")) == NULL) _error(CANT_OPEN_DEST,argv[2]);

 open_intui_lib();

 create_incl_list();

 preprocess(argv[1]);

 kill_incl_list();

 fclose(dest);
 free_alloc();
 
 exit(OK);
}
