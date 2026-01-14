/*
** ACE run-time module to create/delete temporary ILBM.library.
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
**   Date: 19th,21st,28th August 1994
*/

#include <exec/types.h>
#include <libraries/dos.h>

#define	LIB_DIR 	"ram:ILBMtmp"
#define	ILBM_library 	"ram:ILBMtmp/ilbm.library"

/* globals */
BOOL	dir_created = FALSE;
BOOL	lib_created = FALSE;

/* externals */
extern	UBYTE ILBM_bytes[];

/* functions */
void create_ILBMLib()
{
/*
** Create ILBM.library from a buffer
** containing its bytes. 
*/
struct Lock *lock;
struct FileHandle *fh;

	/*
	** Create ram:ILBMtmp and/or ILBM.library?
	*/
	fh = (struct FileHandle *)Open("libs:ilbm.library",MODE_OLDFILE);
	if (fh == NULL)
	{
		/*
		** Create ram:ILBMtmp. 
		*/
		lock = (struct Lock *)CreateDir(LIB_DIR);
		if (lock != NULL) 
		{
			UnLock(lock);
			dir_created = TRUE;
		}
	
		/*
		** Create ram:ILBMtmp/ILBM.library.
		*/
		fh = (struct FileHandle *)Open(ILBM_library,MODE_NEWFILE);
		if (fh != NULL)
		{
			Write(fh,ILBM_bytes,6924L);
			Close(fh);
			lib_created = TRUE;
		}
	}
}

void remove_ILBMLib()
{
/*
** Delete temporary ILBM.library and/or ram:ILBMtmp.
*/

	if (lib_created) DeleteFile((STRPTR)ILBM_library);
	if (dir_created) DeleteFile((STRPTR)LIB_DIR); 
}
