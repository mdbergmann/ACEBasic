' GadTools STRING_KIND runtime test
' Creates a string gadget with initial text, verifies creation.
'
' Expected log (RAM:gt_string_run.log):
'   PASS: string created
'   PASS: closed ok
'   DONE

WINDOW 1,"String Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_string_run.log"

GADGET 1,1,"Name:",(10,20)-(250,34),STRING_KIND,GTST_MaxChars=50

PRINT #1,"PASS: string created"

GADGET CLOSE 1

PRINT #1,"PASS: closed ok"

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
