/*
** ACE run-time library module: bevel-box function.
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
**   Date: 20th,24th,30th June 1994
*/

#include <exec/types.h>
#include <intuition/intuition.h>

#define RAISED 		1L
#define RECESSED 	2L
#define STRGADBOX	3L

/* externals */
extern	struct RastPort *RPort;

/* functions */
void	BevelBox(style,y2,x2,y1,x1)
ULONG 	style,x1,y1,x2,y2;		
{
/*
** Render a 3D bevel-box in one of 3 styles.
*/
ULONG 	width,height;
BYTE	old_fgpen;

	if (y1 > y2 || x1 > x2 ||
	   (style != RAISED && 
	    style != RECESSED && 
	    style != STRGADBOX)) return;

	width  = x2-x1;
	height = y2-y1;

	old_fgpen = RPort->FgPen;

	if (style == RAISED)
	{
		/* raised 3D style */

		SetAPen(RPort,1L);
		Move(RPort,x2,y1); Draw(RPort,x2,y2);       /* rt side */
		Move(RPort,x2-1,y1); Draw(RPort,x2-1,y2-1); /* rt thickening */
		Move(RPort,x1,y2); Draw(RPort,x2,y2);	    /* bottom */	

		SetAPen(RPort,2L);
		Move(RPort,x1,y1); Draw(RPort,x1,y2);	    /* lt side */
		Move(RPort,x1+1,y1); Draw(RPort,x1+1,y2-1); /* lt thickening */
		Move(RPort,x1,y1); Draw(RPort,x2-1,y1);     /* top */	

		/* reset fgnd pen colour */
		SetAPen(RPort,old_fgpen);
	}
	else
	if (style == RECESSED)
	{
		/* recessed 3D style */

		SetAPen(RPort,2L);
		Move(RPort,x2,y1); Draw(RPort,x2,y2);	    /* rt side */
		Move(RPort,x2-1,y1); Draw(RPort,x2-1,y2-1); /* rt thickening */
		Move(RPort,x1,y2); Draw(RPort,x2,y2);	    /* bottom */	

		SetAPen(RPort,1L);
		Move(RPort,x1,y1); Draw(RPort,x1,y2);	    /* lt side */
		Move(RPort,x1+1,y1); Draw(RPort,x1+1,y2-1); /* lt thickening */
		Move(RPort,x1,y1); Draw(RPort,x2-1,y1);     /* top */	

		/* reset fgnd pen colour */
		SetAPen(RPort,old_fgpen);
	}
	else
	{
		/* new look 3D string gadget */

		BevelBox(RAISED,y2,x2,y1,x1);		
		BevelBox(RECESSED,y2-1,x2-2,y1+1,x1+2);		
	}
}
