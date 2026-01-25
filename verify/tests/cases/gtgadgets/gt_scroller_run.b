' GadTools SCROLLER_KIND runtime test
' Creates a scroller, sets top via SETATTR, reads back via GETATTR.
'
' Expected log (RAM:gt_scroller_run.log):
'   PASS: scroller created
'   PASS: top= 5
'   DONE

WINDOW 1,"Scroller Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_scroller_run.log"

GADGET 1,1,"",(10,20)-(250,34),SCROLLER_KIND,GTSC_Top=0,GTSC_Total=20,GTSC_Visible=5

PRINT #1,"PASS: scroller created"

GADGET SETATTR 1,GTSC_Top=5

x& = GADGET GETATTR(1,GTSC_Top)
PRINT #1,"PASS: top=";x&

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
