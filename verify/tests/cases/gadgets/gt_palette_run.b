' GadTools PALETTE_KIND runtime test
' Creates a palette gadget, reads initial color via GETATTR.
'
' Expected log (RAM:gt_palette_run.log):
'   PASS: palette created
'   PASS: color= 1
'   DONE

WINDOW 1,"Palette Test",(0,0)-(320,120),30

OPEN "O",#1,"RAM:gt_palette_run.log"

GADGET 1,1,"Color:",(10,20)-(250,70),PALETTE_KIND,GTPA_Depth=4,GTPA_Color=1

PRINT #1,"PASS: palette created"

x& = GADGET GETATTR(1,GTPA_Color)
PRINT #1,"PASS: color=";x&

SLEEP FOR 1

PRINT #1,"DONE"
CLOSE #1

GADGET CLOSE 1
WINDOW CLOSE 1
END
