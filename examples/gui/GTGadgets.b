{*
** GadTools gadgets using the built-in _KIND syntax.
**
** This is the simplified equivalent of GTools.b, which
** requires ~230 lines of boilerplate library calls.
**
** Creates a slider, string gadget, and button, then
** handles events from each.
*}

CONST GAD_SLIDER = 1
CONST GAD_STRING = 2
CONST GAD_BUTTON = 3
CONST WIN_CLOSE = 256

WINDOW 1,"GadTools Gadget Demo",(0,0)-(400,100),30

GADGET FONT "topaz.font", 8

GADGET GAD_SLIDER, ON, "Speed:   ", (100,20)-(300,32), SLIDER_KIND, GTSL_Min=1, GTSL_Max=20, GTSL_Level=5, GTSL_LevelFormat="%2ld", GTSL_MaxLevelLen=2
GADGET GAD_STRING, ON, "Type Here:", (100,40)-(300,54), STRING_KIND, GTST_String="Hello World!", GTST_MaxChars=50
GADGET GAD_BUTTON, OFF, "Click Here", (150,60)-(250,72), BUTTON_KIND

LONGINT terminated, gad
terminated = 0

WHILE terminated = 0
  GADGET WAIT 0
  gad = GADGET(1)

  CASE
    gad = GAD_SLIDER : MsgBox "Speed: "+STR$(GADGET(3)),"OK"
    gad = GAD_STRING : MsgBox CSTR(GADGET(2)),"OK"
    gad = GAD_BUTTON : BEEP
    gad = WIN_CLOSE  : terminated = 1
  END CASE
WEND

GADGET CLOSE GAD_BUTTON
GADGET CLOSE GAD_STRING
GADGET CLOSE GAD_SLIDER
WINDOW CLOSE 1
END
