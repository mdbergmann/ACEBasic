/* <<ACE>> db.lib module: Generic window functions.
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
     Date: 5th,7th-9th,19th,24th-26th,28th,29th,31st October 1993,
	   1st,4th,8th,15th November 1993,
	   6th February 1994,
	   23rd,30th April 1994,
	   12th,24th,28th July 1994,
	   13th-15th,20th August 1994,
	   10th,11th September 1994,
	   3rd,4th December 1995
*/

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <exec/memory.h>
#include "intuievent.h"

#define MAXWDW			17L	/* shell wdw + user-wdws 1..16 */
#define CLEARED_ANY_MEM	 	7L
#define WINDOW_OPEN_ERR		700L

/* globals */
static 	BOOL 	first_wdw_creation=TRUE;
static 	USHORT 	wdw_close_num=0;

/* misc. external variables */
extern	ULONG	error_code;

/* screen/intuition window vs AmigaDOS window (shell/CLI) mode */
extern UBYTE IntuiMode;

/* screen pointers */ 
extern struct Screen *Scrn;
extern struct Screen *WBScrn;
extern struct Screen *Screen_list[10];	

/* Workbench Message */
extern	ULONG	WBenchMsg;

/* global window info */
extern	struct Window	*Wdw;
extern	struct RastPort	*RPort;

extern	USHORT	Wdw_id;
extern	struct	Window	 *WBWdw;
extern	struct	RastPort *WBRPort;
extern	USHORT	fgdpen;
extern	USHORT	bgpen;
extern	USHORT	WBfgdpen;
extern	USHORT	WBbgpen;

extern	struct	IntuitionBase *IntuitionBase;

/* turtle graphics info */
extern	USHORT	tg_initx;
extern	USHORT	tg_inity;
extern	USHORT	tg_tx;
extern	USHORT	tg_ty;
extern	USHORT	tg_degs;
extern	UBYTE	tg_pen;

/* window list */
typedef struct wdw_list_type
	{
		struct  Window 	 *Wdw;
		struct	RastPort *RPort;
		USHORT	fgdpen;
		USHORT	bgpen;
	} WDW;

WDW Wdw_list[MAXWDW] = { 
{NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0},
{NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0},
{NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0},
{NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0}, {NULL,NULL,0,0},
{NULL,NULL,0,0}
};
 
struct NewWindow NewWdw =
{
 0,0,
 0,0,				/* position & size */

 0,1,				/* detail & block pens */

 INTUITICKS |
 VANILLAKEY |
 MENUPICK |
 GADGETUP |
 ACTIVEWINDOW,			/* IDCMP Flags */

 0,				/* Flags */

 NULL,				/* first gadget */
 NULL,				/* CheckMark */
 NULL,				/* title */
 NULL,				/* Screen */
 NULL,				/* BitMap */

 -1,-1,
 -1,-1,				/* minimum & maximum window size */

 0				/* screen type */
};

/* prototypes */
void	MakeOutputWdw();

/* external functions */
extern 	void	ClearMenu();
extern	void	stringcopy();
extern	ULONG	stringlength();
extern	void	*alloc();

/* functions */
void	check_for_open_window()
{
/* Test for the presence of an open window
   on the current screen and make the highest
   numbered one (the first encountered) the
   current output window. This routine is called
   by _closescreen in scrwin.s.
*/
USHORT i,wdw_on_this_screen=FALSE;

	/* search for an open window on current screen */
	for (i=MAXWDW-1;i>=1;i--)
	    if (Wdw_list[i].Wdw->WScreen == Scrn)
	    { 
		wdw_on_this_screen = TRUE;
		break;
	    }

	/* set new output window? */
	if (wdw_on_this_screen) 
	{
		Wdw_id = i;
		MakeOutputWdw();
	}		
}

USHORT	only_shell_is_active()
{
/* Return true or false depending upon whether
   a shell is the only window open on the Wb
   screen and no other ACE screens are open.
*/
USHORT i, no_intui_wdw = TRUE;

	for (i=MAXWDW-1;i>=1;i--)
	    if (Wdw_list[i].Wdw) { no_intui_wdw = FALSE; break; }

	return(no_intui_wdw && WBenchMsg == NULL && Scrn == WBScrn);
}

void StoreWdwInfo()
{
/* store information about current window */

	Wdw_list[Wdw_id].Wdw	= Wdw;
	Wdw_list[Wdw_id].RPort	= RPort;
	Wdw_list[Wdw_id].fgdpen	= fgdpen;	
	Wdw_list[Wdw_id].bgpen 	= bgpen;	
}

void DeleteWdwInfo(window_id)
ULONG window_id;
{
/* zero all window list values for current window */
USHORT id;

	id = (USHORT)window_id;

	Wdw_list[id].Wdw	= 0L;
	Wdw_list[id].RPort	= 0L;
	Wdw_list[id].fgdpen	= 0;
	Wdw_list[id].bgpen 	= 0;
}

void MakeOutputWdw()
{
/*
** Make the Wdw_id'th window the current output window
** toggling IntuiMode if necessary. 
*/

	Wdw	= Wdw_list[Wdw_id].Wdw;
	RPort	= Wdw_list[Wdw_id].RPort;
	fgdpen	= Wdw_list[Wdw_id].fgdpen;
	bgpen	= Wdw_list[Wdw_id].bgpen;

	if (Scrn == WBScrn) 
	{
		WBWdw 	= Wdw;
		WBRPort = RPort;
		WBfgdpen= fgdpen;
		WBbgpen = bgpen;
	}

	/* 
	** If shell is new current output window switch
	** off IntuiMode.
	*/
	if (Wdw_id == 0 && WBenchMsg == NULL)
		IntuiMode = 0;
	else
		IntuiMode = 1;
}

void ChangeOutputWdw(window_id)
ULONG 	window_id;
{
/* change the current output window */
USHORT id;

	id = (USHORT)window_id;

	if (id < 0 || id > MAXWDW-1) return;
	
	Wdw_id = id;

	if (Wdw_list[id].Wdw != NULL) MakeOutputWdw();	
}

ULONG OpenWdw(screen,type,bottom,right,top,left,title,window_id)
ULONG   window_id;
UBYTE   *title;
ULONG   left,top,right,bottom;
ULONG   type,screen;
{
/* open an Intuition window */
USHORT   width, height,id;

	/* initialise shell window info? */
	if (first_wdw_creation)
	{
		first_wdw_creation = FALSE;

		/* shell/CLI open? */
		if (WBenchMsg == NULL)
		{
			Wdw_list[0].Wdw		= Wdw;
			Wdw_list[0].RPort	= RPort;
			Wdw_list[0].fgdpen	= fgdpen;	
			Wdw_list[0].bgpen 	= bgpen;	
		}
	}

	/* valid request? */
	id = (USHORT)window_id;

	if (id < 1 || id > MAXWDW-1 || Wdw_list[id].Wdw != NULL || 
	    right < left || bottom < top)
	{ 
		error_code = WINDOW_OPEN_ERR;
		return(NULL);
	}

	Wdw = NULL;

	/* complete NewWdw structure */
	width 	= right - left;
	height	= bottom - top;

	NewWdw.LeftEdge = (USHORT)left;
	NewWdw.TopEdge 	= (USHORT)top;	
	NewWdw.Width  	= width;
	NewWdw.Height 	= height;

	if (title != NULL)
	{
		NewWdw.Title = (UBYTE *)
		        	alloc(CLEARED_ANY_MEM,
				      stringlength(title)+1);

		if (NewWdw.Title == NULL) 
		{ 
			error_code = WINDOW_OPEN_ERR;
			return(NULL);
		}

		stringcopy(NewWdw.Title,title);
	}
	else
		NewWdw.Title = NULL;

	/* set window type */
 	NewWdw.Flags = GIMMEZEROZERO | ACTIVATE;

	if (type == -1) type = 31;	/* defaults to the works */

	if (type & 1) 	{ NewWdw.Flags |= WINDOWSIZING; 
			  NewWdw.IDCMPFlags |= NEWSIZE; }

	if (type & 2) 	{ NewWdw.Flags |= WINDOWDRAG; }

	if (type & 4) 	{ NewWdw.Flags |= WINDOWDEPTH; }

	if (type & 8) 	{ NewWdw.Flags |= WINDOWCLOSE; 
			  NewWdw.IDCMPFlags |= CLOSEWINDOW; }

	if (type & 16) 	
		{ NewWdw.Flags |= SMART_REFRESH; }
	else
		{ NewWdw.Flags |= NOCAREREFRESH; }

	if (type & 32)  { NewWdw.Flags |= BORDERLESS; }  /* ACE only! */

	/* Workbench or custom screen? */
	if (screen >= 1 && screen <= 9)
	{
		NewWdw.Type    	= CUSTOMSCREEN;
		NewWdw.Screen	= Screen_list[screen];
	}
	else
	if (screen == 0 || screen == -1)
		NewWdw.Type    	= WBENCHSCREEN;
	else
	{
		error_code = WINDOW_OPEN_ERR;
		return(NULL);  /* illegal screen id */
	}

	/* open window */
 	Wdw = (struct Window *)OpenWindow(&NewWdw);

	/* store window info */
	if (Wdw)
	{
		/* global info */
		Wdw_id		= id;
		RPort		= Wdw->RPort;
		fgdpen		= 1;
		bgpen		= 0;

		if (Scrn == WBScrn)
		{
			WBWdw 	 = Wdw;
			WBRPort	 = RPort;
			WBfgdpen = fgdpen;
			WBbgpen	 = bgpen;
		}

		/* turtle graphics info */
		tg_tx	= tg_initx;
		tg_ty	= tg_inity;
		tg_degs	= 270;
		tg_pen	= 1;

		/* window list info */
		StoreWdwInfo();	

		/* set IntuiMode */
		IntuiMode = 1;

		/* set first drawing position */
		Move(RPort,0,RPort->Font->tf_YSize - 2);
		SetAPen(RPort,1L);
	}

	if (Wdw == NULL) error_code = WINDOW_OPEN_ERR;

	return(Wdw);	/* NULL (error) or Wdw handle */
}

void CloseWdw(window_id)
ULONG  window_id;
{
/* close an Intuition window */
USHORT id,n;

	id = (USHORT)window_id;

	if (id < 1 || id > MAXWDW-1 || Wdw_list[id].Wdw == NULL) return;

	/* close window */
	ClearMenu();
 	if (Wdw_list[id].Wdw) CloseWindow(Wdw_list[id].Wdw);
	
	/* kill info about this window */
	DeleteWdwInfo(window_id);

	/* find next highest numbered open window and make it active */
	n=MAXWDW-1;
	while (n > 0 && Wdw_list[n].Wdw == NULL) --n;

	Wdw_id = n;

	/* set the new current output window */
	if (Wdw_list[Wdw_id].Wdw != NULL) MakeOutputWdw(); 	

	/* if Wdw-id=0 (shell) and only Wb screen -> IntuiMode OFF */
	if (Wdw_id == 0 && Wdw_list[0].Wdw && Scrn == WBScrn) IntuiMode = 0;
}

ULONG wdw_close_test(n)
LONG n;
{
/* Test for selection of a window's close gadget. */
BOOL	  wdw_closegadget_clicked=FALSE;
IntuiInfo *message;
ULONG	  MessageClass;
ULONG	  i;
	
	/* Test each user-defined window for a close-gadget click. 
	   If n=1 (compiler "-b" switch), close the window, otherwise 
	   make it the current output window so that the user-defined 
	   event trapping subroutine can call WINDOW(1) to close the 
	   window etc.
        */

	/* GADGET WAIT trapped a CLOSEWINDOW? */
	if (wdw_close_num >= 1 && wdw_close_num < MAXWDW)
	{
		if (n == 1) CloseWindow(Wdw_list[wdw_close_num].Wdw);
		wdw_close_num=0;
		return(1L);
	}

	/* ON WINDOW? */
	for (i=1;i<=MAXWDW-1 && !wdw_closegadget_clicked;i++)
	{
		if (Wdw_list[i].Wdw != NULL)
		   if ((message = 
			GetIntuiEvent(Wdw_list[i].Wdw->UserPort)) != NULL)
		   {
			MessageClass = message->Class;

			if (MessageClass & CLOSEWINDOW)	ClearIntuiEvent();

			if (MessageClass & CLOSEWINDOW)
			{
				wdw_closegadget_clicked = TRUE;
			
				if (n == 1)
				{
					/* close wdw before prg ends */
					CloseWindow(Wdw_list[i].Wdw);
				}
				else
				{
					/* make "close-gadget clicked" 
					   window the current one */
					ChangeOutputWdw(i);
				}
			}
		   }
	}
		
	/* return 0 or 1 */
	if (wdw_closegadget_clicked) 
	   	return(1L);
	else
		return(0L);
}

void set_wdw_close_num()
{
/* ON GADGET/MENU WAITing may get a CLOSEWINDOW message, 
   so set a variable to indicate this. ON WINDOW trapping
   will detect this and set the variable to 0 after 
   returning a positive window-close event indication.
*/

	wdw_close_num = Wdw_id;
}

LONG get_selected_wdw()
{
/*
** Return the window-id of the currently selected 
** window if it is an ACE window, otherwise zero.
**
** Note that zero will also be returned if the shell
** is the currently selected window.
*/
ULONG  ILock;
struct Window *selected_wdw;
LONG wdw_id = 0L;
int i;

	ILock = LockIBase(0L);
	selected_wdw = IntuitionBase->ActiveWindow;

	for (i=0;i<=MAXWDW-1;i++)
	    if (Wdw_list[i].Wdw == selected_wdw)
	    {
		wdw_id = i;
		break;
	    }	

	UnlockIBase(ILock);
	
	return(wdw_id);
}
