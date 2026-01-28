/*
** Random file library functions for ACE.
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
** Note: According to the 2.04 (KS 37.175) dos.library autodocs,
** 	 Seek() doesn't return -1 for V36 or V37, and IoErr()
**	 must be called. However, under pre-2.x/3.x systems (according 
**	 to the 2nd edition Bantam AmigaDOS reference), under 2.04 
**	 (by testing), and under 3.0 (by testing), Seek() _does_
**	 return -1 upon failure. That's good enough for me. Accordingly,
**	 ACE's error_code value is set to the dos/dos.h ERROR_SEEK_ERROR
**	 value when Seek() returns -1. Why not just call IoErr() you ask?
**	 Because the value IoErr() returns after Seek() returns -1 were
**	 found to be different under 2.04 and 3.0! Geez! What the heck are 
**	 these guys trying to do to me!? And I think _my_ code is inconsistent
**	 sometimes!
**
** Author: David J Benn
**   Date: 9th-11th March 1996
*/

#include <exec/types.h>
#include <libraries/dos.h>

#define ERR 			-1L
#define MAXFILE			255L
#define BAD_FILE_NUMBER		52L	/* see also ACE:lib/asm/file.s [BFN] */
#define	BAD_RECORD_NUMBER	63L
#define NEXT			0L

/*
** External variables.
*/
extern	LONG error_code;
extern	file_handle_list[255];

/*
** Function definitions.
*/
void GetRecord(recordNum, bytes, buffer, fileNum)
LONG recordNum;
LONG bytes;
void *buffer;
LONG fileNum;
{
/*
** Get the specified record (1..N) from 
** the specified file (1..255), placing 
** it into the supplied buffer.
*/
BPTR fh;
LONG result;

	if (fileNum < 1 || fileNum > 255)
	{
		error_code = BAD_FILE_NUMBER;
		return;
	}
	else
	if (recordNum < 1 && recordNum != NEXT)
	{
		error_code = BAD_RECORD_NUMBER;
		return;
	}
	else	
	{
		fh = file_handle_list[fileNum-1];
		if (fh == NULL)
		{
			error_code = BAD_FILE_NUMBER;
			return;
		}

		/*
		** Position the file pointer at the correct location?
		*/
		if (recordNum != NEXT)
		{
			/*
			** Position the file pointer so we're ready to read.
			*/
			result = Seek(fh,bytes*(recordNum-1),OFFSET_BEGINNING);
			if (result == ERR) 
			{
				error_code = ERROR_SEEK_ERROR;
				return;
			}
		}

		result = Read(fh,buffer,bytes);
		if (result != bytes) error_code = IoErr();
	}
}

void PutRecord(recordNum, bytes, buffer, fileNum)
LONG recordNum;
LONG bytes;
void *buffer;
LONG fileNum;
{
/*
** Store the specified record (1..N) in the
** specified file (1..255), taking it from
** the supplied buffer. If the file is
** not large enough to accommodate the 
** new record, make it so.
*/
BPTR fh;
LONG result;

	if (fileNum < 1 || fileNum > 255)
	{
		error_code = BAD_FILE_NUMBER;
		return;
	}
	else
	if (recordNum < 1 && recordNum != NEXT)
	{
		error_code = BAD_RECORD_NUMBER;
		return;
	}
	else	
	{
		fh = file_handle_list[fileNum-1];
		if (fh == NULL)
		{
			error_code = BAD_FILE_NUMBER;
			return;
		}
		
		/*
		** Position the file pointer at the correct location?
		*/
		if (recordNum != NEXT)
		{
			/*
			** Position the file pointer so we're ready to write.
			*/
			result = Seek(fh,bytes*(recordNum-1),OFFSET_BEGINNING);
			if (result == ERR) 
			{
				/*
				** Assume seek failed because the file
				** was too small. Attempt to increase 
				** the file's size (V36+ only, ie. not Wb 1.3).
				*/
				if (system_version() < 36)
				{
					error_code = ERROR_SEEK_ERROR;
					return;
				}
				else
				{
					/*
					** Set file pointer and therefore new end-of-file
					** to the _start_ of the record we want to write.
					*/
					result = SetFileSize(fh, bytes*(recordNum-1), OFFSET_BEGINNING);
					if (result == ERR)
					{
						error_code = ERROR_SEEK_ERROR;
						return;
					}
				}
			}
		}

		result = Write(fh,buffer,bytes);
		if (result != bytes) error_code = IoErr();
	}
}

LONG FilePosition(fileNum)
LONG fileNum;
{
/*
** Return the current position of the file
** pointer for the specified file, ie. the
** number of bytes read or written.
*/
BPTR fh;

	if (fileNum < 1 || fileNum > 255)
	{
		error_code = BAD_FILE_NUMBER;
		return;
	}
	else
	{
		fh = file_handle_list[fileNum-1];
		if (fh == NULL)
		{
			error_code = BAD_FILE_NUMBER;
			return;
		}

		return Seek(fh,0L,OFFSET_CURRENT);
	}
}
