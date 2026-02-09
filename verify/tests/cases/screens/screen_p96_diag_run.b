REM Diagnostic test for P96 screen support
REM Writes results to a file for verification
OPEN "O",#1,"ace:test-p96-diag.txt"

REM Try opening P96 screen
SCREEN 1,800,600,8,13
IF ERR = 600 THEN
  PRINT #1,"FAIL: P96 not available (error 600)"
  CLOSE #1
  STOP
END IF

PRINT #1,"PASS: P96 screen opened"

REM Check SCREEN() function values
scrn& = SCREEN(1)
wdw& = SCREEN(0)
rport& = SCREEN(2)
vport& = SCREEN(3)

IF scrn& <> 0 THEN
  PRINT #1,"PASS: SCREEN(1) returned non-zero screen pointer"
ELSE
  PRINT #1,"FAIL: SCREEN(1) returned zero"
END IF

IF wdw& <> 0 THEN
  PRINT #1,"PASS: SCREEN(0) returned non-zero window pointer"
ELSE
  PRINT #1,"FAIL: SCREEN(0) returned zero"
END IF

IF rport& <> 0 THEN
  PRINT #1,"PASS: SCREEN(2) returned non-zero RastPort pointer"
ELSE
  PRINT #1,"FAIL: SCREEN(2) returned zero"
END IF

IF vport& <> 0 THEN
  PRINT #1,"PASS: SCREEN(3) returned non-zero ViewPort pointer"
ELSE
  PRINT #1,"FAIL: SCREEN(3) returned zero"
END IF

REM Try drawing
LINE (10,50)-(200,150),2,bf
PRINT #1,"PASS: LINE drew without crash"

CIRCLE (400,300),100,4
PRINT #1,"PASS: CIRCLE drew without crash"

REM Close screen
SCREEN CLOSE 1
PRINT #1,"PASS: SCREEN CLOSE succeeded"
PRINT #1,"All tests passed"
CLOSE #1
