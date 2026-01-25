' GadTools Phase 8 test: string array tags (CYCLE_KIND)
' Creates a CYCLE_KIND gadget with GTCY_Labels from a string array.
'
' This test verifies that the compiler correctly handles
' array-type tag values: GTCY_Labels=opts$()
'
' Verification: compile only, check generated .s for
' _BuildGTLabels call and tag array setup.

DIM opts$(2)
opts$(0) = "Red"
opts$(1) = "Green"
opts$(2) = "Blue"

WINDOW 1, "Cycle Test", (0,0)-(320,100), 30

GADGET 1, 1, "Color:", (10,20)-(200,34), CYCLE_KIND, GTCY_Labels=opts$()

SLEEP FOR 2

GADGET CLOSE 1
WINDOW CLOSE 1
END
