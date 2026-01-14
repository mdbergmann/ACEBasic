/*
** ACE db.lib module: change text style or font.
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
**   Date: 31st January 1994,
**	   1st,6th February 1994,
**	   20th March 1994,
**	   20th,28th August 1994,
**	   10th September 1994,
**	   17th October 1996
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>

#define	CLEARED_ANY_MEM 7L

/* Globals */
struct Library 	*DiskfontBase;	

/* Externals */
extern 	struct 	RastPort *RPort;
extern	UBYTE	IntuiMode;

/* External Functions */
extern 	void 	stringcopy();
extern 	ULONG 	stringlength();
extern	LONG	stringcompare();
extern	void	*alloc();

/* Functions */
void change_text_style(style)
LONG style;
{
/*
** Change the text style for the current rastport or console window.
*/
	
	if (IntuiMode)
	{
		/* plain, underlined, bold, italic, extended */	
		SetSoftStyle(RPort,style,(ULONG)AskSoftStyle(RPort));
	}
	else
	/* plain, underlined, bold, italic */
	if (style >= 0 && style <= 7)
	{
		/* 
		** Reset console text styles to plain.
		** A style of zero will do ONLY this.
		*/
		putchar(27);
		printf("[0m");

		/* underlined */
		if (style & 1) { putchar(27); printf("[4m"); }

		/* bold */
		if (style & 2) { putchar(27); printf("[1m"); }

		/* italic */
		if (style & 4) { putchar(27); printf("[3m"); }
	}
}

void change_text_font(size,name)
LONG size;
char *name;
{
/*
** Change the font for the current output window's rastport 
** (intuition windows ONLY).
*/
char	*tmp,*font;
struct 	TextAttr myFont;
struct 	TextFont *FontPtr;

	DiskfontBase = (struct Library *)
			OpenLibrary("diskfont.library",0L);

	if (DiskfontBase)
	{
		/* append ".font" to name if not present */
		font = (char *)alloc(CLEARED_ANY_MEM,stringlength(name)+6);
					
		stringcopy(font,name);
		tmp = font;
		while (*tmp && *tmp != '.') tmp++;
		if (stringcompare(tmp,".font") != 0)
		   stringcopy(tmp,".font");

		/* set up TextAttr structure */
		myFont.ta_Name 	= (STRPTR)font;
		myFont.ta_YSize	= (UWORD)size;
		myFont.ta_Style	= 0;
		myFont.ta_Flags	= 0;

		/* attempt to open font */
		FontPtr = (struct TextFont *)OpenDiskFont(&myFont);	

		/* set new font and close old one */
		if (FontPtr) 
		{
			CloseFont(RPort->Font);
			SetFont(RPort,FontPtr);
		}

		/* cleanup */
		CloseLibrary(DiskfontBase);
	} 
}
