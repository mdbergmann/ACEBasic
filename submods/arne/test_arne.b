REM #using ace:submods/arne/arne.o

{*
** Test program for Arne audio submodule.
** Generates a 16-bit sine wave in memory and plays it
** as a looping tone on channel 0.
**
** Requires: Vampire with SAGA/Arne audio hardware.
*}

#include <submods/Arne.h>

SHORTINT period%, ch%

PRINT "Arne Audio Submod Test"
PRINT "====================="
PRINT

{* Generate a 16-bit sine wave: 32 samples = 64 bytes *}
DIM sineData%(31)
FOR i% = 0 TO 31
  sineData%(i%) = CINT(SIN(i% * 6.2832 / 32) * 32767)
NEXT

LONGINT sampleAddr&
sampleAddr& = VARPTR(sineData%(0))

{* Play at ~440 Hz on channel 0, full volume, 16-bit mono loop *}
period% = ArnePeriod(440& * 32&)

PRINT "Playing 440 Hz sine wave on channel 0..."
PRINT "Period:"; period%
PRINT "Sample address: $"; HEX$(sampleAddr&)
PRINT

ArnePlay(0, sampleAddr&, 64, period%, 255, 255, ARNE_16BIT)

{* Test ArneIsFree - channel 0 should be busy *}
IF ArneIsFree(0) THEN
  PRINT "Channel 0: free (unexpected!)"
ELSE
  PRINT "Channel 0: busy (correct)"
END IF

{* Test ArneFindFree - should return 1 (first free after ch 0) *}
ch% = ArneFindFree()
PRINT "First free channel:"; ch%

PRINT
INPUT "Press ENTER to stop..."; dummy$

ArneStop(0)

PRINT "Stopped."
