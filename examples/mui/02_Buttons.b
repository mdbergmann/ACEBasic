{*
** 02_Buttons.b - Button handling with event IDs
**
** Demonstrates:
** - Creating buttons with MUIButton
** - Setting up button notifications with MUINotifyButton
** - Handling button clicks in the event loop
** - Using MUIGroupSameSize for uniform button sizing
**
** Compile: ace:bin/bas 02_Buttons ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

{ Event IDs - start at 1, avoid -1 which is QUIT }
CONST ID_OK = 1
CONST ID_CANCEL = 2
CONST ID_HELP = 3

ADDRESS app, win, grp
ADDRESS btnOK, btnCancel, btnHelp
LONGINT eventID, running

{ Initialize MUI }
MUIInit

{ Create buttons }
btnOK = MUIButton("OK")
btnCancel = MUIButton("Cancel")
btnHelp = MUIButton("Help")

{ Build layout:
    +---------------------------+
    |   Click a button below:   |
    +---------------------------+
    |  [ OK ] [Cancel] [ Help ] |
    +---------------------------+
}

MUIBeginVGroup
    MUIChild(MUITextCentered("Click a button below:"))
    MUIBeginHGroup
        MUIGroupSameSize
        MUIChild(btnOK)
        MUIChild(btnCancel)
        MUIChild(btnHelp)
    MUIChild(MUIEndGroup)
grp = MUIEndGroup

win = MUIWindow("Button Test", grp)
app = MUIApp("ButtonTest", "$VER: ButtonTest 1.0", win)

IF app <> 0& THEN
    { Set up button notifications - return ID when pressed }
    MUINotifyButton(btnOK, app, ID_OK)
    MUINotifyButton(btnCancel, app, ID_CANCEL)
    MUINotifyButton(btnHelp, app, ID_HELP)

    { Close window also quits }
    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    MUIWindowOpen(win)

    { Event loop }
    running = -1
    WHILE running
        eventID = MUIWaitEvent(app)

        CASE
            eventID = MUIV_Application_ReturnID_Quit : BLOCK
                PRINT "Goodbye!"
                running = 0
            END BLOCK
            eventID = ID_OK : PRINT "OK button clicked!"
            eventID = ID_CANCEL : BLOCK
                PRINT "Cancel button clicked - exiting"
                running = 0
            END BLOCK
            eventID = ID_HELP : PRINT "Help: Click OK to acknowledge, Cancel to exit."
        END CASE
    WEND

    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
