' Legacy gadget event handling test
' Creates a button, verifies event system is initialized.
' Uses non-blocking GADGET(0) to check event state.
'
' Expected log (RAM:events.log):
'   PASS: button created
'   PASS: no event pending
'   DONE

WINDOW 1,"Legacy Event Test",(0,0)-(320,200),30

OPEN "O",#1,"RAM:events.log"

GADGET 1, 1, "Click Me", (100,80)-(220,100), BUTTON

PRINT #1, "PASS: button created"

' Non-blocking event check: should be 0 (no event yet)
ev& = GADGET(0)
IF ev& = 0 THEN
  PRINT #1, "PASS: no event pending"
ELSE
  PRINT #1, "FAIL: unexpected event"
END IF

SLEEP FOR 1

PRINT #1, "DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
