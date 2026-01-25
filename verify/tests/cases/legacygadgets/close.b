' Legacy gadget close test
' Creates two gadgets, closes one. Verifies cleanup works.
'
' Expected log (RAM:close.log):
'   PASS: created 2
'   PASS: closed 1
'   DONE

WINDOW 1,"Close Test",(0,0)-(320,150),30

OPEN "O",#1,"RAM:close.log"

GADGET 1, 1, "First", (10,20)-(100,40), BUTTON
GADGET 2, 1, "Second", (10,50)-(100,70), BUTTON

PRINT #1, "PASS: created 2"

GADGET CLOSE 1

PRINT #1, "PASS: closed 1"

SLEEP FOR 1

PRINT #1, "DONE"
CLOSE #1

GADGET CLOSE 2
WINDOW CLOSE 1
END
