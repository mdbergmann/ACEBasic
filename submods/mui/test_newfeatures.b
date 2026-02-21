{*
** test_newfeatures.b - Test newly implemented MUI submod features
*}

REM #using ace:submods/mui/MUI.o
#include <submods/MUI.h>

{ Event IDs }
CONST ID_SLEEP = 1
CONST ID_WAKE = 2
CONST ID_TITLE = 3
CONST ID_QUIT = 4

{ Main program variables }
ADDRESS app, win, grp
ADDRESS btnSleep, btnWake, btnTitle, btnQuit
ADDRESS txtStatus, txtVersion
ADDRESS colorBox, scaleH
ADDRESS strName, strAge
LONGINT running, eventID, titleNum, errCode, muiVer, isOpen

{ Initialize MUI }
MUIInit

{ Check for errors and display version }
errCode = MUILastError
IF errCode <> MUIERR_NONE THEN
    PRINT "MUI Error: "; errCode
    MUICleanup
    GOTO exitProg
END IF

muiVer = MUIVersion
PRINT "MUI Version: "; muiVer

{ Create status text }
txtVersion = MUIText("MUI Version: " + STR$(muiVer))
txtStatus = MUITextCentered("Status: Ready")

{ Create buttons with keyboard shortcuts }
btnSleep = MUIKeyButton("_Sleep App", "s")
btnWake = MUIKeyButton("_Wake App", "w")
btnTitle = MUIKeyButton("Change _Title", "t")
btnQuit = MUIKeyButton("_Quit", "q")

{ Create color field (red) }
colorBox = MUIColorfield(&HFFFFFFFF, 0&, 0&)

{ Create horizontal scale }
scaleH = MUIScale

{ Create form fields }
strName = MUIString("", 40)
strAge = MUIInteger(25)

{ Build the UI using group builder }
MUIBeginVGroup
    MUIGroupFrameT("New Features Test")
    MUIChild(txtVersion)
    MUIChild(txtStatus)
    MUIBeginHGroup
        MUIGroupSameHeight
        MUIChild(colorBox)
        MUIChild(scaleH)
    MUIChild(MUIEndGroup)
    MUIChild(MUIForm2(MUILabelRight("Name:"), strName, MUILabelRight("Age:"), strAge))
    MUIBeginHGroup
        MUIGroupSameWidth
        MUIChildWeight(btnSleep, 100)
        MUIChildWeight(btnWake, 100)
        MUIChildWeight(btnTitle, 100)
        MUIChildWeight(btnQuit, 50)
    MUIChild(MUIEndGroup)
grp = MUIEndGroup

{ Create window }
win = MUIWindow("New Features Test", grp)
IF win = 0& THEN
    PRINT "Failed to create window"
    MUICleanup
    GOTO exitProg
END IF

{ Create application }
app = MUIApp("NewFeaturesTest", "$VER: NewFeaturesTest 1.0", win)
IF app = 0& THEN
    PRINT "Failed to create application"
    MUICleanup
    GOTO exitProg
END IF

{ Set up notifications }
MUINotifyButton(btnSleep, app, ID_SLEEP)
MUINotifyButton(btnWake, app, ID_WAKE)
MUINotifyButton(btnTitle, app, ID_TITLE)
MUINotifyButton(btnQuit, app, ID_QUIT)
MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

{ Open window }
MUIWindowOpen(win)

{ Check if window is open }
isOpen = MUIWindowIsOpen(win)
IF isOpen THEN
    MUISetText(txtStatus, "Status: Window opened")
END IF

PRINT "Window open - visual check for 2 seconds"
SLEEP FOR 2

{ Cleanup }
MUIWindowClose(win)
MUIDispose(app)
MUICleanup

PRINT "Test completed"

exitProg:
END
