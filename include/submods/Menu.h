/*
** Header for GadTools based menu subprogram library module.
**
** Author: David Benn
**   Date: 20th July 1996, 8th,9th August 1996
*/

Library "intuition"

/*
** Structure definitions.
*/
Struct menuInfo
  Address visualInfo
  Address menuStrip
End Struct

/*
** Subprogram declarations.
*/
Declare Sub Address MakeMenu(Address theNewMenu,Shortint items) External
Declare Sub AddMenuTitle(Address menuAddr, String theTitle) External
Declare Sub AddMenuItem(Address menuAddr, String theItem, String commKey) External
Declare Sub AddMenuSubItem(Address menuAddr, String theSubItem) External
Declare Sub AddMenuBarItem(Address menuAddr) External
Declare Sub EndMenu(Address menuAddr) External
Declare Sub Longint DisplayMenu(Address winAddr, Address menuAddr, Address infoAddr) External
Declare Sub DestroyMenu(Address win, Address infoAddr) External
