' GadTools CHECKBOX_KIND runtime test
' Creates a checkbox with initial checked state, reads back via GETATTR.
'
' Expected log (RAM:gt_checkbox_run.log):
'   PASS: checkbox created
'   PASS: checked= 1
'   DONE

WINDOW 1,"Checkbox Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_checkbox_run.log"

GADGET 1,1,"Agree",(10,20)-(200,34),CHECKBOX_KIND,GTCB_Checked=1

PRINT #1,"PASS: checkbox created"

x& = GADGET GETATTR(1,GTCB_Checked)
PRINT #1,"PASS: checked=";x&

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
