REM Test IFF submod: open file, query dimensions, verify values
REM Expected: Stoffa640x480.iff = ILBM, 640x480, 5 planes, mode 4
REM #using ace:submods/iff/iff.o
#include <submods/iff.h>

LONGINT rc
LONGINT w, h, d, m

PRINT "IFF Info Test"
PRINT "============="

rc = IffInit
ASSERT rc = IFF_OK, "IffInit failed"
PRINT "PASS: IffInit OK"

REM --- Test: open a known IFF file ---
rc = IffOpen(1, "SYS:Prefs/Presets/Backdrops/640x480/Stoffa640x480.iff")
IF rc <> IFF_OK THEN
  PRINT "IffOpen returned"; rc
  IffShutdown
END IF
ASSERT rc = IFF_OK, "IffOpen failed"
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

ASSERT w = 640, "Width expected 640"
ASSERT h = 480, "Height expected 480"
ASSERT d = 5, "Depth expected 5"
ASSERT m = 4, "ScreenMode expected 4"

REM --- Test: form type ---
LONGINT ftAddr
ftAddr = IffFormType(1)
ASSERT ftAddr <> 0, "FormType returned 0"
STRING ft$ SIZE 8
SHORTINT idx
FOR idx = 0 TO 3
  ft$ = ft$ + CHR$(PEEK(ftAddr + idx))
NEXT idx
PRINT "  FormType: "; ft$
ASSERT ft$ = "ILBM", "FormType expected ILBM"

REM --- Test: invalid channel ---
ASSERT IffWidth(0) = 0, "Invalid chan 0 should return 0"
ASSERT IffWidth(16) = 0, "Invalid chan 16 should return 0"

REM --- Test: close and re-query ---
IffClose(1)
ASSERT IffWidth(1) = 0, "Width after close should be 0"

PRINT "============="
PRINT "Done."

IffShutdown
