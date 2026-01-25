' Legacy STRING gadget runtime test
' Creates a string gadget with initial text, verifies creation.
'
' Expected log (RAM:string_run.log):
'   PASS: string created
'   PASS: closed ok
'   DONE

WINDOW 1,"String Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:string_run.log"

GADGET 1,ON,"Hello",(10,20)-(250,34),STRING

PRINT #1,"PASS: string created"

SLEEP FOR 2

GADGET CLOSE 1

PRINT #1,"PASS: closed ok"

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
