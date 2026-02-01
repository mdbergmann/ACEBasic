{*
** 04_Lists.b - List operations
**
** Copyright (c) 2026 Manfred Bergmann. All rights reserved.
**
** Demonstrates:
** - Creating lists with MUIList and MUIListview
** - Adding and removing entries
** - Getting selection state
** - Directory and volume lists
**
** Compile: ace:bin/bas 04_Lists ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

CONST ID_ADD = 1
CONST ID_REMOVE = 2
CONST ID_CLEAR = 3

ADDRESS app, win, grp
ADDRESS listObj, listview, strEntry
ADDRESS btnAdd, btnRemove, btnClear
ADDRESS txtCount
LONGINT eventID, running, count, sel
STRING countStr SIZE 40

{ Initialize MUI }
MUIInit

{ Create list objects }
listObj = MUIList                       ' Empty list
listview = MUIListview(listObj)         ' Wrap in listview for display

{ Input field for new entries }
strEntry = MUIString("New item", 40)

{ Buttons }
btnAdd = MUIButton("Add")
btnRemove = MUIButton("Remove")
btnClear = MUIButton("Clear")

{ Status text }
txtCount = MUIText("Count: 0")

{ Add some initial entries }
MUIListInsert(listObj, "First item")
MUIListInsert(listObj, "Second item")
MUIListInsert(listObj, "Third item")

{ Build layout:
    +---------------------------+
    |   List Example            |
    +---------------------------+
    |  +-------------------+    |
    |  | First item        |    |
    |  | Second item       |    |
    |  | Third item        |    |
    |  +-------------------+    |
    |  [New item__________]     |
    |  [Add] [Remove] [Clear]   |
    |  Count: 3                 |
    +---------------------------+
}

MUIBeginVGroup
    MUIGroupFrameT("List Example")

    MUIChild(listview)

    MUIChild(strEntry)

    MUIBeginHGroup
        MUIGroupSameSize
        MUIChild(btnAdd)
        MUIChild(btnRemove)
        MUIChild(btnClear)
    MUIChild(MUIEndGroup)

    MUIChild(txtCount)
grp = MUIEndGroup

win = MUIWindow("List Operations", grp)
app = MUIApp("ListExample", "$VER: ListExample 1.0", win)

IF app <> 0& THEN
    MUINotifyButton(btnAdd, app, ID_ADD)
    MUINotifyButton(btnRemove, app, ID_REMOVE)
    MUINotifyButton(btnClear, app, ID_CLEAR)
    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    MUIWindowOpen(win)

    { Update initial count }
    countStr = "Count: " + STR$(MUIListCount(listObj))
    MUISetText(txtCount, countStr)

    running = -1
    WHILE running
        eventID = MUIWaitEvent(app)

        CASE
            eventID = MUIV_Application_ReturnID_Quit : running = 0

            eventID = ID_ADD : BLOCK
                { Add entry from string gadget }
                IF MUIGetStringContents(strEntry) <> 0& THEN
                    MUIListInsert(listObj, CSTR(MUIGetStringContents(strEntry)))
                END IF
                count = MUIListCount(listObj)
                countStr = "Count: " + STR$(count)
                MUISetText(txtCount, countStr)
                PRINT "Added entry, count now: "; count
            END BLOCK

            eventID = ID_REMOVE : BLOCK
                { Remove selected entry }
                sel = MUIListActive(listObj)
                IF sel >= 0 THEN
                    MUIListRemove(listObj, sel)
                    count = MUIListCount(listObj)
                    countStr = "Count: " + STR$(count)
                    MUISetText(txtCount, countStr)
                    PRINT "Removed entry at "; sel
                ELSE
                    PRINT "No selection to remove"
                END IF
            END BLOCK

            eventID = ID_CLEAR : BLOCK
                MUIListClear(listObj)
                MUISetText(txtCount, "Count: 0")
                PRINT "List cleared"
            END BLOCK
        END CASE
    WEND

    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
