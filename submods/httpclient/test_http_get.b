REM test_http_get.b - Regression test (low-level + high-level)
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT sc, rc
LONGINT totalLen, bytesGot, rdDone
STRING resp$ SIZE 16384
ADDRESS respBuf

respBuf = SADD(resp$)

PRINT "=== HTTP Regression Test ==="

' --- Test 1: HttpHead (high-level) ---
PRINT "T1: HttpHead"
sc = HttpHead(myReq, myResp, myTcp, "http://www.google.com/")
PRINT "  status:"; sc
IF sc = 200 THEN
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF

' --- Test 2: Low-level GET (step by step) ---
PRINT "T2: Low-level GET"
PRINT "  opening..."
rc = HttpOpen(myReq, myTcp, "www.google.com", 80, 0)
PRINT "  rc:"; rc
IF rc <> HTTP_SUCCESS THEN
  PRINT "  FAIL (open)"
  GOTO skipT2
END IF

PRINT "  sending..."
rc = HttpSendRequest(myReq, myTcp, "GET", "/")
PRINT "  send rc:"; rc
IF rc < 0 THEN
  PRINT "  FAIL (send)"
  HttpClose(myTcp)
  GOTO skipT2
END IF

PRINT "  reading status..."
sc = HttpReadStatus(myTcp, myResp)
PRINT "  status:"; sc
IF sc < 0 THEN
  PRINT "  FAIL (status)"
  HttpClose(myTcp)
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
    bytesGot = HttpReadBody(myTcp, myResp, respBuf + totalLen, maxRead)
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
HttpClose(myTcp)
PRINT "  PASS"
skipT2:

PRINT "=== Test Done ==="
