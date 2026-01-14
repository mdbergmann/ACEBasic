/* 
** <<ACE>> Linked library module: Menus.
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
**   Date: 9th-11th,13th,14th November 1993,
**	   5th December 1993,
**	   12th-15th January 1994,
**	   20th March,
**	   4th May 1994,
**	   12th,24th July 1994,
**	   3rd,10th September 1994,
**	   19th July 1996
*/

#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/gfxmacros.h>
#include "intuievent.h"

#define MINMENU	1
#define MAXMENU	10

#define MINITEM	0
#define MAXITEM	19

#define MAXWDW	9
#define MAXSCRN	9
#define MAXMBAR MAXWDW+MAXSCRN

#define CLEARED_ANY_MEM 7L

#define RPort	   (&(Scrn->RastPort))
#define FontHeight ((Scrn->RastPort.Font->tf_YSize)+1)

/* menu structures */
typedef struct menu_type {
				struct 	Menu info;
				SHORT	max_item_width;
				struct	IntuiText text[MAXITEM+1];
				struct	MenuItem item[MAXITEM+1];
			} MENU;

typedef struct mbar_type {
				struct 	Window *window;
				MENU 	menu[MAXMENU+1];
			} MBAR;

/* externals */
extern	struct	Window	 *Wdw;
extern	struct	Screen	 *Scrn;
extern	BYTE	IntuiMode;
 		
/* globals */
static	BOOL   first_created=TRUE;
static	MBAR   *mbar[MAXMBAR];
static	ULONG  menunum=0L;
static	ULONG  itemnum=0L;
static	ULONG  subitemnum=0L;
	 
/* external functions */
extern	void	*alloc();
extern	void	stringcopy();
extern	ULONG	stringlength();
extern	void	set_wdw_close_num();

/* 
** graphics.library function 
** to determine menu text length
** based upon font type and size.
*/
extern	WORD	TextLength();  

/* functions */
BOOL NewMenuBar(mbarnum)
ULONG *mbarnum;
{
/* 
** Make a new menu bar.
*/
ULONG i;
MBAR  *mbar_ptr;
BOOL  free_slot_found = FALSE;

	/* allocate memory for a new menu strip */
	mbar_ptr = (MBAR *)alloc(CLEARED_ANY_MEM,sizeof(MBAR));

	if (mbar_ptr == NULL) return(FALSE);

	/* find a free slot for it */
	for (i=1;i<=MAXMBAR;i++)
	    if (mbar[i] == NULL)
	    {
		free_slot_found = TRUE;
	    	mbar[i] = mbar_ptr;
		mbar[i]->window = Wdw;
		*mbarnum = i;
		break;
	    }

	/* 
	** zero maximum item width holders (in case this mbar
        ** has been used before!) 
	*/	
	if (free_slot_found)
	   for (i=MINMENU;i<=MAXMENU;i++)
	       mbar[*mbarnum]->menu[i].max_item_width = 0;

	return(free_slot_found);			
}

BOOL FindMBarNum(num)
ULONG *num;
{
/*
** Return true or false to indicate whether or not 
** this window has a menu bar and if it does, the 
** number of the menu bar for this window.
*/
ULONG i;
BOOL  found = FALSE;

	for (i=0;i<=MAXMBAR;i++)
	    if (mbar[i] != NULL && mbar[i]->window == Wdw) 
	    { 
		found = TRUE;
		*num = i;
		break; 
	    }

	return(found);
}

SHORT MenuLeftEdge(mbarnum,menu_id)
ULONG mbarnum,menu_id;
{
/* 
** Return the left edge of the menu relative
** to the left edge of the menu bar, leaving
** 2 spaces between each menu title.
*/
ULONG i;
SHORT total=0;

	if (menu_id == MINMENU)
	{
		return(0);
	}
	else
	{
		for (i=MINMENU;i<menu_id;i++)
		    if (mbar[mbarnum]) 
			total += (mbar[mbarnum]->menu[i].info.Width +
				  TextLength(RPort,(STRPTR)"  ",2));
				  
		return(total);
	}
}

SHORT MenuWidth(name)
BYTE  *name;
{
/* 
** Return the width of a menu name (plus 1 space).
*/

	return(TextLength(RPort,(STRPTR)name,(WORD)stringlength(name)) +
	       TextLength(RPort,(STRPTR)" ",1));
}

SHORT MenuItemWidth(name)
BYTE  *name;
{
/* 
** Return the width of a menu item name.
*/

	return(TextLength(RPort,(STRPTR)name,(WORD)stringlength(name)) + 1);
}

BYTE *MakeName(name)
BYTE *name;
{
/* 
** Allocate memory for a name, copy the name into this memory
** region and return a pointer to the start of it.
*/
static BYTE *tmp;

	tmp = (BYTE *)alloc(CLEARED_ANY_MEM,stringlength(name)+1);
	if (tmp) stringcopy(tmp,name);
	return(tmp);
}

void SetItemWidths(mbarnum,menu_id)
ULONG mbarnum,menu_id;
{
/*
** Give each menu item's width member a value
** based upon the maximum item width so far.
**
** We're actually filling ALL items for this
** menu, even if they haven't been specified
** yet (or aren't ever going to be).
**
** Call this function for each item insertion.
**
*/
ULONG i;

	for (i=MINITEM+1;i<=MAXITEM;i++)
	    mbar[mbarnum]->menu[menu_id].item[i].Width = 
			mbar[mbarnum]->menu[menu_id].max_item_width;
}

void ModifyMenu(command,title,state,item_id,menu_id)
BYTE  *command,*title;
ULONG state,item_id,menu_id;
{
/* 
** Create or modify a menu or menu-item.
*/
ULONG i,mbarnum;
SHORT item_width;

	/* reasonable request? */
	if (menu_id < MINMENU || menu_id > MAXMENU ||
	    item_id < MINITEM || item_id > MAXITEM ||
	    IntuiMode == 0)
	return;

	/* prepare mbar array? */
	if (first_created)
	{
		first_created = FALSE;
		for (i=0;i<=MAXMBAR;i++) mbar[i] = NULL;
	}

	/* create a new mbar? */
	if (!FindMBarNum(&mbarnum))
	{
		/* 
		** prepare a new mbar return
		** if memory can't be allocated! 
		*/
		if (!NewMenuBar(&mbarnum)) return;
	}
	else
		ClearMenuStrip(Wdw);

	if (item_id == 0)
	{
	 /* menu title */

	 if (menu_id < MAXMENU)
	    mbar[mbarnum]->menu[menu_id].info.NextMenu = 
				&mbar[mbarnum]->menu[menu_id+1].info;
	 else
	    mbar[mbarnum]->menu[menu_id].info.NextMenu = NULL;

	 mbar[mbarnum]->menu[menu_id].info.LeftEdge = 
				MenuLeftEdge(mbarnum,menu_id);
	 mbar[mbarnum]->menu[menu_id].info.TopEdge  = 0;
	 mbar[mbarnum]->menu[menu_id].info.Width    = MenuWidth(title);
	 mbar[mbarnum]->menu[menu_id].info.Height   = FontHeight;

	 if (state != 0)
	    mbar[mbarnum]->menu[menu_id].info.Flags = MENUENABLED;

	 mbar[mbarnum]->menu[menu_id].info.MenuName = MakeName(title);

	 if (mbar[mbarnum]->menu[menu_id].info.FirstItem == NULL)
	    mbar[mbarnum]->menu[menu_id].info.FirstItem = 
				&mbar[mbarnum]->menu[menu_id].item[MINITEM+1];
	}
	else
	{
	 /* menu item */

	 /* fill intuitext structure */
	 mbar[mbarnum]->menu[menu_id].text[item_id].FrontPen = 0;
	 mbar[mbarnum]->menu[menu_id].text[item_id].BackPen  = 1;
	 mbar[mbarnum]->menu[menu_id].text[item_id].DrawMode = JAM2;
	 mbar[mbarnum]->menu[menu_id].text[item_id].LeftEdge = 1;
	 mbar[mbarnum]->menu[menu_id].text[item_id].TopEdge  = 1;
	 mbar[mbarnum]->menu[menu_id].text[item_id].ITextFont= NULL;
	 mbar[mbarnum]->menu[menu_id].text[item_id].IText = (UBYTE *)
							     MakeName(title);
	 mbar[mbarnum]->menu[menu_id].text[item_id].NextText = NULL;

	 /* fill menuitem structure */
	 if (item_id < MAXITEM)
		mbar[mbarnum]->menu[menu_id].item[item_id].NextItem =
				&mbar[mbarnum]->menu[menu_id].item[item_id+1];
	 else
		mbar[mbarnum]->menu[menu_id].item[item_id].NextItem = NULL;

	 mbar[mbarnum]->menu[menu_id].item[item_id].LeftEdge = 0;

	 mbar[mbarnum]->menu[menu_id].item[item_id].TopEdge = 
						(item_id-1)*FontHeight;
	 	
     	 mbar[mbarnum]->menu[menu_id].item[item_id].Height = FontHeight;

 	 mbar[mbarnum]->menu[menu_id].item[item_id].Flags = ITEMTEXT | HIGHCOMP;

	 switch(state)
	 {
	  case 0 :
	  mbar[mbarnum]->menu[menu_id].item[item_id].Flags &= ~ITEMENABLED;
 	  mbar[mbarnum]->menu[menu_id].item[item_id].Flags &=~(CHECKIT|CHECKED);
	  break;
	
	  case 1 :
	  mbar[mbarnum]->menu[menu_id].item[item_id].Flags |= ITEMENABLED;
	  mbar[mbarnum]->menu[menu_id].item[item_id].Flags &=~(CHECKIT|CHECKED);
	  break;
	
	  case 2 :
	  mbar[mbarnum]->menu[menu_id].item[item_id].Flags |= ITEMENABLED;
 	  mbar[mbarnum]->menu[menu_id].item[item_id].Flags |= CHECKIT|CHECKED;
	  break;
	 }

 	 mbar[mbarnum]->menu[menu_id].item[item_id].MutualExclude = 0; 

	 mbar[mbarnum]->menu[menu_id].item[item_id].ItemFill = 
			(APTR)&mbar[mbarnum]->menu[menu_id].text[item_id];

	 mbar[mbarnum]->menu[menu_id].item[item_id].SelectFill = NULL;

	 /*
	 ** Current menu item width.
	 */ 
	 item_width = MenuItemWidth(title);

	 /*
	 ** Command key?
	 */
	 if (command != NULL)
	 {
		mbar[mbarnum]->menu[menu_id].item[item_id].Command = *command;
		mbar[mbarnum]->menu[menu_id].item[item_id].Flags |= COMMSEQ;
		item_width += (TextLength(RPort,(STRPTR)"       ",7));
	 }
	 else
 	 	mbar[mbarnum]->menu[menu_id].item[item_id].Command = 0;

	 /* 
	 ** Is menu title width > biggest menu item width so far? 
	 */
	 if (mbar[mbarnum]->menu[menu_id].info.Width > item_width)
		item_width = mbar[mbarnum]->menu[menu_id].info.Width;

	 /* 
	 ** Is current item width > biggest item width so far? 
	 */
	 if (item_width > mbar[mbarnum]->menu[menu_id].max_item_width)
		mbar[mbarnum]->menu[menu_id].max_item_width = item_width;

 	 mbar[mbarnum]->menu[menu_id].item[item_id].SubItem = NULL;

 	 mbar[mbarnum]->menu[menu_id].item[item_id].NextSelect = 0;

	 SetItemWidths(mbarnum,menu_id);			 
	}	

	/* Hey presto! It's menu time! */
	SetMenuStrip(Wdw,&mbar[mbarnum]->menu[MINMENU].info);	
}

void ChangeMenuState(state,item_id,menu_id)
ULONG state,item_id,menu_id;
{
/* 
** Change the state of a menu or menu-item.
*/
ULONG mbarnum;

	/* reasonable request? */
	if (menu_id < MINMENU || menu_id > MAXMENU ||
	    item_id < MINITEM || item_id > MAXITEM ||
	    IntuiMode == 0)
	return;

	/* find the mbar number for this window */
	if (!FindMBarNum(&mbarnum)) return;

	/* clear the menu strip */
	ClearMenuStrip(Wdw);

	/* make the change */
	if (item_id == 0)
	switch(state)
	{
		/* disable menu */
		case 0 : 
		mbar[mbarnum]->menu[menu_id].info.Flags &= ~MENUENABLED;
		break;

		/* enable menu */
		case 1 : 
		mbar[mbarnum]->menu[menu_id].info.Flags |= MENUENABLED;
		break;
	}
	else
	switch(state)
	{
		/* disable item */
		case 0 : 
		mbar[mbarnum]->menu[menu_id].item[item_id].Flags &=~ITEMENABLED;
 	  	mbar[mbarnum]->menu[menu_id].item[item_id].Flags &=
							~(CHECKIT|CHECKED);
		break;

		/* enable item */
		case 1 : 
		mbar[mbarnum]->menu[menu_id].item[item_id].Flags |= ITEMENABLED;
	  	mbar[mbarnum]->menu[menu_id].item[item_id].Flags &=
							~(CHECKIT|CHECKED);
		break;

		/* check item */
		case 2 : 
	  	mbar[mbarnum]->menu[menu_id].item[item_id].Flags |= ITEMENABLED;
		mbar[mbarnum]->menu[menu_id].item[item_id].Flags |=
							CHECKIT|CHECKED;
		break;
	}
	
	/* show the menus */	
	SetMenuStrip(Wdw,&mbar[mbarnum]->menu[MINMENU].info);
}

void ClearMenu()
{
/*
** Clear the current output window's menu strip. 
*/
ULONG mbarnum;

	if (IntuiMode == 0) return;
	
	if (FindMBarNum(&mbarnum)) 
  	{ 
		ClearMenuStrip(Wdw);
		mbar[mbarnum] = NULL; 
	}
}	

void WaitMenu()
{
/*
** Go to sleep until we get a menu message.
*/
struct 	IntuiMessage *message;
ULONG	MsgClass;
USHORT	code;

	if (IntuiMode == 0) return;

	/* soak up pending messages first? ** MAY RESULT IN MESSAGE LOSS **
	if ((message = (struct IntuiMessage *)
			GetMsg(Wdw->UserPort))) ReplyMsg(message); */

	do
	{
		/* await a message */
		if ((message = (struct IntuiMessage *)
				GetMsg(Wdw->UserPort)) == NULL)
		{
			Wait(1L << Wdw->UserPort->mp_SigBit);
			continue;
		}

		/* extract info' about Intuition event */
		MsgClass = message->Class;
		code = message->Code;

		/* reply to message */
		ReplyMsg(message);

		/* 
		** since MENU WAITing may interfere
		** with CLOSEWINDOW events, check for one
		** of the latter.
		*/
		if (MsgClass & CLOSEWINDOW)
		{
			set_wdw_close_num();
			return;
		}
	}
	while (!(MsgClass & MENUPICK));

	/* 
	** Store basic menu info: menu and item number.
	*/
	menunum = MENUNUM(code)+1;
	itemnum = ITEMNUM(code)+1;
	if (menunum > MAXMENU) menunum = 0L;
	if (itemnum > MAXITEM) itemnum = 0L;

	/* 
	** Store menu subitem number.
	** Note: there is no MAXSUB since intrinsic ACE
	** menus don't support subitems. This is essentially 
	** here to support GadTools menus.
	*/
	subitemnum = SUBNUM(code)+1;		
}

ULONG menu_test()
{
/*
** Test for a menu event. 
*/
IntuiInfo *message;
ULONG	  MsgClass;
USHORT	  code;

	if (IntuiMode == 0) return(0L);

	/* attempt to get a message */
	if ((message = GetIntuiEvent(Wdw->UserPort)) == NULL) return(0L);

	/* extract info' about Intuition event */
	MsgClass = message->Class;
	code = message->Code;

	/* has a menu event occurred? */
	if (MsgClass & MENUPICK)
	{
		ClearIntuiEvent();

		/* 
		** Store basic menu info: menu and item number.
		*/
		menunum = MENUNUM(code)+1;
		itemnum = ITEMNUM(code)+1;
		if (menunum > MAXMENU) menunum = 0L;
		if (itemnum > MAXITEM) itemnum = 0L;

		/* 
		** Store menu subitem number.
		** Note: there is no MAXSUB since intrinsic ACE
		** menus don't support subitems. This is essentially 
		** here to support GadTools menus.
		*/
		subitemnum = SUBNUM(code)+1;		

		return(1L);
	}
	else
		return(0L);
}

ULONG MenuFunc(n)
ULONG n;
{
/* 
** Return information about the most recently
** selected menu. 
*/
ULONG num;

	switch(n)
	{
		case 0 : num = menunum;
			 menunum = 0;
			 return(num);
			 break;

		case 1 : return(itemnum);
			 break;

		case 2 : return(subitemnum);	/* for GadTools menus */
			 break;
	}
}
