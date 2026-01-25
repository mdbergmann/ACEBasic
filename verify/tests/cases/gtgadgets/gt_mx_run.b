' GadTools MX_KIND runtime test
' Creates an MX (mutual exclude) gadget with labels, reads active.
'
' Expected log (RAM:gt_mx_run.log):
'   PASS: mx created
'   PASS: active= 0
'   DONE

DIM opts$(2)
opts$(0) = "Option A"
opts$(1) = "Option B"
opts$(2) = "Option C"

WINDOW 1,"MX Test",(0,0)-(320,120),30

OPEN "O",#1,"RAM:gt_mx_run.log"

GADGET 1,1,"",(10,20)-(200,80),MX_KIND,GTMX_Labels=opts$(),GTMX_Active=0

PRINT #1,"PASS: mx created"

x& = GADGET GETATTR(1,GTMX_Active)
PRINT #1,"PASS: active=";x&

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
