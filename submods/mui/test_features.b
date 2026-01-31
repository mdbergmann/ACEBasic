=/==8{*
** test_features.b - Test all new MUI submod features
**
** Two-column layout to show alignment and stretching behavior.
**
** Layout:
**   +--------------------------------------------------+
**   |         MUI Features Test (centered)             |
**   +--------------------------------------------------+
**   | +-- Left Column -----+ +-- Right Column ------+  |
**   | | Form (ColGroup 2)  | | Progress             |  |
**   | |   Name: [_____]    | |   [gauge bar]        |  |
**   | |   Age:  [_____]    | |   Slider: [---o---]  |  |
**   | +--------------------+ +----------------------+  |
**   | | Options (Radio)    | | Framed Text          |  |
**   | |   ( ) Option A     | | [text with frame]    |  |
**   | |   ( ) Option B     | |                      |  |
**   | |   ( ) Option C     | |                      |  |
**   | +--------------------+ +----------------------+  |
**   +--------------------------------------------------+
**   |            [  OK  ]  [Cancel]                    |
**   +--------------------------------------------------+
*}

#include <submods/MUI.h>

{ ============== Libraries ============== }
LIBRARY "intuition.library"
LIBRARY "muimaster.library"
LIBRARY "utility.library"

{ ============== Variables ============== }
ADDRESS app, win, rootGrp
ADDRESS txtHeader, txtFramed
ADDRESS strName, strAge
ADDRESS radioObj, gaugeObj, sliderObj
ADDRESS btnOK, btnCancel
ADDRESS formGrp, radioGrp, progressGrp, buttonGrp
ADDRESS leftCol, rightCol, mainColumns, headerGrp
LONGINT running, returnID

{ Radio button entries - null-terminated array of string pointers }
DIM radioEntries&(4)

{ Hook for slider }
DECLARE STRUCT MUIHook sliderHook

{ ============== Callbacks ============== }

SUB OnSliderChange(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED gaugeObj, sliderObj
    LONGINT sval

    IF sliderObj <> 0& AND gaugeObj <> 0& THEN
        sval = MUIGetValue(sliderObj)
        MUISetGauge(gaugeObj, sval)
    END IF

    OnSliderChange = 0&
END SUB

{ ============== Main Program ============== }

PRINT "MUI Features Test"
PRINT "================="

{ Set up radio entries }
radioEntries&(0) = SADD("Option A")
radioEntries&(1) = SADD("Option B")
radioEntries&(2) = SADD("Option C")
radioEntries&(3) = 0&   { Null terminator }

{ Initialize MUI submod }
MUIInit

{ ============== Create Objects ============== }

{ Header text - centered, wrapped in a framed group to make it expand }
txtHeader = MUITextCentered("MUI Features Test")
IF txtHeader = 0& THEN PRINT "FAIL: txtHeader" : GOTO cleanup

{ Framed text }
txtFramed = MUITextFramed("This text has a frame around it")
IF txtFramed = 0& THEN PRINT "FAIL: txtFramed" : GOTO cleanup

{ String gadgets for form }
strName = MUIString("", 40)
IF strName = 0& THEN PRINT "FAIL: strName" : GOTO cleanup

strAge = MUIInteger(0)
IF strAge = 0& THEN PRINT "FAIL: strAge" : GOTO cleanup

{ Radio buttons }
radioObj = MUIRadio(VARPTR(radioEntries&(0)))
IF radioObj = 0& THEN PRINT "FAIL: radioObj" : GOTO cleanup

{ Gauge (progress bar) }
gaugeObj = MUIGauge(100)
IF gaugeObj = 0& THEN PRINT "FAIL: gaugeObj" : GOTO cleanup

{ Slider - controls the gauge }
sliderObj = MUISlider(0, 100, 50)
IF sliderObj = 0& THEN PRINT "FAIL: sliderObj" : GOTO cleanup

{ Buttons }
btnOK = MUIButton("OK")
IF btnOK = 0& THEN PRINT "FAIL: btnOK" : GOTO cleanup

btnCancel = MUIButton("Cancel")
IF btnCancel = 0& THEN PRINT "FAIL: btnCancel" : GOTO cleanup

PRINT "All objects created"

{ ============== Build Layout ============== }

{ Form group - 2 column layout with frame }
MUIBeginColGroup(2)
    MUIGroupFrameT("Form (ColGroup 2)")
    MUIChild(MUILabelRight("Name:"))
    MUIChild(strName)
    MUIChild(MUILabelRight("Age:"))
    MUIChild(strAge)
formGrp = MUIEndGroup
IF formGrp = 0& THEN PRINT "FAIL: formGrp" : GOTO cleanup

{ Radio group with frame }
MUIBeginVGroup
    MUIGroupFrameT("Options (Radio)")
    MUIChild(radioObj)
radioGrp = MUIEndGroup
IF radioGrp = 0& THEN PRINT "FAIL: radioGrp" : GOTO cleanup

{ Progress group with frame }
MUIBeginVGroup
    MUIGroupFrameT("Progress (Gauge + Slider)")
    MUIGroupSpacing(4)
    MUIChild(gaugeObj)
    MUIChild(MUIHGroup2(MUILabel("Slider:"), sliderObj))
progressGrp = MUIEndGroup
IF progressGrp = 0& THEN PRINT "FAIL: progressGrp" : GOTO cleanup

{ Left column: Form + Radio }
MUIBeginVGroup
    MUIChild(formGrp)
    MUIChild(radioGrp)
leftCol = MUIEndGroup
IF leftCol = 0& THEN PRINT "FAIL: leftCol" : GOTO cleanup
PRINT "leftCol:"; leftCol

{ Right column: Progress + Framed text }
MUIBeginVGroup
    MUIChild(progressGrp)
    MUIChild(txtFramed)
rightCol = MUIEndGroup
IF rightCol = 0& THEN PRINT "FAIL: rightCol" : GOTO cleanup
PRINT "rightCol:"; rightCol

{ Main two-column area - simple HGroup without SameSize }
mainColumns = MUIHGroup2(leftCol, rightCol)
IF mainColumns = 0& THEN PRINT "FAIL: mainColumns" : GOTO cleanup
PRINT "mainColumns created:"; mainColumns

{ Button group - same size buttons, centered }
MUIBeginHGroup
    MUIGroupSameSize
    MUIGroupSpacing(8)
    MUIChild(MUIRectangle)
    MUIChild(btnOK)
    MUIChild(btnCancel)
    MUIChild(MUIRectangle)
buttonGrp = MUIEndGroup
IF buttonGrp = 0& THEN PRINT "FAIL: buttonGrp" : GOTO cleanup

{ Header in a framed group so it expands full width }
MUIBeginHGroup
    MUIGroupFrameT("Header")
    MUIChild(txtHeader)
headerGrp = MUIEndGroup
IF headerGrp = 0& THEN PRINT "FAIL: headerGrp" : GOTO cleanup

{ Root group - everything together }
MUIBeginVGroup
    MUIGroupSpacing(4)
    MUIChild(headerGrp)
    MUIChild(mainColumns)
    MUIChild(MUIHBar)
    MUIChild(buttonGrp)
rootGrp = MUIEndGroup
IF rootGrp = 0& THEN PRINT "FAIL: rootGrp" : GOTO cleanup

PRINT "Layout built"

{ ============== Create Window and App ============== }

win = MUIWindow("MUI Features Test", rootGrp)
IF win = 0& THEN PRINT "FAIL: window" : GOTO cleanup

app = MUIApp("FeaturesTest", "$VER: FeaturesTest 1.0", win)
IF app = 0& THEN PRINT "FAIL: app" : GOTO cleanup

PRINT "Window and app created"

{ ============== Set Up Notifications ============== }

{ Button notifications }
MUINotifyButton(btnOK, app, 1)
MUINotifyButton(btnCancel, app, 2)

{ Close notification }
MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

{ Slider hook - updates gauge when slider moves }
MUISetupHookA4(sliderHook, @OnSliderChange, 0&)
MUINotifyAttrHook(sliderObj, MUIA_Numeric_Value, sliderHook)

{ Set initial gauge value to match slider }
MUISetGauge(gaugeObj, 50)

{ ============== Open Window ============== }

MUIWindowOpen(win)
PRINT "Window open - try resizing!"

{ ============== Event Loop ============== }

running = -1&

WHILE running
    returnID = MUIWaitEvent(app)

    IF returnID = -1& THEN
        PRINT "Window closed"
        running = 0&
    END IF
    IF returnID = 1 THEN
        { OK pressed - show values }
        PRINT "OK pressed!"
        PRINT "  Radio selection:"; MUIGetRadioActive(radioObj)
        PRINT "  Slider value:"; MUIGetValue(sliderObj)
        PRINT "  Age:"; MUIGetInteger(strAge)
    END IF
    IF returnID = 2 THEN
        { Cancel pressed }
        PRINT "Cancel pressed"
        running = 0&
    END IF
WEND

{ ============== Cleanup ============== }

MUIWindowClose(win)

cleanup:
IF app <> 0& THEN
    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "muimaster.library"
LIBRARY CLOSE "intuition.library"

PRINT "Done!"
END
