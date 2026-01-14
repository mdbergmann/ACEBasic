/*
** ACE IFF commands.
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
**   Date: 27th February 1994,
**	   10th,11th,19th August 1994
*/

#include "acedef.h"

/* externals */
extern	int	sym;
extern	BOOL	iffused;

/* functions */
void	iff_open()
{
/* 
** IFF OPEN [#]channel,file-name
*/
int	itype;

	insymbol();

	if (sym == hash) insymbol();

	itype = expr();

	if (itype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(itype) == shorttype) make_long();
		
		if (sym != comma) 
			_error(16);
		else
		{
			/* picture file name */
			insymbol();
			if (expr() != stringtype)
				_error(4);
			else
			{
				/* call function */
				gen("jsr","_IFFPicOpen","  ");
				gen("addq","#8","sp");
				enter_XREF("_IFFPicOpen");
			}				
		} 
			
	}
}

void	iff_read()
{
/* 
** IFF READ [#]channel[,screen-id]
*/
int	itype;

	insymbol();

	if (sym == hash) insymbol();

	itype = expr();

	if (itype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(itype) == shorttype) make_long();

		if (sym != comma)
			/* no screen-id */
			gen("move.l","#-1","-(sp)");	
		else
		{
			/* screen-id */

			insymbol();
			
			itype = expr();

			if (itype == stringtype)
				_error(4);
			else
			{
				if (make_integer(itype) == shorttype) 
				   make_long();

			}
		}

		/* call function */
		gen("jsr","_IFFPicRead","  ");
		gen("addq","#8","sp");
		enter_XREF("_IFFPicRead");
	}
}

void	iff_close()
{
/* 
** IFF CLOSE [#]channel
*/
int	itype;

	insymbol();

	if (sym == hash) insymbol();

	itype = expr();

	if (itype == stringtype)
		_error(4);
	else
	{
		/* channel */
		if (make_integer(itype) == shorttype) make_long();

		/* call function */
		gen("jsr","_IFFPicClose","  ");
		gen("addq","#4","sp");
		enter_XREF("_IFFPicClose");
	}
}

void iff()
{
/* IFF OPEN | READ | CLOSE */

	insymbol();
	
	switch(sym)
	{
		case opensym  : iff_open(); break;
		case readsym  : iff_read(); break;
		case closesym : iff_close(); break;
	}

	/* 
	** All three require intuition.library.
	*/
	enter_XREF("_IntuitionBase");

	/*
	** We need to tell ACE to create/delete ILBM.library.
	*/
	iffused = TRUE;
}
