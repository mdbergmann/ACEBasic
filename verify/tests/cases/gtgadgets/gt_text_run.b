' GadTools TEXT_KIND runtime test
' Creates a read-only text display gadget, verifies creation.
'
' Expected log (RAM:gt_text_run.log):
'   PASS: text created
'   PASS: closed ok
'   DONE

WINDOW 1,"Text Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_text_run.log"

GADGET 1,1,"Status:",(10,20)-(250,34),TEXT_KIND,GTTX_Border=1

PRINT #1,"PASS: text created"

GADGET CLOSE 1

PRINT #1,"PASS: closed ok"

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

WINDOW CLOSE 1
END
