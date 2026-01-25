' Legacy slider modification test
' Creates a POTX slider, modifies position with GADGET MOD.
'
' Expected log (RAM:slider_mod.log):
'   PASS: slider created
'   PASS: slider modified
'   DONE

WINDOW 1,"Slider Mod Test",(0,0)-(320,100),30

OPEN "O",#1,"RAM:slider_mod.log"

' Create horizontal slider with max value 100
GADGET 1,ON,100,(10,20)-(200,40),POTX

PRINT #1,"PASS: slider created"

' Modify slider position to 50
GADGET MOD 1, 50

PRINT #1,"PASS: slider modified"

PRINT #1,"DONE"
CLOSE #1

SLEEP FOR 2

GADGET CLOSE 1
WINDOW CLOSE 1
END
