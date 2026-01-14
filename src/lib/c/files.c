/* ACE linked library module for the FILES command
** which gives a directory listing.
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

   ACE syntax: FILES [TO <storefile>] [,<target>]

   If <storefile> is specified, the listing will be
   captured by that file.

   If <storefile> is omitted, a valid _stdout is 
   assumed for the listing to be displayed. 

   The <target> argument can be a file, directory or
   an AmigaDOS device name.

   Author: David J Benn
     Date: 18th,21st May 1993,
	   10th September 1994
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>

extern struct FileHandle *stdout;

void show_info(info,out)
struct FileInfoBlock *info;
struct FileHandle *out;
{
/* show info about file/directory */
long entry_type;
char *name;

 /* get info */
 entry_type = info->fib_DirEntryType;
 name = info->fib_FileName;

 /* show or store info */ 
 if (entry_type > 0) 
    fprintf(out,"[%s]\n",name); /* directory name in brackets */
 else
    fprintf(out,"%s\n",name);
}

void files(target,store)
char *target,*store;
{
/* FILES [TO <storefile>] [,<target>] */
struct Process *process;
struct FileLock *lock;
struct FileHandle *store_fh;
struct FileInfoBlock *f_info;
 
 /* allocate memory for FIB -- must be long-word aligned */
 if ((f_info=(struct FileInfoBlock *)
    AllocMem(sizeof(struct FileInfoBlock),MEMF_ANY | MEMF_CLEAR))==NULL)
 return;

 /* get lock on directory */
 if (target)
 {
  /* target directory/file specified */
  lock = (struct FileLock *)Lock(target,ACCESS_READ);
 }
 else
 {
  /* no target specified -> get current directory for CLI/Wb command */
  process = (struct Process *)FindTask(0L);
  lock = (struct FileLock *)process->pr_CurrentDir;   
 }

 /* quit if lock is NULL */
 if (lock == NULL) 
    { FreeMem(f_info,sizeof(struct FileInfoBlock)); return; }

 /* set up file storage? */
 if (store)
 {
  if ((store_fh=(struct FileHandle *)Open(store,MODE_NEWFILE))==NULL)
     { FreeMem(f_info,sizeof(struct FileInfoBlock)); return; }
 }
 else
     store_fh = stdout;

 /* examine first entry */
 if (Examine(lock,f_info) == NULL)
    { FreeMem(f_info,sizeof(struct FileInfoBlock)); return; }

 /* show details of first entry */
 fprintf(store_fh,"Directory of: ");
 show_info(f_info,store_fh);

 /* if directory, examine contents */
 if (f_info->fib_DirEntryType > 0)
 {
  while (ExNext(lock,f_info) != NULL) 
        show_info(f_info,store_fh);
 }

 /* clean up */
 if (target) UnLock(lock);  /* don't free CLI/Wb lock! */ 
 FreeMem(f_info,sizeof(struct FileInfoBlock));
 if (store_fh != stdout) Close(store_fh);
}
