/*
** Unix-style hassle free memory allocation
** via Intuition's Alloc/FreeRemember() functions
** which keep track of memory allocations for ease
** of deallocation.
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
** Call alloc() or ACEalloc() for each memory allocation 
** request.
**
** Call free_alloc() once at the end of a program
** to free ALL allocated chunks.
**
** Call clear_alloc() whenever ACEalloc() allocations 
** must be cleared before the end of a program run. 
** Calls to ACEalloc() may be freely made subsequently.
**
** Author: David J Benn
**   Date: 30th June 1993, 1st July 1993,
**	   4th April 1994,
**	   2nd September 1994,
**	   11th March 1995
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>

/* Allocation lists for db.lib functions and ACE programs. */
struct Remember *RememberList = NULL;
struct Remember *AceAllocList = NULL;

/* Functions */
ULONG TheFlags(MemType,bytes)
LONG MemType,bytes;
{
ULONG flags;

 	switch(MemType)
 	{
  		case 0L : flags = MEMF_CHIP; break;
  		case 1L : flags = MEMF_FAST; break;
  		case 2L : flags = MEMF_PUBLIC; break;

  		case 3L : flags = MEMF_CHIP | MEMF_CLEAR; break;
  		case 4L : flags = MEMF_FAST | MEMF_CLEAR; break;
  		case 5L : flags = MEMF_PUBLIC | MEMF_CLEAR; break;

		case 6L : flags = MEMF_ANY; break;
		case 7L : flags = MEMF_ANY | MEMF_CLEAR; break;

		/* see basfun.c */
		case 9L : flags = MEMF_ANY | MEMF_CLEAR; break;	

		/* if all else fails... */
  		default : flags = MEMF_ANY | MEMF_CLEAR; break;
 	}

	return flags;
}

ULONG alloc(MemType,bytes)
LONG MemType,bytes;
{
/* 
** Allocate memory as requested (for db.lib functions). 
*/	
 	return((ULONG)AllocRemember(&RememberList,bytes,TheFlags(MemType,bytes)));     
}

ULONG ACEalloc(MemType,bytes)
LONG MemType,bytes;
{
/* 
** Allocate memory as requested (for ACE programs). 
*/	
 	return((ULONG)AllocRemember(&AceAllocList,bytes,TheFlags(MemType,bytes)));     
}

void free_alloc()
{
/* 
** Free all memory allocated by AllocRemember().
*/
	if (RememberList != NULL) FreeRemember(&RememberList,TRUE);
	if (AceAllocList != NULL) FreeRemember(&AceAllocList,TRUE);
}

void clear_alloc()
{
/* 
** Free all memory allocated by ACEalloc() thus far
** and prepare for subsequent calls to ACEalloc(). 
*/

	if (AceAllocList != NULL)
	{
		FreeRemember(&AceAllocList,TRUE);
		AceAllocList = NULL;
	}
}
