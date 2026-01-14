/*
** GadTools based menu subprogram library module. Permits
** menu subitems and normal ACE menu waiting and event trapping.
**
** Adapted from RKM: Libraries (1992), p 368-378
** by David Benn, 22nd,23rd June 1996, 19th,20th July 1996, 8th,9th August 1996
*/

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <libraries/gadtools.h>

#include <funcs/exec_funcs.h>
#include <funcs/gadtools_funcs.h>
#include <funcs/intuition_funcs.h>

/*
** Structure definitions.
*/
Struct menuInfo
  Address visualInfo
  Address menuStrip
End Struct

/*
** Subprogram definitions.
*/
Sub Address MakeMenu(Address theNewMenu,Shortint items) External
/*
** Allocate space for required number of menu structures + 1.
** The extra item is for the NM_END marker. See EndMenu SUB.
** Store address in reference parameter and return it also.
** Note: the address may be NULL and the caller should test
** for this. 
*/
  	*&theNewMenu := Alloc((items+1)*Sizeof(NewMenu))
	MakeMenu = *&theNewMenu
End Sub

Sub AddMenuTitle(Address menuAddr, String theTitle) External
/*
** Add a menu title to a GadTools menu.
*/
Declare Struct NewMenu *theMenu
Address strAddr
	theMenu = *&menuAddr
	theMenu->nm_Type = NM_TITLE
	strAddr = Alloc(Len(theTitle)+1)
	If strAddr = NULL Then Exit Sub
	String titleClone Address strAddr
	titleClone = theTitle
	theMenu->nm_Label = @titleClone
	theMenu->nm_CommKey = 0&
	theMenu->nm_Flags = 0&
	theMenu->nm_MutualExclude = 0&
	theMenu->nm_UserData = 0&
	*&menuAddr := theMenu+Sizeof(NewMenu)	
End Sub

Sub AddMenuItem(Address menuAddr, String theItem, String commKey) External
/*
** Add a menu item to a GadTools menu.
*/
Declare Struct NewMenu *theMenu
Address strAddr
	theMenu = *&menuAddr
	theMenu->nm_Type = NM_ITEM
	strAddr = Alloc(Len(theItem)+1)
	If strAddr = NULL Then Exit Sub
	String itemClone Address strAddr
	itemClone = theItem
	theMenu->nm_Label = @itemClone
	If commKey = "" Then 
		theMenu->nm_CommKey = 0&
	Else
		strAddr = Alloc(Len(commKey)+1)
		If strAddr = NULL Then Exit Sub
		String commKeyClone Address strAddr
		commKeyClone = commKey
		theMenu->nm_CommKey = @commKeyClone
	End If
	theMenu->nm_Flags = 0&
	theMenu->nm_MutualExclude = 0&
	theMenu->nm_UserData = 0&
	*&menuAddr := theMenu+Sizeof(NewMenu)	
End Sub

Sub AddMenuSubItem(Address menuAddr, String theSubItem) External
/*
** Add a menu subitem to a GadTools menu.
*/
Declare Struct NewMenu *theMenu
Address strAddr
	theMenu = *&menuAddr
	theMenu->nm_Type = NM_SUB
	strAddr = Alloc(Len(theSubItem)+1)
	If strAddr = NULL Then Exit Sub
	String subItemClone Address strAddr
	subItemClone = theSubItem
	theMenu->nm_Label = @subItemClone
	theMenu->nm_CommKey = 0&
	theMenu->nm_Flags = 0&
	theMenu->nm_MutualExclude = 0&
	theMenu->nm_UserData = 0&
	*&menuAddr := theMenu+Sizeof(NewMenu)
End Sub

Sub AddMenuBarItem(Address menuAddr) External
/*
** Add a menu bar to a GadTools menu.
*/
Declare Struct NewMenu *theMenu
	theMenu = *&menuAddr
	theMenu->nm_Type = NM_ITEM
	theMenu->nm_Label = NM_BARLABEL
	theMenu->nm_CommKey = 0&
	theMenu->nm_Flags = 0&
	theMenu->nm_MutualExclude = 0&
	theMenu->nm_UserData = 0&
	*&menuAddr := theMenu+Sizeof(NewMenu)
End Sub

Sub EndMenu(Address menuAddr) External
/*
** Mark the end of a GadTools menu.
*/
Declare Struct NewMenu *theMenu
	theMenu = menuAddr
	theMenu->nm_Type = NM_END
	theMenu->nm_Label = 0&
	theMenu->nm_CommKey = 0&
	theMenu->nm_Flags = 0&
	theMenu->nm_MutualExclude = 0&
	theMenu->nm_UserData = 0&
End Sub

Sub Longint DisplayMenu(Address winAddr, Address menuAddr, Address infoAddr) External
/*
** Gets current screen's visual info for GadTools, Creates 
** Intuition menus from GadTools menu description info, 
** lays out the menus and displays them.
*/
Declare Struct _Window *win
Declare Struct menuInfo *menuInfo

  Library "gadtools"

  win = winAddr
  menuInfo = infoAddr

  menuInfo->visualInfo = GetVisualInfoA(win->WScreen,NULL)
  If menuInfo->visualInfo Then
      menuInfo->menuStrip = CreateMenusA(menuAddr,NULL)
      If menuInfo->menuStrip Then
        If LayoutMenusA(menuInfo->menuStrip,menuInfo->visualInfo,NULL) Then
          SetMenuStrip(win,menuInfo->menuStrip)
    	  DisplayMenu = TRUE
	Else
	  DisplayMenu = FALSE
	End If
      Else
	DisplayMenu = FALSE
      End If
  Else
   DisplayMenu = FALSE
  End If
End Sub

Sub DestroyMenu(Address win, Address infoAddr) External
/*
** Clears the specified window's menu strip, frees the resources
** associated with the menus and with the GadTools visual info.
*/
Declare Struct menuInfo *menuInfo
  menuInfo = infoAddr
  ClearMenuStrip(win)
  FreeMenus(menuInfo->menuStrip)
  FreeVisualInfo(menuInfo->visualInfo)
  Library Close "gadtools"
End Sub
