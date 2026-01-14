/*
** ACE run-time library module: SCREEN(n) function.
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
**   Date: 28th August 1994
*/

#include <exec/types.h>
#include <intuition/intuition.h>

/* externals */
extern	struct Window *Wdw;	
extern	struct Screen *Scrn;
extern	struct RastPort *RPort;
extern	struct ViewPort *ViewPort;

/* functions */
LONG screenfunc(n)
LONG n;
{
/* 
** Return information about active screen/current output window (0,2).
*/

	switch(n)
	{
		case 0L :	return (LONG)Wdw;
		case 1L :	return (LONG)Scrn;
		case 2L :	return (LONG)RPort;
		case 3L :	return (LONG)ViewPort;
		case 4L :	return (LONG)&(Scrn->BitMap);
		case 5L :	return (LONG)Scrn->RastPort.Font->tf_XSize;
		case 6L :	return (LONG)Scrn->RastPort.Font->tf_YSize;
		default: 	return 0L;
				break;
	}
}
