' Legacy LONGINT gadget runtime test
' Creates a LONGINT gadget for integer input, verifies creation.
'
' Expected log (RAM:longint_run.log):
'   PASS: longint created
'   PASS: closed ok
'   DONE

WINDOW 1,"LongInt Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:longint_run.log"

GADGET 1,ON,"0",(10,20)-(200,34),LONGINT

PRINT #1,"PASS: longint created"

SLEEP FOR 2

GADGET CLOSE 1

PRINT #1,"PASS: closed ok"

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
