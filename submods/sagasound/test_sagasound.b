REM #using ace:submods/sagasound/sagasound.o

{*
** Test program for SagaSound audio submodule.
** Generates a 16-bit sine wave in memory and plays it
** as a looping tone on channel 0.
**
** Requires: Vampire with SAGA audio hardware.
*}

#include <submods/SagaSound.h>

SHORTINT period%, ch%

PRINT "SagaSound Audio Submod Test"
PRINT "==========================="
PRINT

{* Generate a 16-bit sine wave: 32 samples = 64 bytes *}
DIM sineData%(31)
FOR i% = 0 TO 31
  sineData%(i%) = CINT(SIN(i% * 6.2832 / 32) * 32767)
NEXT

LONGINT sampleAddr&
sampleAddr& = VARPTR(sineData%(0))

{* Play at ~440 Hz on channel 0, full volume, 16-bit mono loop *}
period% = SagaSoundPeriod(440& * 32&)

PRINT "Playing 440 Hz sine wave on channel 0..."
PRINT "Period:"; period%
PRINT "Sample address: $"; HEX$(sampleAddr&)
PRINT

SagaSoundPlay(0, sampleAddr&, 64, period%, 255, 255, SAGASOUND_16BIT)

{* Test SagaSoundIsFree - channel 0 should be busy *}
IF SagaSoundIsFree(0) THEN
  PRINT "Channel 0: free (unexpected!)"
ELSE
  PRINT "Channel 0: busy (correct)"
END IF

{* Test SagaSoundFindFree - should return 1 (first free after ch 0) *}
ch% = SagaSoundFindFree()
PRINT "First free channel:"; ch%

PRINT
PRINT "Playing for 2 seconds..."
SLEEP FOR 2

SagaSoundStop(0)

PRINT "Stopped."
