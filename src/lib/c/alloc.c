/*
** Memory allocation for ACE BASIC programs and db.lib.
**
** ACE programs use ACEalloc/ACEfree with a custom doubly-linked
** list and AllocMem/FreeMem, supporting per-block deallocation.
**
** Internal db.lib functions use alloc() with Intuition's
** AllocRemember/FreeRemember (bulk deallocation only).
**
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
**   Date: 30th June 1993, 1st July 1993,
**	   4th April 1994,
**	   2nd September 1994,
**	   11th March 1995
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include "lib_protos.h"

/* Block header prepended to each ACEalloc allocation. */
struct AllocHeader {
	struct AllocHeader *prev;
	struct AllocHeader *next;
	ULONG size;
	ULONG flags;
};

#define HEADER_SIZE (sizeof(struct AllocHeader))

/* Allocation lists. */
struct Remember *RememberList = NULL;
static struct AllocHeader *AceAllocHead = NULL;

/* Memory flag lookup table indexed 0-9 (case 8 = default). */
static ULONG flagTable[10] = {
	MEMF_CHIP,				/* 0 */
	MEMF_FAST,				/* 1 */
	MEMF_PUBLIC,				/* 2 */
	MEMF_CHIP | MEMF_CLEAR,		/* 3 */
	MEMF_FAST | MEMF_CLEAR,		/* 4 */
	MEMF_PUBLIC | MEMF_CLEAR,		/* 5 */
	MEMF_ANY,				/* 6 */
	MEMF_ANY | MEMF_CLEAR,			/* 7 */
	MEMF_ANY | MEMF_CLEAR,			/* 8 = default */
	MEMF_ANY | MEMF_CLEAR			/* 9 = see basfun.c */
};

/* Functions */
ULONG TheFlags(MemType,bytes)
LONG MemType,bytes;
{
	if (MemType >= 0 && MemType <= 9)
		return flagTable[MemType];
	return MEMF_ANY | MEMF_CLEAR;
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
** Uses AllocMem with a prepended header for per-block deallocation.
*/
	ULONG fl;
	struct AllocHeader *hdr;

	fl = TheFlags(MemType, bytes);
	hdr = (struct AllocHeader *)AllocMem(HEADER_SIZE + bytes, fl);
	if (hdr == NULL) return 0;

	hdr->size = bytes;
	hdr->flags = fl;
	hdr->prev = NULL;
	hdr->next = AceAllocHead;
	if (AceAllocHead != NULL)
		AceAllocHead->prev = hdr;
	AceAllocHead = hdr;

	return (ULONG)((UBYTE *)hdr + HEADER_SIZE);
}

void ACEfree(ptr)
ULONG ptr;
{
/*
** Free a single block previously allocated by ACEalloc().
** Passing 0 is a safe no-op.
*/
	struct AllocHeader *hdr;

	if (ptr == 0) return;

	hdr = (struct AllocHeader *)((UBYTE *)ptr - HEADER_SIZE);

	if (hdr->prev != NULL)
		hdr->prev->next = hdr->next;
	else
		AceAllocHead = hdr->next;

	if (hdr->next != NULL)
		hdr->next->prev = hdr->prev;

	FreeMem(hdr, HEADER_SIZE + hdr->size);
}

void free_alloc()
{
/*
** Free all memory: db.lib RememberList + ACE allocation list.
*/
	struct AllocHeader *hdr, *nxt;

	if (RememberList != NULL) FreeRemember(&RememberList,TRUE);

	hdr = AceAllocHead;
	while (hdr != NULL)
	{
		nxt = hdr->next;
		FreeMem(hdr, HEADER_SIZE + hdr->size);
		hdr = nxt;
	}
	AceAllocHead = NULL;
}

void clear_alloc()
{
/*
** Free all memory allocated by ACEalloc() thus far
** and prepare for subsequent calls to ACEalloc().
*/
	struct AllocHeader *hdr, *nxt;

	hdr = AceAllocHead;
	while (hdr != NULL)
	{
		nxt = hdr->next;
		FreeMem(hdr, HEADER_SIZE + hdr->size);
		hdr = nxt;
	}
	AceAllocHead = NULL;
}
