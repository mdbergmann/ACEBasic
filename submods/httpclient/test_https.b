{* test_https.b - Test HTTPS support via AmiSSL *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

STRING resp$ SIZE 8192
ADDRESS respBuf
LONGINT sc, bodyAddr, rc

respBuf = SADD(resp$)

PRINT "=== HTTPS Test ==="
PRINT

' --- Test 1: HTTPS GET ---
PRINT "Test 1: HttpGet https://httpbin.org/get"
rc = HttpGet(myReq, myResp, myTcp, ~
             "https://httpbin.org/get")
IF rc < 0 THEN
  IF rc = HTTP_ERR_NO_LIB THEN
    PRINT "  SKIP (AmiSSL not installed)"
  ELSEIF rc = HTTP_ERR_SSL_INIT THEN
    PRINT "  SKIP (AmiSSL init failed)"
  ELSE
    PRINT "  SKIP (error:"; rc; ")"
  END IF
  PRINT
  GOTO SkipAll
END IF
bodyAddr = rc
PRINT "  Status: "; myResp->statusCode
ASSERT myResp->statusCode = 200, "T1: HTTPS GET status not 200"
PRINT "  Body length: "; myResp->contentLen
HttpFreeBuf(bodyAddr)
PRINT

' --- Test 2: HTTPS POST ---
PRINT "Test 2: HttpPost https://httpbin.org/post"
sc = HttpPost(myReq, myResp, myTcp, ~
              "https://httpbin.org/post", ~
              "application/x-www-form-urlencoded", ~
              "greeting=hello", respBuf, 8192)
PRINT "  Status: "; sc
ASSERT sc = 200, "T2: HTTPS POST status not 200"
PRINT "  Body length: "; LEN(CSTR(respBuf))
PRINT

' --- Test 3: Low-level HTTPS ---
PRINT "Test 3: Low-level HttpOpen with SSL"
LONGINT rc
rc = HttpOpen(myReq, myTcp, "httpbin.org", 443, HTTP_SSL)
ASSERT rc = HTTP_SUCCESS, "T3: HttpOpen SSL failed"
rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
ASSERT rc >= 0, "T3: HttpSendRequest failed"
sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status: "; sc
ASSERT sc = 200, "T3: status not 200"

LONGINT totalRd, bytesGot, rdDone
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
PRINT

SkipAll:
PRINT "=== Test Done ==="
