' GadTools Phase 4 test: runtime gadget creation
' Opens a window, creates a BUTTON_KIND gadget, logs result, exits.
'
' Expected log (RAM:gt_create_run.log):
'   PASS: gadget created
'   DONE

WINDOW 1, "GT Test", (0,0)-(320,100), 30

OPEN "O", #1, "RAM:gt_create_run.log"

GADGET 1, 1, "OK", (100,40)-(200,60), BUTTON_KIND

PRINT #1, "PASS: gadget created"

SLEEP FOR 2

PRINT #1, "DONE"
CLOSE #1

WINDOW CLOSE 1
END
