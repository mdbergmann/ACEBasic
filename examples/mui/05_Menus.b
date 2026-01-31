{*
** 05_Menus.b - Menu handling
**
** Demonstrates:
** - Building menus with MUIBeginMenustrip/MUIEndMenustrip
** - Menu items with keyboard shortcuts
** - Checkable menu items
** - Menu separators
** - Attaching menus to windows
**
** Compile: ace:bin/bas 05_Menus ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

{ Menu IDs }
CONST ID_NEW = 1
CONST ID_OPEN = 2
CONST ID_SAVE = 3
CONST ID_CUT = 10
CONST ID_COPY = 11
CONST ID_PASTE = 12
CONST ID_BOLD = 20
CONST ID_ITALIC = 21

ADDRESS app, win, grp, menustrip
ADDRESS miNew, miOpen, miSave, miQuit
ADDRESS miCut, miCopy, miPaste
ADDRESS miBold, miItalic
ADDRESS txtStatus
LONGINT eventID, running
STRING statusStr SIZE 80

{ Initialize MUI }
MUIInit

{ Build menu structure }
MUIBeginMenustrip
    MUIBeginMenu("Project")
        miNew = MUIMenuitem("New", "N")
        miOpen = MUIMenuitem("Open...", "O")
        miSave = MUIMenuitem("Save", "S")
        MUIMenuSeparator                    ' Separator bar
        miQuit = MUIMenuitem("Quit", "Q")
    MUIEndMenu

    MUIBeginMenu("Edit")
        miCut = MUIMenuitem("Cut", "X")
        miCopy = MUIMenuitem("Copy", "C")
        miPaste = MUIMenuitem("Paste", "V")
    MUIEndMenu

    MUIBeginMenu("Format")
        miBold = MUIMenuitemCheck("Bold", "B", 0)     ' 0 = unchecked
        miItalic = MUIMenuitemCheck("Italic", "I", 0)
    MUIEndMenu
menustrip = MUIEndMenustrip

{ Create window content }
txtStatus = MUITextCentered("Select a menu item")

grp = MUIVGroup2(txtStatus, MUIRectangle)

{ Create window with menu attached }
win = MUIWindowWithMenu("Menu Example", grp, menustrip)
app = MUIApp("MenuExample", "$VER: MenuExample 1.0", win)

IF app <> 0& THEN
    { Set up menu notifications }
    MUINotifyMenu(miNew, app, ID_NEW)
    MUINotifyMenu(miOpen, app, ID_OPEN)
    MUINotifyMenu(miSave, app, ID_SAVE)
    MUINotifyMenu(miQuit, app, MUIV_Application_ReturnID_Quit)
    MUINotifyMenu(miCut, app, ID_CUT)
    MUINotifyMenu(miCopy, app, ID_COPY)
    MUINotifyMenu(miPaste, app, ID_PASTE)
    MUINotifyMenu(miBold, app, ID_BOLD)
    MUINotifyMenu(miItalic, app, ID_ITALIC)

    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    MUIWindowOpen(win)

    running = -1
    WHILE running
        eventID = MUIWaitEvent(app)

        CASE
            eventID = MUIV_Application_ReturnID_Quit : running = 0

            eventID = ID_NEW : BLOCK
                MUISetText(txtStatus, "New selected")
                PRINT "New"
            END BLOCK

            eventID = ID_OPEN : BLOCK
                MUISetText(txtStatus, "Open selected")
                PRINT "Open"
            END BLOCK

            eventID = ID_SAVE : BLOCK
                MUISetText(txtStatus, "Save selected")
                PRINT "Save"
            END BLOCK

            eventID = ID_CUT : BLOCK
                MUISetText(txtStatus, "Cut selected")
                PRINT "Cut"
            END BLOCK

            eventID = ID_COPY : BLOCK
                MUISetText(txtStatus, "Copy selected")
                PRINT "Copy"
            END BLOCK

            eventID = ID_PASTE : BLOCK
                MUISetText(txtStatus, "Paste selected")
                PRINT "Paste"
            END BLOCK

            eventID = ID_BOLD : BLOCK
                { Toggle bold - read current state and invert }
                IF MUIMenuGetChecked(miBold) THEN
                    statusStr = "Bold: ON"
                ELSE
                    statusStr = "Bold: OFF"
                END IF
                MUISetText(txtStatus, statusStr)
                PRINT statusStr
            END BLOCK

            eventID = ID_ITALIC : BLOCK
                IF MUIMenuGetChecked(miItalic) THEN
                    statusStr = "Italic: ON"
                ELSE
                    statusStr = "Italic: OFF"
                END IF
                MUISetText(txtStatus, statusStr)
                PRINT statusStr
            END BLOCK
        END CASE
    WEND

    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
