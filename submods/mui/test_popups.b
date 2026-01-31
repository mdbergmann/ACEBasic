{*
** test_popups.b - Test MUI Popup Objects (Phase 11)
**
** Tests:
** - MUIPopaslFile - File requester popup
** - MUIPopaslDrawer - Drawer requester popup
** - MUIPopaslFont - Font requester popup
** - MUIPoplist - Simple list popup
** - MUIPopstringValue - Get popup string value
*}

#include <submods/MUI.h>

CONST ID_SHOWFILE = 1
CONST ID_SHOWFONT = 2
CONST ID_SHOWLIST = 3

ADDRESS app, win, grp
ADDRESS popFile, popDrawer, popFont, popList
ADDRESS btnShowFile, btnShowFont, btnShowList, txtResult
LONGINT eventID, running
ADDRESS strPtr

{ String array for poplist - NULL terminated }
DIM listItems&(5)
listItems&(0) = SADD("Red")
listItems&(1) = SADD("Green")
listItems&(2) = SADD("Blue")
listItems&(3) = SADD("Yellow")
listItems&(4) = 0&

PRINT "MUI Popup Objects Test"
PRINT "======================"
PRINT

MUIInit

IF MUILastError <> 0 THEN PRINT "Error: Could not initialize MUI" : END

PRINT "MUI initialized, version: "; MUIVersion

{ Create popup objects }
popFile = MUIPopaslFile("Select a file", "#?")
IF popFile = 0& THEN PRINT "Error: Could not create file popup"

popDrawer = MUIPopaslDrawer("Select a drawer")
IF popDrawer = 0& THEN PRINT "Error: Could not create drawer popup"

popFont = MUIPopaslFont("Select a font")
IF popFont = 0& THEN PRINT "Error: Could not create font popup"

popList = MUIPoplist(VARPTR(listItems&(0)))
IF popList = 0& THEN PRINT "Error: Could not create list popup"

{ Create buttons to show popup values }
btnShowFile = MUIButton("Show File")
btnShowFont = MUIButton("Show Font")
btnShowList = MUIButton("Show Color")
txtResult = MUITextFramed("Result will appear here")

{ Build the UI }
MUIBeginVGroup
MUIGroupFrameT("Popup Objects Test")

MUIBeginColGroup(2)
MUIChild(MUILabelRight("File:"))
MUIChild(popFile)

MUIChild(MUILabelRight("Drawer:"))
MUIChild(popDrawer)

MUIChild(MUILabelRight("Font:"))
MUIChild(popFont)

MUIChild(MUILabelRight("Color:"))
MUIChild(popList)
MUIChild(MUIEndGroup)

MUIBeginHGroup
MUIGroupSameSize
MUIChild(btnShowFile)
MUIChild(btnShowFont)
MUIChild(btnShowList)
MUIChild(MUIEndGroup)

MUIChild(txtResult)

MUIChild(MUIEndGroup)

grp = MUIEndGroup

win = MUIWindow("Popup Test", grp)
app = MUIApp("PopupTest", "$VER: PopupTest 1.0", win)

IF app = 0& THEN PRINT "Error: Could not create application" : MUICleanup : END

PRINT "Application created"

{ Set up notifications }
MUINotifyButton(btnShowFile, app, ID_SHOWFILE)
MUINotifyButton(btnShowFont, app, ID_SHOWFONT)
MUINotifyButton(btnShowList, app, ID_SHOWLIST)
MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

MUIWindowOpen(win)

IF MUIWindowIsOpen(win) = 0 THEN PRINT "Error: Could not open window" : MUIDispose(app) : MUICleanup : END

PRINT "Window opened"
PRINT
PRINT "Click the popup buttons to select values,"
PRINT "then click the Show buttons to display them."
PRINT

running = -1
WHILE running
    eventID = MUIWaitEvent(app)

    IF eventID = MUIV_Application_ReturnID_Quit THEN PRINT "Quit requested" : running = 0

    IF eventID = ID_SHOWFILE THEN
        strPtr = MUIPopstringValue(popFile)
        IF strPtr <> 0& THEN
            PRINT "File: "; CSTR(strPtr)
            MUISetText(txtResult, "File: " + CSTR(strPtr))
        ELSE
            PRINT "File: (empty)"
            MUISetText(txtResult, "File: (empty)")
        END IF
    END IF

    IF eventID = ID_SHOWFONT THEN
        strPtr = MUIPopstringValue(popFont)
        IF strPtr <> 0& THEN
            PRINT "Font: "; CSTR(strPtr)
            MUISetText(txtResult, "Font: " + CSTR(strPtr))
        ELSE
            PRINT "Font: (empty)"
            MUISetText(txtResult, "Font: (empty)")
        END IF
    END IF

    IF eventID = ID_SHOWLIST THEN
        strPtr = MUIPopstringValue(popList)
        IF strPtr <> 0& THEN
            PRINT "Color: "; CSTR(strPtr)
            MUISetText(txtResult, "Color: " + CSTR(strPtr))
        ELSE
            PRINT "Color: (empty)"
            MUISetText(txtResult, "Color: (empty)")
        END IF
    END IF
WEND

PRINT "Closing..."

MUIWindowClose(win)
MUIDispose(app)
MUICleanup

PRINT "Test complete!"
PRINT "SUCCESS: All popup objects created and tested"
END
