/*
** A test of the GadTools based menu subprogram library module.
**
** Author: David Benn
**   Date: 20th July 1996, 8th,9th August 1996
*/

#include <SUBmods/Menu.h>

Declare Struct menuInfo info
Address myNewMenu, theNewMenu, theWdw

theNewMenu = MakeMenu(@myNewMenu,11)    /* 11 menu entries */

If theNewMenu <> NULL Then
  /*
  ** Project menu.
  */
  AddMenuTitle(@myNewMenu,	"Project")
  AddMenuItem(@myNewMenu,	"Open...","O")	/* menu-id 1 */
  AddMenuBarItem(@myNewMenu)
  AddMenuItem(@myNewMenu,	"Print","")	/* menu-id 3 */
  AddMenuSubItem(@myNewMenu,	  "Draft")
  AddMenuSubItem(@myNewMenu,	  "NLQ")
  AddMenuBarItem(@myNewMenu)
  AddMenuItem(@myNewMenu,	"Quit","Q")	/* menu-id 5 */

  /*
  ** Special menu.
  */
  AddMenuTitle(@myNewMenu,	"Special")	
  AddMenuItem(@myNewMenu,	"Help...","H")	/* menu-id 1 */  
  AddMenuItem(@myNewMenu,	"Spell...","S")	/* menu-id 2 */  

  EndMenu(myNewMenu)

  Window 1,"GadTools Menu SUBmod Test",(0,0)-(640,100),0
  theWdw = Window(7)
  If DisplayMenu(theWdw,theNewMenu,info) Then 
    Repeat 	
      Menu Wait
      theMenu = Menu(0)
      theItem = Menu(1)
      theSubItem = Menu(2)
      Cls : Locate 1,1
      Print theMenu;theItem;
      If theMenu = 1 And theItem = 3 Then Print theSubItem
    Until theMenu = 1 And theItem = 5
    DestroyMenu(theWdw,info)
  End If
  Window Close 1
End If
