/*
** An example of AppMenus in ACE.
** Written by Nils Sjoholm, 6th October 1996.
** Modified by David Benn, 9th October 1996. 
*/

#include <exec/types.h>          /* Need this for the Amiga variable types */
#include <workbench/workbench.h> /* This has DiskObject and AppIcon structs */
#include <dos/dostags.h>
#include <funcs/dos_funcs.h>
#include <funcs/exec_funcs.h>    /* Exec message, port and library functions */
#include <funcs/wb_funcs.h>      /* AppMenuItem function protos */

DECLARE STRUCT MsgPort   *myport : myport = NULL
DECLARE STRUCT AppMenuItem *appitem0, *appitem1 : appitem0 = NULL : appitem1 = NULL
DECLARE STRUCT AppMessage   *appmsg : appmsg = NULL
BOOL success : success = FALSE
LONGINT theType, theID
STRING theCmd

LIBRARY exec
LIBRARY workbench

myport = CreateMsgPort
IF myport <> NULL THEN
    appitem0 = AddAppMenuItemA(0&,~
                              "Command 1",~
                              "Browse Files",~
                              myport,NULL)

    appitem1 = AddAppMenuItemA(1&,~
                              "Command 2",~
                              "Wash the dishes",~
                              myport,NULL)

    IF appitem0 <> NULL And appitem1 <> NULL THEN
        Print "Select Workbench Tools demo menuitem 'Browse Files'."
        WaitPort(myport)

	Repeat
	  appmsg = GetMsg(myport)
	  If appmsg Then 
	    theType = appmsg->am_Type

	    If theType = AMTYPE_APPMENUITEM Then 
		theID = appmsg->am_ID 
		theCmd = Cstr(appmsg->am_UserData)
	    End If

	    ReplyMsg(appmsg)	/* should do this ASAP */

	    If theType = AMTYPE_APPMENUITEM Then 
		Print "AppMenuItem #";Str$(theID);
		Print " - command = ";theCmd
	    End If
	  End If
	Until appmsg = NULL

        success = RemoveAppMenuItem(appitem0)
        If success Then Print "menuitem 0 removed."
        success = RemoveAppMenuItem(appitem1)
        If success Then Print "menuitem 1 removed."
    END IF

    DeleteMsgPort(myport)
END IF

LIBRARY CLOSE
