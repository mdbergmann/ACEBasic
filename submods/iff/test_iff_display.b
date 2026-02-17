REM Test IFF submod: open and display a picture
REM Displays picture on its own screen, waits for keypress, then closes
REM #using ace:submods/iff/iff.o
#include <submods/iff.h>

LONGINT rc

PRINT "IFF Display Test"
PRINT "================"

rc = IffInit
IF rc <> IFF_OK THEN
  PRINT "FAIL: IffInit returned"; rc
  STOP
END IF
PRINT "PASS: IffInit OK"

REM --- Open the IFF file ---
rc = IffOpen(1, "SYS:Prefs/Presets/Backdrops/640x480/Stoffa640x480.iff")
IF rc <> IFF_OK THEN
  PRINT "FAIL: IffOpen returned"; rc
  IffShutdown
  STOP
END IF
PRINT "PASS: IffOpen OK"
PRINT "  "; IffWidth(1); "x"; IffHeight(1); "x"; IffDepth(1)

REM --- Display the picture (let ilbm.library create its own screen) ---
PRINT "Displaying picture... press any key to close."
rc = IffDisplay(1, 0&)
IF rc <> IFF_OK THEN
  PRINT "FAIL: IffDisplay returned"; rc
  IffClose(1)
  IffShutdown
  STOP
END IF
PRINT "PASS: IffDisplay OK"

REM --- Wait for keypress ---
WHILE INKEY$ = "" : SLEEP : WEND

REM --- Close channel (closes the screen/window) ---
IffClose(1)
PRINT "PASS: IffClose OK"

IffShutdown
PRINT "Done."
