{*
** test_menu.b - Test MUI Menu functionality
** Tests Phase 9: Menus implementation
*}

#include <submods/MUI.h>

CONST ID_NEW = 1
CONST ID_OPEN = 2
CONST ID_SAVE = 3
CONST ID_CUT = 10
CONST ID_COPY = 11
CONST ID_PASTE = 12
CONST MUI_ID_QUIT = -1

ADDRESS app, win, grp, mstrip, txtStatus
ADDRESS miNew, miOpen, miSave, miQuit
ADDRESS miCut, miCopy, miPaste
ADDRESS miCheck
LONGINT eventID, running
SHORTINT ok

MUIInit

ok = 1
IF MUILastError <> MUIERR_NONE THEN
    PRINT "Failed to initialize MUI"
    ok = 0
END IF

IF ok THEN
    PRINT "MUI Version:"; MUIVersion

    { Build menu structure }
    MUIBeginMenustrip
        MUIBeginMenu("Project")
            miNew = MUIMenuitem("New", "N")
            miOpen = MUIMenuitem("Open...", "O")
            miSave = MUIMenuitem("Save", "S")
            MUIMenuSeparator
            miCheck = MUIMenuitemCheck("Auto-save", "", 0)
            MUIMenuSeparator
            miQuit = MUIMenuitem("Quit", "Q")
        MUIEndMenu
        MUIBeginMenu("Edit")
            miCut = MUIMenuitem("Cut", "X")
            miCopy = MUIMenuitem("Copy", "C")
            miPaste = MUIMenuitem("Paste", "V")
        MUIEndMenu
    mstrip = MUIEndMenustrip

    IF mstrip = 0& THEN
        PRINT "Failed to create menustrip"
        ok = 0
    END IF
END IF

IF ok THEN
    PRINT "Menustrip created"

    { Build window content }
    txtStatus = MUITextCentered("Select a menu item (Amiga+Q to quit)")

    MUIBeginVGroup
        MUIGroupFrameT("Menu Test")
        MUIChild(txtStatus)
    grp = MUIEndGroup

    { Create window WITH menustrip - must be at creation time }
    win = MUIWindowWithMenu("Menu Test", grp, mstrip)

    IF win = 0& THEN
        PRINT "Failed to create window"
        ok = 0
    END IF
END IF

IF ok THEN
    app = MUIApp("MenuTest", "$VER: MenuTest 1.0", win)

    IF app = 0& THEN
        PRINT "Failed to create app"
        ok = 0
    END IF
END IF

IF ok THEN
    { Set up menu notifications }
    MUINotifyMenu(miNew, app, ID_NEW)
    MUINotifyMenu(miOpen, app, ID_OPEN)
    MUINotifyMenu(miSave, app, ID_SAVE)
    MUINotifyMenu(miQuit, app, MUI_ID_QUIT)
    MUINotifyMenu(miCut, app, ID_CUT)
    MUINotifyMenu(miCopy, app, ID_COPY)
    MUINotifyMenu(miPaste, app, ID_PASTE)

    MUINotifyClose(win, app, MUI_ID_QUIT)

    MUIWindowOpen(win)

    PRINT "Window opened with menus"

    running = -1
    WHILE running
        eventID = MUIWaitEvent(app)
        IF eventID = MUI_ID_QUIT THEN
            PRINT "Quit selected"
            running = 0
        END IF
        IF eventID = ID_NEW THEN
            PRINT "New selected"
            MUISetText(txtStatus, "New selected")
        END IF
        IF eventID = ID_OPEN THEN
            PRINT "Open selected"
            MUISetText(txtStatus, "Open selected")
        END IF
        IF eventID = ID_SAVE THEN
            PRINT "Save selected"
            MUISetText(txtStatus, "Save selected")
        END IF
        IF eventID = ID_CUT THEN
            PRINT "Cut selected"
            MUISetText(txtStatus, "Cut selected")
        END IF
        IF eventID = ID_COPY THEN
            PRINT "Copy selected"
            MUISetText(txtStatus, "Copy selected")
        END IF
        IF eventID = ID_PASTE THEN
            PRINT "Paste selected"
            MUISetText(txtStatus, "Paste selected")
        END IF
    WEND

    PRINT "Test complete"
    MUIDispose(app)
END IF

MUICleanup
END
