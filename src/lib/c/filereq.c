/* 
** Get the full path of a file
** via a file requester.
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
**
** Author: David J Benn
**   Date: 24th-28th December 1993,
**	   26th February 1994,
**	   10th September 1994
*/

#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <libraries/asl.h>

#define MAXSTRINGLEN 1024

/* Arp file requester structure declaration */
typedef struct ArpFileRequester {
	BYTE	*title;
	BYTE	*file;
	BYTE	*dir;	
	struct	Window	*window;
	UBYTE	funcflags;
	UBYTE	flags2;	
	void	(*userfunc)();
	WORD	leftedge;	
	WORD	topedge;						
} ARPREQ;

/* externals */
extern	struct	ExecBase *AbsExecBase;
extern	struct	Window *Wdw,*WBWdw;
extern	BYTE	IntuiMode;
	
/* globals */
struct	Library *AslBase=NULL;
struct 	Library *ArpBase=NULL;
static 	char	path[MAXSTRINGLEN];
                                       
/* function protos */
ULONG	FileRequest();

/* external functions */
extern	void	stringcopy();	

/* functions */
char *asl_filerequest(defdir,title)
char *defdir,*title;
{
/* 
** File requester for machines
** running version 2.04 or higher
** of the operating system.
*/
struct	TagItem	frtags[4];
struct 	FileRequester *FileReq;
char 	*file,*dir,*tmp;
int	tagnum=0;

 /* requester title */
 frtags[tagnum].ti_Tag  = ASL_Hail; 
 frtags[tagnum++].ti_Data = (ULONG)title;

 /* default directory? */
 if (defdir != NULL)
 {
 	frtags[tagnum].ti_Tag  = ASL_Dir;
	frtags[tagnum++].ti_Data = (ULONG)defdir;
 }

 /* specify window? */ 
 if (IntuiMode == 1)
 {
   frtags[tagnum].ti_Tag = ASL_Window; 
   frtags[tagnum++].ti_Data = (ULONG)Wdw;
 }

 frtags[tagnum].ti_Tag = TAG_DONE;

 path[0] = '\0';

 AslBase = (struct Library *)OpenLibrary(AslName,0L);
 if (AslBase == NULL) return(path);

 FileReq = (struct FileRequester *)AllocAslRequest(ASL_FileRequest,frtags);

 if (AslRequest(FileReq,NULL))  
 {  
   dir  = FileReq->rf_Dir;
   file = FileReq->rf_File;
   if (*dir != '\0') stringcopy(path,dir);
   tmp = path;
   while (*tmp) tmp++;
   if (*(tmp-1) != ':' && *dir != '\0') *tmp++ = '/';
   stringcopy(tmp,file); 
 }

 FreeAslRequest(FileReq);

 if (AslBase) CloseLibrary(AslBase);

 return(path);
}

char *custom_filerequest(defdir,title)
char *defdir,*title;
{
/* 
** File requester for machines
** running version 1.3 or less
** of the operating system.
**
** Arp.library must be installed
** in the LIBS: directory for this
** function to work.
*/
ARPREQ	*arpreq;
char	file[MAXSTRINGLEN],dir[MAXSTRINGLEN];
char	*tmp;
int	cc;

    dir[0] = '\0';
    file[0] = '\0';
    path[0] = '\0';                     

    /* default directory? */
    if (defdir != NULL) stringcopy(dir,defdir);

    /* open arp library */
    ArpBase = (struct Library *)OpenLibrary("arp.library",0L);
    if (ArpBase == NULL) return(path);

    /* allocate memory for requester structure */
    arpreq = (ARPREQ *)AllocMem(sizeof(ARPREQ),MEMF_ANY | MEMF_CLEAR);
    if (arpreq == NULL)       
    {
      if (ArpBase) CloseLibrary(ArpBase);
      return(path); 
    }      
            
    /* fill ARPREQ structure */                             
    arpreq->title	= (BYTE *)title;
    arpreq->file  	= (BYTE *)file;   
    arpreq->dir   	= (BYTE *)dir;
    if (IntuiMode == 1)
	arpreq->window	= Wdw;
    else
	arpreq->window	= NULL;
    arpreq->funcflags	= 0;
    arpreq->flags2	= 0;
    arpreq->userfunc	= NULL;
    arpreq->leftedge	= 20;
    arpreq->topedge	= 20;
                                           
    /* invoke arp file requester */                                
    if (FileRequest(arpreq) == 0L)           
    {
      if (arpreq) FreeMem(arpreq,sizeof(ARPREQ));
      if (ArpBase) CloseLibrary(ArpBase);
      return(path); 
    }                  
                  
   /* extract full path from ARPREQ structure */ 
   cc=0;   
   tmp = arpreq->dir;
   while (*tmp) { path[cc++] = *tmp++; }
   path[cc] = '\0';

   if (path[0] != '\0')
      if (path[cc-1] != ':') { path[cc++] = '/'; path[cc] = '\0'; }

   tmp = arpreq->file;                    
   while (*tmp) { path[cc++] = *tmp++; }
   path[cc] = '\0';

   if (arpreq) FreeMem(arpreq,sizeof(ARPREQ));
   if (ArpBase) CloseLibrary(ArpBase);

   return(path);         
}                           

char *filerequest(defdir,title)
char *defdir,*title;
{
/* 
** Invoke a file requester
** and return the full path
** of the selected file.
*/

  if (AbsExecBase->LibNode.lib_Version <= 34)	/* 1.3 or less? */
      return(custom_filerequest(defdir,title));
  else
      return(asl_filerequest(defdir,title));
}
