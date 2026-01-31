{*
** test_colors.b - Test MUI Color Objects
**
** Tests: Colorfield, Coloradjust, Pendisplay, Poppen
**
** Layout:
**   +--------------------------------------------------+
**   |         MUI Color Objects Test                   |
**   +--------------------------------------------------+
**   | +-- Color Display --+ +-- Color Adjust --------+ |
**   | | [Colorfield]      | | [Coloradjust sliders]  | |
**   | | [Pendisplay]      | |                        | |
**   | | [Poppen]          | |                        | |
**   | +-------------------+ +------------------------+ |
**   +--------------------------------------------------+
**   |                      [Close]                     |
**   +--------------------------------------------------+
*}

#include <submods/MUI.h>

{ ============== Libraries ============== }
LIBRARY "intuition.library"
LIBRARY "muimaster.library"
LIBRARY "utility.library"

{ ============== Variables ============== }
ADDRESS app, win, rootGrp
ADDRESS txtHeader
ADDRESS colorField, colorAdjust, penDisplay, popPen
ADDRESS lblColorfield, lblPendisplay, lblPoppen
ADDRESS btnClose
ADDRESS leftCol, rightCol, mainColumns
ADDRESS innerGrp, formGrp
LONGINT running, returnID

CONST ID_CLOSE = 1

{ ============== Main Program ============== }

PRINT "MUI Color Objects Test"
PRINT "======================"

{ Initialize MUI submod }
MUIInit
PRINT "MUIInit done, version: "; MUIVersion

{ ============== Create Objects ============== }

{ Header text }
txtHeader = MUITextCentered("MUI Color Objects Test")
IF txtHeader = 0& THEN PRINT "FAIL: txtHeader" : GOTO cleanup

{ Colorfield - displays a color }
colorField = MUIColorfield(&HFFFFFFFF, &H80000000, &H00000000)
IF colorField = 0& THEN PRINT "FAIL: colorField" : GOTO cleanup
PRINT "Colorfield created"

{ Coloradjust - RGB sliders }
colorAdjust = MUIColoradjustRGB(&HFFFFFFFF, &H80000000, &H00000000)
IF colorAdjust = 0& THEN PRINT "FAIL: colorAdjust" : GOTO cleanup
PRINT "Coloradjust created"

{ Pendisplay - shows a pen color }
penDisplay = MUIPendisplay
IF penDisplay = 0& THEN PRINT "FAIL: penDisplay" : GOTO cleanup
PRINT "Pendisplay created"

{ Poppen - popup color selector }
popPen = MUIPoppen
IF popPen = 0& THEN PRINT "FAIL: popPen" : GOTO cleanup
PRINT "Poppen created"

{ Labels }
lblColorfield = MUILabelRight("Colorfield:")
lblPendisplay = MUILabelRight("Pendisplay:")
lblPoppen = MUILabelRight("Poppen:")

{ Close button }
btnClose = MUIButton("Close")
IF btnClose = 0& THEN PRINT "FAIL: btnClose" : GOTO cleanup

{ ============== Build Layout ============== }

{ Left column - color display objects with labels }
MUIBeginVGroup
    MUIGroupFrameT("Color Display")
    MUIBeginColGroup(2)
        MUIChild(lblColorfield)
        MUIChild(colorField)
        MUIChild(lblPendisplay)
        MUIChild(penDisplay)
        MUIChild(lblPoppen)
        MUIChild(popPen)
    formGrp = MUIEndGroup
    MUIChild(formGrp)
leftCol = MUIEndGroup
IF leftCol = 0& THEN PRINT "FAIL: leftCol" : GOTO cleanup

{ Right column - color adjust }
MUIBeginVGroup
    MUIGroupFrameT("Color Adjust")
    MUIChild(colorAdjust)
rightCol = MUIEndGroup
IF rightCol = 0& THEN PRINT "FAIL: rightCol" : GOTO cleanup

{ Main columns }
mainColumns = MUIHGroup2(leftCol, rightCol)
IF mainColumns = 0& THEN PRINT "FAIL: mainColumns" : GOTO cleanup

{ Root group }
rootGrp = MUIVGroup3(txtHeader, mainColumns, btnClose)
IF rootGrp = 0& THEN PRINT "FAIL: rootGrp" : GOTO cleanup

{ Create window and app }
win = MUIWindow("Color Test", rootGrp)
IF win = 0& THEN PRINT "FAIL: win" : GOTO cleanup

app = MUIApp("ColorTest", "$VER: ColorTest 1.0", win)
IF app = 0& THEN PRINT "FAIL: app" : GOTO cleanup

PRINT "All objects created successfully"

{ ============== Set Up Notifications ============== }

MUINotifyButton(btnClose, app, ID_CLOSE)
MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)
PRINT "Notifications set"

{ ============== Open Window ============== }

MUIWindowOpen(win)
PRINT "Window opened"

{ ============== Event Loop ============== }

running = -1
WHILE running
    returnID = MUIWaitEvent(app)

    IF returnID = MUIV_Application_ReturnID_Quit THEN
        PRINT "Quit requested"
        running = 0
    END IF

    IF returnID = ID_CLOSE THEN
        PRINT "Close button pressed"
        running = 0
    END IF
WEND

PRINT "Event loop exited"

{ ============== Cleanup ============== }

cleanup:

IF app <> 0& THEN
    MUIDispose(app)
    PRINT "App disposed"
END IF

MUICleanup
PRINT "MUICleanup done"

PRINT "Test complete"
END
