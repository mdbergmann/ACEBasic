{*
** Visual test for SAGA submodule.
** Opens 320x240 8-bit chunky mode, sets a rainbow palette,
** fills the screen with horizontal color bars.
** Press joystick fire button (port 2) to exit.
**
** Requires Vampire hardware with SAGA chipset.
*}

#include <submods/SAGA.h>

CONST SCR_W = 320
CONST SCR_H = 240

LONGINT rawBuf&, buf&, offset&
SHORTINT x%, y%, i%, r%, g%, b%

PRINT "SAGA chunky test - 320x240 8-bit"
PRINT "Allocating framebuffer..."

' Allocate buffer with 31 extra bytes for 32-byte alignment
rawBuf& = ALLOC(CLNG(SCR_W) * CLNG(SCR_H) + 31)
IF rawBuf& = 0 THEN
  PRINT "ALLOC failed!"
  STOP
END IF

' Align to 32-byte boundary
buf& = (rawBuf& + 31) AND &HFFFFFFE0

' Fill buffer with horizontal bars (each row = row index)
PRINT "Filling buffer..."
FOR y% = 0 TO SCR_H - 1
  offset& = CLNG(y%) * CLNG(SCR_W)
  FOR x% = 0 TO SCR_W - 1
    POKE buf& + offset& + CLNG(x%), y%
  NEXT
NEXT

' Open SAGA 320x240 8-bit mode
PRINT "Opening SAGA display..."
SagaOpen(buf&, SAGA_320x240, SAGA_FMT_8BIT)

' Set rainbow palette (256 entries)
' Cycle through red -> yellow -> green -> cyan -> blue -> magenta
FOR i% = 0 TO 255
  IF i% < 43 THEN
    r% = 255
    g% = i% * 6
    b% = 0
  ELSEIF i% < 86 THEN
    r% = 255 - (i% - 43) * 6
    g% = 255
    b% = 0
  ELSEIF i% < 128 THEN
    r% = 0
    g% = 255
    b% = (i% - 86) * 6
  ELSEIF i% < 171 THEN
    r% = 0
    g% = 255 - (i% - 128) * 6
    b% = 255
  ELSEIF i% < 213 THEN
    r% = (i% - 171) * 6
    g% = 0
    b% = 255
  ELSE
    r% = 255
    g% = 0
    b% = 255 - (i% - 213) * 6
  END IF
  SagaSetColor(i%, r%, g%, b%)
NEXT

' Wait for joystick fire button (port 2)
' CIA-A PRA ($BFE001) bit 7 = 0 when pressed
WHILE (PEEK(&HBFE001) AND &H80) <> 0
  SagaWaitVBL
WEND

' Restore display
SagaClose

PRINT "Done."
