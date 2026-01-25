' GadTools NUMBER_KIND runtime test
' Creates a number display gadget, sets value via SETATTR.
'
' Expected log (RAM:gt_number_run.log):
'   PASS: number created
'   PASS: set to 123
'   DONE

WINDOW 1,"Number Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_number_run.log"

GADGET 1,1,"Value:",(10,20)-(250,34),NUMBER_KIND,GTNM_Number=0,GTNM_Border=1

PRINT #1,"PASS: number created"

GADGET SETATTR 1,GTNM_Number=123

PRINT #1,"PASS: set to 123"

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
