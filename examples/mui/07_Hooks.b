{*
** 07_Hooks.b - Hook-based callbacks
**
** Demonstrates:
** - CALLBACK SUBs for MUI hooks
** - Using MUISetupHookA4 for SHARED variable access
** - Hook notification on button clicks
** - Real-time slider updates via hooks
**
** Compile: ace:bin/bas 07_Hooks ace:submods/mui/MUI.o
*}

#include <submods/MUI.h>

{ Libraries needed by main program (muimaster opened by submod) }
LIBRARY "intuition.library"
LIBRARY "utility.library"

{ Hook structures }
DECLARE STRUCT MUIHook clickHook
DECLARE STRUCT MUIHook sliderHook

{ Shared variables for callbacks }
LONGINT clickCount
ADDRESS txtCounter, gaugeObj, sliderObj

{ ============== Callback Functions ============== }

{*
** OnButtonClick - Called when button is pressed
**
** MUI passes: hook pointer, object, message
** We use SHARED to access main program variables.
** Return 0& to indicate success.
*}
SUB OnButtonClick(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED clickCount, txtCounter
    STRING countStr SIZE 40

    clickCount = clickCount + 1
    countStr = "Clicks: " + STR$(clickCount)
    MUISetText(txtCounter, countStr)

    OnButtonClick = 0&
END SUB

{*
** OnSliderChange - Called when slider value changes
**
** This demonstrates real-time updates without event loop polling.
*}
SUB OnSliderChange(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    SHARED sliderObj, gaugeObj
    LONGINT v

    IF sliderObj <> 0& AND gaugeObj <> 0& THEN
        v = MUIGetValue(sliderObj)
        MUISetGauge(gaugeObj, v)
    END IF

    OnSliderChange = 0&
END SUB

{ ============== Main Program ============== }

ADDRESS app, win, grp
ADDRESS btnClick
LONGINT running

clickCount = 0

{ Initialize MUI }
MUIInit

{ Create objects }
txtCounter = MUITextCentered("Clicks: 0")
btnClick = MUIButton("Click Me!")
sliderObj = MUISlider(0, 100, 50)
gaugeObj = MUIGauge(100)

{ Set initial gauge value }
MUISetGauge(gaugeObj, 50)

{ Build layout:
    +---------------------------+
    |   Hook-Based Callbacks    |
    +---------------------------+
    |      Clicks: 0            |
    |     [Click Me!]           |
    +---------------------------+
    |   [=====gauge=====]       |
    |   [----slider----]        |
    +---------------------------+
}

MUIBeginVGroup
    MUIBeginVGroup
        MUIGroupFrameT("Button Hook")
        MUIChild(txtCounter)
        MUIChild(btnClick)
    MUIChild(MUIEndGroup)

    MUIBeginVGroup
        MUIGroupFrameT("Slider Hook")
        MUIChild(gaugeObj)
        MUIChild(sliderObj)
    MUIChild(MUIEndGroup)
grp = MUIEndGroup

win = MUIWindow("Hook Callbacks", grp)
app = MUIApp("HooksExample", "$VER: HooksExample 1.0", win)

IF app <> 0& THEN
    { Set up hooks using MUISetupHookA4 for SHARED support }
    MUISetupHookA4(clickHook, @OnButtonClick, 0&)
    MUISetupHookA4(sliderHook, @OnSliderChange, 0&)

    { Bind hooks to objects }
    MUINotifyButtonHook(btnClick, clickHook)
    MUINotifyAttrHook(sliderObj, MUIA_Numeric_Value, sliderHook)

    { Standard close handling }
    MUINotifyClose(win, app, MUIV_Application_ReturnID_Quit)

    MUIWindowOpen(win)

    PRINT "Click the button or move the slider."
    PRINT "Hooks are called automatically - no polling needed!"

    { Simple event loop - hooks are called automatically }
    WHILE MUIWaitEvent(app) <> MUIV_Application_ReturnID_Quit
    WEND

    PRINT "Final click count:"; clickCount

    MUIDispose(app)
END IF

MUICleanup

LIBRARY CLOSE "utility.library"
LIBRARY CLOSE "intuition.library"

END
