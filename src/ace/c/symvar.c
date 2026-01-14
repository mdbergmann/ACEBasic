/* << ACE >> 

   -- Amiga BASIC Compiler --

   ** Symbol Table/Code Generator Variables ** 
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
     Date: 19th October-30th November, 3rd-12th December 1991,
	   14th,27th January 1992, 5th,7th-17th, 
           23rd-24th February 1992,
           14th,22nd March 1992,
	   21st April 1992,
	   2nd,11th,15th May 1992,
	   7th,8th,9th,11th,13th,14th,28th June 1992,
	   2nd-6th,8th,14th-19th,26th,28th,29th July 1992,
	   1st,9th August 1992,
	   6th,22nd December 1992
*/

#include <acedef.h>

/* externals */
extern	BOOL 	dosused;
extern	BOOL 	gfxused;
extern	BOOL 	mathffpused;
extern	BOOL 	mathtransused;
extern	BOOL 	intuitionused;
extern	BOOL 	translateused;
extern	BOOL 	narratorused;
extern	BOOL 	basdatapresent;
extern	BOOL 	early_exit;
extern	SHORT 	dimsize[255];
extern	FILE 	*dest;
extern	int  	addr[2]; 
extern	int  	lev;

/* --symbol table-- */
STRUCM 	*new_structmem,*tail_structmem,*curr_structmem;
SYM  	*tab_head[2],*tab_tail,*new_item,*curr_item,*structdef_item;

/* --code hunk list-- */
CODE *code,*curr_code,*new_code;

/* --data hunk list-- */
DATA *data,*curr_data,*new_data;

/* --bss hunk list-- */
BSS *bss,*curr_bss,*new_bss;

/* --XREF list-- */
XREF *xref,*curr_xref,*new_xref;

/* --BASIC DATA list-- */
BASDATA *basdata,*curr_basdata,*new_basdata;
