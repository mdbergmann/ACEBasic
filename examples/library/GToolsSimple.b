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

WINDOW 1,"GadTools Gadget Demo",(0,0)-(400,100),30

GADGET FONT "topaz.font", 8

GADGET GAD_SLIDER, 1, "Speed:   ", (100,20)-(300,32), SLIDER_KIND, GTSL_Min=1, GTSL_Max=20, GTSL_Level=5, GTSL_LevelFormat="%2ld", GTSL_MaxLevelLen=2
GADGET GAD_STRING, 1, "Type Here:", (100,40)-(300,54), STRING_KIND, GTST_String="Hello World!", GTST_MaxChars=50
GADGET GAD_BUTTON, 1, "Click Here", (150,60)-(250,72), BUTTON_KIND

SHORTINT terminated
terminated = 0

WHILE NOT terminated
  GADGET WAIT 0
  gad = GADGET(1)

  CASE
    gad = GAD_SLIDER : PRINT "Speed:"; GADGET(3)
    gad = GAD_STRING : PRINT "String entered"
    gad = GAD_BUTTON : BEEP
    gad = 256        : terminated = 1
  END CASE
WEND

GADGET CLOSE GAD_BUTTON
GADGET CLOSE GAD_STRING
GADGET CLOSE GAD_SLIDER
WINDOW CLOSE 1
END
