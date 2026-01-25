' Legacy POTX (horizontal slider) gadget runtime test
' Creates a horizontal proportional gadget, verifies creation.
'
' Expected log (RAM:potx_run.log):
'   PASS: potx created
'   PASS: closed ok
'   DONE

WINDOW 1,"POTX Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:potx_run.log"

' POTX takes max value as the gadval parameter (0..100 range)
GADGET 1,ON,100,(10,20)-(200,40),POTX

PRINT #1,"PASS: potx created"

SLEEP FOR 2

GADGET CLOSE 1

PRINT #1,"PASS: closed ok"

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
