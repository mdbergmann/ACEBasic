{*
** Progress bar demo using GadTools gadgets.
**
** Two rows:
** - Row 1: Decrement button, number display, Increment button
** - Row 2: Progress bar (disabled slider showing 0-20 value)
**
** Clicking left/right buttons changes the value 0-20.
**
** Note: GADGET tag values must be constants at creation time.
** To use variables, use GADGET SETATTR which accepts expressions:
**   GADGET 1, ON, "", (x,y)-(x2,y2), NUMBER_KIND, GTNM_Number=0
**   GADGET SETATTR 1, GTNM_Number=myVariable
*}

CONST GAD_DEC = 1
CONST GAD_NUM = 2
CONST GAD_INC = 3
CONST GAD_PROGRESS = 4
CONST WIN_CLOSE = 256

CONST MIN_VAL = 0
CONST MAX_VAL = 20

SHORTINT currentValue
currentValue = 10

WINDOW 1,"Progress Bar Demo",(50,50)-(400,150),30

GADGET FONT "topaz.font", 8

' Row 1: Decrement button, number display, Increment button
GADGET GAD_DEC, ON, " < ", (20,20)-(70,36), BUTTON_KIND
GADGET GAD_NUM, ON, "Value:  ", (100,20)-(220,36), NUMBER_KIND, GTNM_Number=10, GTNM_Border=1
GADGET GAD_INC, ON, " > ", (270,20)-(320,36), BUTTON_KIND

' Row 2: Slider as visual progress indicator (GadTools has no native progress bar)
GADGET GAD_PROGRESS, OFF, "Progress: ", (100,50)-(320,64), SLIDER_KIND, GTSL_Min=0, GTSL_Max=20, GTSL_Level=10

LONGINT terminated, gad
terminated = 0

WHILE terminated = 0
  GADGET WAIT 0
  gad = GADGET(1)

  IF gad = GAD_DEC THEN
    IF currentValue > MIN_VAL THEN
      currentValue = currentValue - 1
      ' SETATTR accepts variables/expressions for dynamic updates
      GADGET SETATTR GAD_NUM, GTNM_Number=currentValue
      GADGET SETATTR GAD_PROGRESS, GTSL_Level=currentValue
    END IF
  END IF

  IF gad = GAD_INC THEN
    IF currentValue < MAX_VAL THEN
      currentValue = currentValue + 1
      GADGET SETATTR GAD_NUM, GTNM_Number=currentValue
      GADGET SETATTR GAD_PROGRESS, GTSL_Level=currentValue
    END IF
  END IF

  IF gad = WIN_CLOSE THEN
    terminated = 1
  END IF
WEND

GADGET CLOSE GAD_PROGRESS
GADGET CLOSE GAD_INC
GADGET CLOSE GAD_NUM
GADGET CLOSE GAD_DEC
WINDOW CLOSE 1
END
