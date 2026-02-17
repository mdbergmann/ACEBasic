'..Display an IFF picture using the IFF submodule.
'..Requires: ilbm.library installed in LIBS:

REM #using ACE:submods/iff/iff.o
#include <submods/iff.h>

rc% = IffInit
IF rc% < 0 THEN
  PRINT "Cannot open ilbm.library"
  STOP
END IF

f$ = FileBox$("Select an IFF file")
IF f$ = "" THEN
  IffShutdown
  STOP
END IF

rc% = IffOpen(1, f$)
IF rc% < 0 THEN
  MsgBox f$ + " is not an IFF file.", "Continue"
  IffShutdown
  STOP
END IF

'..Open a screen matching the picture dimensions
SCREEN 1, IffWidth(1), IffHeight(1), IffDepth(1), IffScreenMode(1)

IF ERR THEN
  MsgBox "Unable to open screen.", "Continue"
  IffClose(1)
ELSE
  '..Display picture on ACE screen 1 (pass screen address)
  scrAddr& = WINDOW(7)
  rc% = IffDisplay(1, scrAddr&)
  IF rc% < 0 THEN
    MsgBox "Error reading " + f$ + ".", "Continue"
  ELSE
    WHILE INKEY$ = "" AND NOT MOUSE(0) : SLEEP : WEND
  END IF
  IffClose(1)
  SCREEN CLOSE 1
END IF

IffShutdown
