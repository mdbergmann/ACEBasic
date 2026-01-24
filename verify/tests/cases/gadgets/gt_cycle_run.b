' GadTools Phase 8 test: CYCLE_KIND runtime with labels
' Creates a cycle gadget with string array labels.
' Verifies gadget creation and GETATTR for active index.
'
' Expected log (RAM:gt_cycle_run.log):
'   PASS: cycle created
'   PASS: active= 0
'   DONE

DIM opts$(2)
opts$(0) = "Red"
opts$(1) = "Green"
opts$(2) = "Blue"

WINDOW 1, "Cycle Test", (0,0)-(320,100), 30

OPEN "O", #1, "RAM:gt_cycle_run.log"

GADGET 1, 1, "Color:", (10,20)-(200,34), CYCLE_KIND, GTCY_Labels=opts$()

PRINT #1, "PASS: cycle created"

x& = GADGET GETATTR(1, GTCY_Active)
PRINT #1, "PASS: active=";x&

SLEEP FOR 1

PRINT #1, "DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
