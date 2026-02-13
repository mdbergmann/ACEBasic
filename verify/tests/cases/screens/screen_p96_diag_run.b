REM Diagnostic test for P96 screen support

REM Try opening P96 screen
SCREEN 1,800,600,8,13
ASSERT ERR <> 600, "P96 not available (error 600)"

REM Check SCREEN() function values
scrn& = SCREEN(1)
wdw& = SCREEN(0)
rport& = SCREEN(2)
vport& = SCREEN(3)

ASSERT scrn& <> 0, "SCREEN(1) returned zero"
ASSERT wdw& <> 0, "SCREEN(0) returned zero"
ASSERT rport& <> 0, "SCREEN(2) returned zero"
ASSERT vport& <> 0, "SCREEN(3) returned zero"

REM Try drawing
LINE (10,50)-(200,150),2,bf
CIRCLE (400,300),100,4

REM Close screen
SCREEN CLOSE 1
PRINT "All tests passed"
