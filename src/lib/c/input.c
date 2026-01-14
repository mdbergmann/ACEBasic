/* 
** <<ACE>> linked library module: DOS and Intuition window INPUT code. 
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
**   Date: 10th,11th October 1993,
**	   5th December 1993
*/

#include <exec/types.h>
#include <intuition/intuition.h>

#define BOOL 	short
#define TRUE	1
#define FALSE	0

/* external variables */
extern 	BYTE 	IntuiMode;
extern	SHORT	fgdpen;
extern 	ULONG 	stdin,stdout;
extern 	SHORT	Wdw_id;
extern	struct	Screen *Scrn;
extern 	struct 	Window *Wdw;
extern 	struct	RastPort *RPort;

/* globals */
static	char space = ' ';

/* external functions */
extern	void	scroll_screen();

/* functions */
void cursor()
{
char 	csr = '|';
ULONG	i,oldfg,maxcolr,x,y;
/* Display cursor in Intuition window */

	/* change foreground colour */
	oldfg = fgdpen;
	/* maximum colour-id = 2^depth-1 */
	maxcolr = 1;
	for (i=1;i<=Scrn->BitMap.Depth;i++) maxcolr <<= 1;
	--maxcolr;
	SetAPen(RPort,maxcolr);
			
	/* show cursor */
	Text(RPort,&csr,1L);
	x = RPort->cp_x - RPort->Font->tf_XSize;
	y = RPort->cp_y;
	Move(RPort,x,y);

	/* restore foreground colour */
	SetAPen(RPort,oldfg);
}

BOOL eoln(ch)
{
/* End of line? */

	if (ch == '\n' || ch == '\r')
	   return(TRUE);
	else
	   return(FALSE);	
}

void process_char(ch,ccol,buf)
char ch;
long *ccol;
char *buf;
{
ULONG x,y;
/* Display a character on a DOS or Intuition window
   or handle a non-printable character. 
*/

	/* display current character */
	if (IntuiMode == 0)
	{
		/* DOS window */
		if (ch == '\r') ch = '\n';   /* RAW: eoln = CR -> LF */
		if (ch != '\b')
	   		Write(stdout,&ch,1L);
		else
		if (*ccol > 0) 
		{
			/* erase character? */
			putchar('\b');
			putchar(' ');
			putchar('\b');	
		}		
	}
	else
	{
		/* Intuition window */
		if (ch != '\b') 
		{
			if (!eoln(ch))
			{
		   		Text(RPort,&ch,1L);
				cursor();
			}
		}
		else
		if (*ccol > 0)
		{
			/* erase character */
			x = RPort->cp_x - RPort->Font->tf_XSize;
			y = RPort->cp_y;
			Move(RPort,x,y);
			Text(RPort,&space,1L);
			Text(RPort,&space,1L);
			x = RPort->cp_x - ((RPort->Font->tf_XSize) << 1);
			y = RPort->cp_y;
			Move(RPort,x,y);
			cursor();
		}
	} 

	/* delete or store a character */
	if (ch == '\b') 
	{
	   	/* delete rightmost character */
	   	if (*ccol > 0) *ccol -= 1;
	}
	else
	{
		/* store character & advance to next */
		if (!eoln(ch))
		{
			buf[*ccol] = ch;
			*ccol += 1;
		}
	}	
}

char input_char()
{
char   	ch;
struct 	IntuiMessage *msg;
BOOL	no_key_press=TRUE;
/* Get a character from a DOS or Intuition window. */

	if (IntuiMode == 0)
	{
		/* DOS window */
		while (!WaitForChar(stdin,1L));
		Read(stdin,&ch,1L);
	}
	else
	{
		/* Intuition window */
		do
		{
			WaitPort(Wdw->UserPort);
			msg = (struct IntuiMessage *)GetMsg(Wdw->UserPort);
			if (msg && msg->Class & VANILLAKEY)
			{
				ch = (msg->Code & 0xff);
				no_key_press = FALSE;
				ReplyMsg(msg);
			}
			else
				if (msg) ReplyMsg(msg);
		}
		while (no_key_press);
	} 

	return(ch);
}

void Ustringinput(buf)
char *buf;
{
char 	ch;
ULONG	x,y;
long	bytes,ccol=0;
static	char csr_on[] 	= { 0x9b,0x20,0x70 };
static	char csr_off[] 	= { 0x9b,0x30,0x20,0x70 };
/* Input a string from a DOS or Intuition window. */

	/* turn cursor off */
	if (IntuiMode == 0) 
	   Write(stdout,csr_on,3L); 
	else
	   cursor();
	   
	/* CON: ? */
	if (Wdw_id == 0 && IntuiMode == 0) 
	{ 
		bytes = Read(stdin,buf,1024L); 
		buf[bytes-1] = '\0'; 
	}
	else
	{
		/* RAW: window or Intuition window */
		do
		{
			ch = input_char();
			process_char(ch,&ccol,buf);
		}
		while (!eoln(ch));

		buf[ccol] = '\0';
	}

	/* turn cursor off */
	if (IntuiMode == 0) 
	   Write(stdout,csr_off,4L);
   	else
	{
	   /* overwrite cursor */	 
  	   Text(RPort,&space,1L);

	   /* move to next line in Intuition window */
	   x = 1;
	   y = RPort->cp_y + RPort->Font->tf_YSize;
	   Move(RPort,x,y);
	   scroll_screen();
	}
}
