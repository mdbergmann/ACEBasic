{* test_https.b - Test HTTPS support via AmiSSL *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

STRING resp$ SIZE 8192
ADDRESS respBuf
LONGINT sc, bodyAddr, rc, totalRd, bytesGot, rdDone

respBuf = SADD(resp$)

PRINT "=== HTTPS Test ==="

TkInit

' --- Test 1: HTTPS GET ---
PRINT "T1: HttpGet https://httpbun.com/get"
rc = HttpGet(myReq, myResp, myTcp, ~
             "https://httpbun.com/get")
IF rc < 0 THEN
  IF rc = HTTP_ERR_NO_LIB THEN
    PRINT "  SKIP (AmiSSL not installed)"
  ELSEIF rc = HTTP_ERR_SSL_INIT THEN
    PRINT "  SKIP (AmiSSL init failed)"
  ELSE
    PRINT "  SKIP (error:"; rc; ")"
  END IF
  GOTO SkipAll
END IF
bodyAddr = rc
PRINT "  Status: "; myResp->statusCode
TkAssertEq&(myResp->statusCode, 200, "T1: HTTPS GET status 200")
PRINT "  Body length: "; myResp->contentLen
HttpFreeBuf(bodyAddr)

' --- Test 2: HTTPS POST ---
PRINT "T2: HttpPost https://httpbun.com/post"
rc = HttpPost(myReq, myResp, myTcp, ~
              "https://httpbun.com/post", ~
              "application/x-www-form-urlencoded", ~
              "greeting=hello")
TkAssertTrue(rc > 0, "T2: HttpPost returns body")
IF rc > 0 THEN
  bodyAddr = rc
  PRINT "  Status: "; myResp->statusCode
  TkAssertEq&(myResp->statusCode, 200, "T2: HTTPS POST status 200")
  PRINT "  Body length: "; myResp->contentLen
  HttpFreeBuf(bodyAddr)
END IF

' --- Test 3: Low-level HTTPS ---
PRINT "T3: Low-level HttpOpen with SSL"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 443, HTTP_SSL)
TkAssertEq&(rc, HTTP_SUCCESS, "T3: HttpOpen SSL")
IF rc <> HTTP_SUCCESS THEN GOTO SkipAll

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
TkAssertTrue(rc >= 0, "T3: HttpSendRequest")

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status: "; sc
TkAssertEq&(sc, 200, "T3: status 200")

totalRd = 0
rdDone = 0
WHILE rdDone = 0
  bytesGot = HttpReadBody(myTcp, myResp, respBuf + totalRd, 4096)
  IF bytesGot > 0 THEN
    totalRd = totalRd + bytesGot
  ELSE
    rdDone = 1
  END IF
WEND
POKE respBuf + totalRd, 0
PRINT "  Body length: "; totalRd

HttpClose(myTcp)

SkipAll:
TkSummary
