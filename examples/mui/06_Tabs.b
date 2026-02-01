{*
** 06_Tabs.b - Tabbed interface (Register)
**
** Copyright (c) 2026 Manfred Bergmann. All rights reserved.
**
** Demonstrates:
** - Creating tabbed pages with MUIRegister
** - Builder pattern vs quick helper
** - Getting/setting active page
**
** Compile: ace:bin/bas 06_Tabs ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

CONST ID_PREV = 1
CONST ID_NEXT = 2
CONST ID_CHECK = 3

ADDRESS app, win, grp
ADDRESS reg, pageGeneral, pageAdvanced, pageAbout
ADDRESS strName, chkDebug, txtVersion
ADDRESS btnPrev, btnNext
LONGINT eventID, running, currentPage, numPages

{ Initialize MUI }
MUIInit

numPages = 3

{ Create page 1: General }
MUIBeginVGroup
    MUIGroupFrameT("Settings")
    MUIBeginColGroup(2)
        MUIChild(MUILabelRight("Name:"))
        strName = MUIString("User", 40)
        MUIChild(strName)
    MUIChild(MUIEndGroup)
pageGeneral = MUIEndGroup

{ Create page 2: Advanced }
MUIBeginVGroup
    MUIGroupFrameT("Options")
    MUIBeginHGroup
        chkDebug = MUICheckmark(0)
        MUIChild(chkDebug)
        MUIChild(MUILabel("Enable debug mode"))
    MUIChild(MUIEndGroup)
pageAdvanced = MUIEndGroup

{ Create page 3: About }
MUIBeginVGroup
    txtVersion = MUITextCentered("Tabs Example v1.0")
    MUIChild(txtVersion)
    MUIChild(MUIText("Demonstrates MUI Register (tabs)"))
pageAbout = MUIEndGroup

{ Create Register with 3 tabs }
reg = MUIRegister3("General|Advanced|About", pageGeneral, pageAdvanced, pageAbout)

{ Navigation buttons }
btnPrev = MUIButton("< Previous")
btnNext = MUIButton("Next >")

{ Build layout }
MUIBeginVGroup
    MUIChild(reg)
    MUIBeginHGroup
        MUIGroupSameSize
        MUIChild(btnPrev)
        MUIChild(btnNext)
    MUIChild(MUIEndGroup)
grp = MUIEndGroup

win = MUIWindow("Tabbed Interface", grp)
app = MUIApp("TabsExample", "$VER: TabsExample 1.0", win)

IF app <> 0& THEN
    MUINotifyButton(btnPrev, app, ID_PREV)
    MUINotifyButton(btnNext, app, ID_NEXT)
    MUINotifyCheckmark(chkDebug, app, ID_CHECK)
    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    MUIWindowOpen(win)

    running = -1
    WHILE running
        eventID = MUIWaitEvent(app)

        CASE
            eventID = MUIV_Application_ReturnID_Quit : running = 0

            eventID = ID_PREV : BLOCK
                currentPage = MUIRegisterActive(reg)
                IF currentPage > 0 THEN
                    MUIRegisterSetActive(reg, currentPage - 1)
                    PRINT "Switched to page"; currentPage - 1
                END IF
            END BLOCK

            eventID = ID_NEXT : BLOCK
                currentPage = MUIRegisterActive(reg)
                IF currentPage < numPages - 1 THEN
                    MUIRegisterSetActive(reg, currentPage + 1)
                    PRINT "Switched to page"; currentPage + 1
                END IF
            END BLOCK

            eventID = ID_CHECK : BLOCK
                PRINT "Checkmark clicked! Selected ="; MUIGetChecked(chkDebug)
            END BLOCK
        END CASE
    WEND

    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
