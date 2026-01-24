' GadTools SLIDER_KIND runtime test
' Creates a slider, sets level via SETATTR, reads back via GETATTR.
'
' Expected log (RAM:gt_slider_run.log):
'   PASS: slider created
'   PASS: level= 42
'   DONE

WINDOW 1,"Slider Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:gt_slider_run.log"

GADGET 1,1,"Vol:",(10,20)-(250,34),SLIDER_KIND,GTSL_Min=0,GTSL_Max=100,GTSL_Level=10

PRINT #1,"PASS: slider created"

GADGET SETATTR 1,GTSL_Level=42

x& = GADGET GETATTR(1,GTSL_Level)
PRINT #1,"PASS: level=";x&

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
