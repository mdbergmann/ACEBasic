' Legacy POTY (vertical slider) gadget runtime test
' Creates a vertical proportional gadget, verifies creation.
'
' Expected log (RAM:poty_run.log):
'   PASS: poty created
'   PASS: closed ok
'   DONE

WINDOW 1,"POTY Test",(0,0)-(320,150),30

OPEN "O",#1,"RAM:poty_run.log"

' POTY takes max value as the gadval parameter (0..100 range)
GADGET 1,ON,100,(10,20)-(40,120),POTY

PRINT #1,"PASS: poty created"

SLEEP FOR 2

GADGET CLOSE 1

PRINT #1,"PASS: closed ok"

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
