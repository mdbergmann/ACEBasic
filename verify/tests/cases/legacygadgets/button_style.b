' Legacy BUTTON gadget with styles test
' Tests different button styles (1=complement, 2=box, 3=borderless)
'
' Expected log (RAM:button_style.log):
'   PASS: style 1 created
'   PASS: style 2 created
'   PASS: style 3 created
'   DONE

WINDOW 1,"Button Styles",(0,0)-(320,150),30

OPEN "O",#1,"RAM:button_style.log"

' Style 1: complement (default)
GADGET 1, 1, "Complement", (10,20)-(150,40), BUTTON, 1
PRINT #1,"PASS: style 1 created"

' Style 2: box border
GADGET 2, 1, "Box", (10,50)-(150,70), BUTTON, 2
PRINT #1,"PASS: style 2 created"

' Style 3: borderless
GADGET 3, 1, "Borderless", (10,80)-(150,100), BUTTON, 3
PRINT #1,"PASS: style 3 created"

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
GADGET CLOSE 2
GADGET CLOSE 3
WINDOW CLOSE 1
END
