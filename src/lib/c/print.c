/* 
** <<ACE>> linked library module: DOS and Intuition window PRINT code. 
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
**   Date: 9th,10th,31st October 1993,
**	   1st November 1993,
**	   24th December 1993,
**	   17th September 1994
*/

#include <intuition/intuition.h>
#include <exec/types.h>

#define LF	0L
#define TAB	1L
#define SPC	2L
#define QUN	3L

#define FontX	(ULONG)(RPort->Font->tf_XSize)
#define FontY	(ULONG)(RPort->Font->tf_YSize)

#define currX	(ULONG)(RPort->cp_x)
#define currY	(ULONG)(RPort->cp_y)

/* external variables */
extern BYTE 	IntuiMode;
extern ULONG 	stdout;
extern struct 	RastPort *RPort;
extern struct   Window	 *Wdw;

/* external functions */
extern ULONG 	stringlength();
extern void 	beep();
extern void 	scroll_screen();
	
/* functions */
void Ucodeprint(code)
long code;
{
char qunmark = '?';
char space = ' ';

/* print LF, TAB, SPACE (etc) to DOS or Intuition window */

	if (IntuiMode == 0)
	{
		/* DOS window */
		switch(code)
		{
		 case LF	: putchar('\n'); break;
		 case TAB	: putchar(9); break;
		 case SPC	: putchar(' '); break;
		 case QUN	: putchar('?'); break;
		}		
	}
	else
	{
		/* Intuition window */	
		switch(code)
		{
		 case LF 	: printsLF(); 	break;
		 case TAB 	: printsTAB(); 	break;
		 case SPC	: Text(RPort,&space,1); break;
		 case QUN	: Text(RPort,&qunmark,1); break;
		}
	}		
}
	
BOOL special_character(ch)
char ch;
{
/* return true or false depending upon whether "ch" is
   in the range 0..31 and needs to be handled specially 
   by ACE ala AmigaBASIC.
*/

	if (ch==7 || ch==8 || ch==9 || ch==10 || ch==12 || ch==13)
		return(TRUE);
	else
		return(FALSE);
}

void act_on_special_character(ch)
char ch;
{
/* duplicate the effect that "ch" would have in
   an AmigaBASIC window. 
*/

	switch(ch)
	{
		/* BELL */
		case 7 : 	beep(); 
				break;

		/* BS */
		case 8 :	if (currX >= FontX)
				{
				  Move(RPort,currX-FontX,currY);
				  Text(RPort," ",1);
				  Move(RPort,currX-FontX,currY);
				}
				break;

		/* TAB */
		case 9 : 	Text(RPort,"    ",4);
				break;

		/* LF */
		case 10 :	Move(RPort,0L,currY+FontY);
				scroll_screen();
				break;

		/* CLS */
		case 12 : 	Move(RPort,0,0);
				ClearScreen(RPort);
				Move(RPort,currX,currY+FontY-2);
				break;

		/* CR */
		case 13 :	Move(RPort,0L,currY);
				break;
	}
}

void Ustringprint(str)
char *str;
{
/* print string to DOS or Intuition window */
char  *first,*last;
BOOL  special;
ULONG length;

	if (IntuiMode == 0)
	{
		/* DOS window */
		Write(stdout,str,stringlength(str));		
	}
	else
	{
		/* Intuition window */
		first = str;
		last = str;

		do
		{
		
			/* look for special character or end of string */
			while (!(special = special_character(*last)) &&
                               *last != '\0') ++last;
			
			/* print partial string, then special character */ 
			if (special)
			{
				length = last-first;
				if (length > 0) Text(RPort,first,length);
				act_on_special_character(*last);
				++last;
				first = last;	
			}
			else
			{
				/* print whole/rest of string! */
				length = last-first;
				if (length > 0) Text(RPort,first,length);
			}
		}
		while (*last != '\0');
	}		
}

void Ushortprint(num)
long num;
{
static char buf[40];
/* print short integer to DOS or Intuition window */

	/* convert to string */
	if (num >= 0) 
	   sprintf(buf," %ld",num);  /* leading space if num >= 0 */
	else
	   sprintf(buf,"%ld",num);
	
	/* display number as string */
	Ustringprint(buf);
}

void Ulongprint(num)
long num;
{
static char buf[40];
/* print long integer to DOS or Intuition window */

	/* convert to string */
	if (num >= 0) 
	   sprintf(buf," %ld",num);	/* leading space if num >= 0 */
	else
	   sprintf(buf,"%ld",num);
	
	/* display number as string */
	Ustringprint(buf);
}

void Usingleprint(num)
float num;
{
/* print single-precision float to DOS or Intuition window */

	/* display number as string */	
	Ustringprint(strsingle(num));
}
