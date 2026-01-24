' GadTools Phase 7 test: GADGET CLOSE
' Creates two gadgets, closes one, logs status at each step.
'
' Expected log (RAM:gt_close.log):
'   PASS: created 2
'   PASS: closed 1
'   DONE

WINDOW 1,"GT Close Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_close.log"

GADGET 1,1,"OK",(10,40)-(100,60),BUTTON_KIND
GADGET 2,1,"Cancel",(120,40)-(220,60),BUTTON_KIND

PRINT #1,"PASS: created 2"

GADGET CLOSE 1

PRINT #1,"PASS: closed 1"

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
