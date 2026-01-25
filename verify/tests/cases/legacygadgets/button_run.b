' Legacy BUTTON gadget runtime test
' Opens a window, creates a BUTTON gadget, logs result, exits.
'
' Expected log (RAM:button_run.log):
'   PASS: button created
'   DONE

WINDOW 1, "Button Test", (0,0)-(320,100), 30

OPEN "O", #1, "RAM:button_run.log"

GADGET 1, 1, "OK", (100,40)-(200,60), BUTTON

PRINT #1, "PASS: button created"

SLEEP FOR 2

PRINT #1, "DONE"
CLOSE #1

WINDOW CLOSE 1
END
