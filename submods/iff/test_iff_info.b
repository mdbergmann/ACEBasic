REM Test IFF submod: open file, query dimensions, verify values
REM Expected: Stoffa640x480.iff = ILBM, 640x480, 5 planes, mode 4
REM #using ace:submods/iff/iff.o
#include <submods/iff.h>

LONGINT rc
LONGINT w, h, d, m

PRINT "IFF Info Test"
PRINT "============="

rc = IffInit
IF rc <> IFF_OK THEN
  PRINT "FAIL: IffInit returned"; rc
  STOP
END IF
PRINT "PASS: IffInit OK"

REM --- Test: open a known IFF file ---
rc = IffOpen(1, "SYS:Prefs/Presets/Backdrops/640x480/Stoffa640x480.iff")
IF rc <> IFF_OK THEN
  PRINT "FAIL: IffOpen returned"; rc
  IffShutdown
  STOP
END IF
PRINT "PASS: IffOpen OK"

REM --- Test: query dimensions ---
w = IffWidth(1)
h = IffHeight(1)
d = IffDepth(1)
m = IffScreenMode(1)

PRINT "  Width:  "; w
PRINT "  Height: "; h
PRINT "  Depth:  "; d
PRINT "  Mode:   "; m

IF w = 640 THEN PRINT "PASS: Width" ELSE PRINT "FAIL: Width expected 640"
IF h = 480 THEN PRINT "PASS: Height" ELSE PRINT "FAIL: Height expected 480"
IF d = 5 THEN PRINT "PASS: Depth" ELSE PRINT "FAIL: Depth expected 5"
IF m = 4 THEN PRINT "PASS: ScreenMode" ELSE PRINT "FAIL: ScreenMode expected 4"

REM --- Test: form type ---
LONGINT ftAddr
ftAddr = IffFormType(1)
IF ftAddr <> 0 THEN
  STRING ft$ SIZE 8
  SHORTINT idx
  FOR idx = 0 TO 3
    ft$ = ft$ + CHR$(PEEK(ftAddr + idx))
  NEXT idx
  PRINT "  FormType: "; ft$
  IF ft$ = "ILBM" THEN PRINT "PASS: FormType" ELSE PRINT "FAIL: FormType expected ILBM"
ELSE
  PRINT "FAIL: FormType returned 0"
END IF

REM --- Test: invalid channel ---
IF IffWidth(0) = 0 THEN PRINT "PASS: Invalid chan 0" ELSE PRINT "FAIL: Invalid chan 0"
IF IffWidth(16) = 0 THEN PRINT "PASS: Invalid chan 16" ELSE PRINT "FAIL: Invalid chan 16"

REM --- Test: close and re-query ---
IffClose(1)
IF IffWidth(1) = 0 THEN PRINT "PASS: Width after close" ELSE PRINT "FAIL: Width after close"

PRINT "============="
PRINT "Done."

IffShutdown
