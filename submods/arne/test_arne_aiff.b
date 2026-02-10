REM #using ace:submods/arne/arne.o

{*
** Test program for Arne audio submodule - raw PCM file playback.
**
** Loads a raw 16-bit PCM file into memory and plays it through
** Arne. Expects a headerless raw PCM file (16-bit signed
** big-endian, mono, 44100 Hz).
**
** Usage: test_arne_aiff <filename>
**
** To create a raw PCM test file from an AIFF on a modern system:
**   sox input.aiff -t raw -r 44100 -b 16 -e signed -B output.raw
**
** Requires: Vampire with SAGA/Arne audio hardware.
*}

#include <submods/Arne.h>
EXTERNAL Arne

DECLARE FUNCTION _Read&(fh&, buf&, length&) LIBRARY dos

STRING fileName SIZE 256
LONGINT fileSize&, rawAddr&, alignedAddr&, fh&, bytesRead&
SHORTINT period%, ch%, playing%

playing% = 0

PRINT "Arne Raw PCM Player"
PRINT "==================="
PRINT

{* Get filename from command line or prompt *}
IF ARGCOUNT > 0 THEN
  fileName = ARG$(1)
ELSE
  INPUT "Enter raw PCM filename: ", fileName
END IF

IF fileName = "" THEN
  PRINT "No filename given."
  GOTO done
END IF

{* Open file and get size *}
OPEN "I", #1, fileName
fh& = HANDLE(1)
IF fh& = 0& THEN
  PRINT "Cannot open: "; fileName
  GOTO done
END IF
fileSize& = LOF(1)

IF fileSize& = 0 THEN
  CLOSE #1
  PRINT "File is empty."
  GOTO done
END IF

PRINT "File: "; fileName
PRINT "Size:"; fileSize&; " bytes"

{* Allocate buffer with 31 extra bytes for 32-byte alignment *}
rawAddr& = ALLOC(fileSize& + 31)
IF rawAddr& = 0 THEN
  CLOSE #1
  PRINT "Out of memory!"
  GOTO done
END IF
alignedAddr& = (rawAddr& + 31) AND &HFFFFFFE0

PRINT "Buffer: $"; HEX$(alignedAddr&); " (aligned)"

{* Load raw PCM data via dos _Read (fast block read) *}
bytesRead& = _Read(fh&, alignedAddr&, fileSize&)
CLOSE #1

IF bytesRead& <> fileSize& THEN
  PRINT "Read error: got"; bytesRead&; " of"; fileSize&; " bytes"
  GOTO done
END IF

{* Play AS 16-bit sterio oneshot at 44100 Hz *}
period% = ArnePeriod(44100&)
ch% = ArneFindFree()

IF ch% < 0 THEN
  PRINT "No free channels!"
  GOTO done
END IF

PRINT "Playing on channel"; ch%; " at 44100 Hz..."
PRINT "Period:"; period%
PRINT
playing% = 1

ArnePlay(ch%, alignedAddr&, fileSize&, period%, 255, 255, ARNE_PLAY16S)

INPUT "Press ENTER to stop..."; dummy$

ArneStop(ch%)

done:
IF playing% THEN
  PRINT "Stopped."
END IF
PRINT "Done."

