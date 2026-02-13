REM test_http_get.b - Regression test (low-level debug version)
REM #using ace:submods/httpclient/httpclient.o

#include <submods/HTTPClient.h>

LONGINT statusCode, hConn, rc
LONGINT totalLen, bytesGot, rdDone
STRING resp$ SIZE 16384
ADDRESS respBuf

respBuf = SADD(resp$)

PRINT "=== HTTP Regression Test ==="

' --- Test 1: HttpHead (high-level) ---
PRINT "T1: HttpHead"
statusCode = HttpHead("http://www.google.com/")
PRINT "  status:"; statusCode
IF statusCode = 200 THEN
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF

' --- Test 2: Low-level GET (step by step) ---
PRINT "T2: Low-level GET"
PRINT "  opening..."
hConn = HttpOpen("www.google.com", 80, 0)
PRINT "  hConn:"; hConn
IF hConn < 1 THEN
  PRINT "  FAIL (open)"
  GOTO skipT2
END IF

PRINT "  sending..."
rc = HttpSendRequest(hConn, "GET", "/")
PRINT "  send rc:"; rc
IF rc < 0 THEN
  PRINT "  FAIL (send)"
  HttpClose(hConn)
  GOTO skipT2
END IF

PRINT "  reading status..."
statusCode = HttpReadStatus(hConn)
PRINT "  status:"; statusCode
IF statusCode < 0 THEN
  PRINT "  FAIL (status)"
  HttpClose(hConn)
  GOTO skipT2
END IF

PRINT "  reading body..."
totalLen = 0
rdDone = 0
LONGINT maxRead
WHILE rdDone = 0
  maxRead = 16383 - totalLen
  IF maxRead <= 0 THEN
    rdDone = 1
  ELSE
    IF maxRead > 4096 THEN maxRead = 4096
    bytesGot = HttpReadBody(hConn, respBuf + totalLen, maxRead)
    IF bytesGot > 0 THEN
      totalLen = totalLen + bytesGot
    ELSE
      rdDone = 1
    END IF
  END IF
WEND
POKE respBuf + totalLen, 0

PRINT "  body bytes:"; totalLen
PRINT "  closing..."
HttpClose(hConn)
PRINT "  PASS"
skipT2:

PRINT "=== Test Done ==="
