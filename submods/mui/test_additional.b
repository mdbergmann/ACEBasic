' test_additional.b - Test Phase 13 Additional Objects
' Tests: Numericbutton, Knob, Levelmeter with MUINotifyAttrHook

#include <submods/MUI.h>

CONST ID_QUIT = 1
CONST ID_SYNC = 10

ADDRESS app, win, root
ADDRESS numBtn, knob, levelmeter
ADDRESS txtStatus
ADDRESS btnSync

LONGINT running, eventID
STRING s$ SIZE 80

' Hook structures for attribute change notifications
DECLARE STRUCT MUIHook numBtnHook
DECLARE STRUCT MUIHook knobHook

' Callback for Numericbutton value change
SUB OnNumBtnChange(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED txtStatus, numBtn, knob, levelmeter
    LONGINT nv, kv, lv
    STRING st$ SIZE 80

    nv = MUINumericbuttonValue(numBtn)
    kv = MUINumericbuttonValue(knob)
    lv = MUINumericbuttonValue(levelmeter)

    st$ = "N=" + STR$(nv) + " K=" + STR$(kv) + " L=" + STR$(lv)
    MUISetText(txtStatus, st$)
    PRINT "NumBtn changed: "; nv

    OnNumBtnChange = 0&
END SUB

' Callback for Knob value change
SUB OnKnobChange(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED txtStatus, numBtn, knob, levelmeter
    LONGINT nv, kv, lv
    STRING st$ SIZE 80

    nv = MUINumericbuttonValue(numBtn)
    kv = MUINumericbuttonValue(knob)
    lv = MUINumericbuttonValue(levelmeter)

    st$ = "N=" + STR$(nv) + " K=" + STR$(kv) + " L=" + STR$(lv)
    MUISetText(txtStatus, st$)
    PRINT "Knob changed: "; kv

    OnKnobChange = 0&
END SUB

PRINT "Phase 13 Test: Additional Objects"
PRINT "=================================="
PRINT ""

MUIInit

IF MUILastError <> 0 THEN
    PRINT "ERROR: MUIInit failed"
    STOP
END IF

PRINT "Creating Numericbutton..."
numBtn = MUINumericbutton(0, 100, 50)
IF numBtn = 0& THEN PRINT "  FAIL: Numericbutton NULL"
IF numBtn <> 0& THEN PRINT "  OK: Numericbutton created"

PRINT "Creating Knob..."
knob = MUIKnob(0, 255, 128)
IF knob = 0& THEN PRINT "  FAIL: Knob NULL"
IF knob <> 0& THEN PRINT "  OK: Knob created"

PRINT "Creating Levelmeter..."
levelmeter = MUILevelmeter(-20, 6, 0)
IF levelmeter = 0& THEN PRINT "  FAIL: Levelmeter NULL"
IF levelmeter <> 0& THEN PRINT "  OK: Levelmeter created"

txtStatus = MUITextCentered("Adjust controls to see values")
btnSync = MUIButton("Set all to 50")

' Build UI
MUIBeginVGroup
MUIGroupFrameT("Numericbutton (0-100)")
MUIChild(numBtn)
MUIChild(MUIEndGroup)

MUIBeginVGroup
MUIGroupFrameT("Knob (0-255)")
MUIChild(knob)
MUIChild(MUIEndGroup)

MUIBeginVGroup
MUIGroupFrameT("Levelmeter (-20 to +6 dB)")
MUIChild(levelmeter)
MUIChild(MUIEndGroup)

MUIChild(MUIHBar)
MUIChild(txtStatus)
MUIChild(btnSync)

root = MUIEndGroup

win = MUIWindow("Phase 13: Numeric Controls", root)
app = MUIApp("Phase13Test", "$VER: Phase13Test 1.0", win)

IF app = 0& THEN
    PRINT "ERROR: Failed to create application"
    MUICleanup
    STOP
END IF

' Set up hook notifications for value changes
PRINT "Setting up hooks..."
MUISetupHookA4(numBtnHook, @OnNumBtnChange, 0&)
MUINotifyAttrHook(numBtn, MUIA_Numeric_Value, numBtnHook)

MUISetupHookA4(knobHook, @OnKnobChange, 0&)
MUINotifyAttrHook(knob, MUIA_Numeric_Value, knobHook)

' Set up button and close notifications
MUINotifyClose(win, app, ID_QUIT)
MUINotifyButton(btnSync, app, ID_SYNC)

MUIWindowOpen(win)

PRINT ""
PRINT "Window opened - adjust controls to see live updates"
PRINT "Close window to exit"

running = -1
WHILE running
    eventID = MUIWaitEvent(app)
    IF eventID = ID_QUIT THEN running = 0
    IF eventID = MUIV_Application_ReturnID_Quit THEN running = 0
    IF eventID = ID_SYNC THEN
        PRINT "Setting all to 50 (level to 0)..."
        MUINumericbuttonSetValue(numBtn, 50)
        MUINumericbuttonSetValue(knob, 50)
        MUINumericbuttonSetValue(levelmeter, 0)
        s$ = "N= 50 K= 50 L= 0"
        MUISetText(txtStatus, s$)
    END IF
WEND

PRINT "Test complete."
MUIDispose(app)
MUICleanup
END
