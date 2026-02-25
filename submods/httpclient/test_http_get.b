REM test_http_get.b - Regression test (low-level + high-level)
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT sc, rc
LONGINT totalLen, bytesGot, rdDone
STRING resp$ SIZE 16384
ADDRESS respBuf

respBuf = SADD(resp$)

PRINT "=== HTTP Regression Test ==="

TkInit

' --- Test 1: HttpHead (high-level) ---
PRINT "T1: HttpHead"
sc = HttpHead(myReq, myResp, myTcp, "http://www.google.com/")
PRINT "  status:"; sc
TkAssertEq&(sc, 200, "T1: HttpHead status 200")

' --- Test 2: Low-level GET (step by step) ---
PRINT "T2: Low-level GET"
rc = HttpOpen(myReq, myTcp, "www.google.com", 80, 0)
TkAssertEq&(rc, HTTP_SUCCESS, "T2: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO done

rc = HttpSendRequest(myReq, myTcp, "GET", "/")
TkAssertTrue(rc >= 0, "T2: HttpSendRequest")
IF rc < 0 THEN GOTO closeT2

sc = HttpReadStatus(myTcp, myResp)
PRINT "  status:"; sc
TkAssertEq&(sc, 200, "T2: status 200")

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
TkAssertTrue(totalLen > 0, "T2: body bytes received")

closeT2:
HttpClose(myTcp)

done:
TkSummary
