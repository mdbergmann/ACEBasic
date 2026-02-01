{*
** 01_Hello.b - Minimal MUI window
**
** Copyright (c) 2026 Manfred Bergmann. All rights reserved.
**
** This is the simplest possible MUI program using the MUI submod.
** It creates a window with centered text that closes when you
** click the close gadget.
**
** Compile: ace:bin/bas 01_Hello ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

ADDRESS app, win, grp, txt

{ Initialize MUI }
MUIInit

{ Create a centered text object }
txt = MUITextCentered("Hello from MUI!")

{ Wrap in a group - MUI windows need a group as root }
MUIBeginVGroup
    MUIGroupFrameT("Welcome")
    MUIChild(txt)
grp = MUIEndGroup

{ Create window with group as root }
win = MUIWindow("Hello MUI", grp)

{ Create application with the window }
app = MUIApp("HelloMUI", "$VER: HelloMUI 1.0", win)

IF app <> 0& THEN
    { Set up window close notification }
    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    { Open the window }
    MUIWindowOpen(win)

    { Event loop - wait until quit }
    WHILE MUIWaitEvent(app) <> MUIV_Application_ReturnID_Quit
    WEND

    { Dispose the application (frees all objects) }
    MUIDispose(app)
END IF

{ Cleanup MUI }
MUICleanup

{ Close libraries }
LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
