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
LONGINT sc

respBuf = SADD(resp$)

PRINT "=== HTTPS Test ==="
PRINT

' --- Test 1: HTTPS GET ---
PRINT "Test 1: HttpGet https://httpbin.org/get"
sc = HttpGet(myReq, myResp, myTcp, ~
             "https://httpbin.org/get", respBuf, 8192)
IF sc = HTTP_ERR_NO_LIB THEN
  PRINT "  SKIP (AmiSSL not installed)"
  PRINT
  GOTO SkipAll
END IF
IF sc = HTTP_ERR_SSL_INIT THEN
  PRINT "  SKIP (AmiSSL init failed)"
  PRINT
  GOTO SkipAll
END IF
PRINT "  Status: "; sc
IF sc = 200 THEN
  PRINT "  Body length: "; LEN(CSTR(respBuf))
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

' --- Test 2: HTTPS POST ---
PRINT "Test 2: HttpPost https://httpbin.org/post"
sc = HttpPost(myReq, myResp, myTcp, ~
              "https://httpbin.org/post", ~
              "application/x-www-form-urlencoded", ~
              "greeting=hello", respBuf, 8192)
PRINT "  Status: "; sc
IF sc = 200 THEN
  PRINT "  Body length: "; LEN(CSTR(respBuf))
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

' --- Test 3: Low-level HTTPS ---
PRINT "Test 3: Low-level HttpOpen with SSL"
LONGINT rc
rc = HttpOpen(myReq, myTcp, "httpbin.org", 443, HTTP_SSL)
IF rc <> HTTP_SUCCESS THEN
  PRINT "  Open failed: "; rc
  PRINT "  FAIL"
  GOTO SkipLowLevel
END IF
rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
IF rc < 0 THEN
  PRINT "  SendRequest failed: "; rc
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO SkipLowLevel
END IF
sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status: "; sc
IF sc = 200 THEN
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
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
HttpClose(myTcp)
SkipLowLevel:
PRINT

SkipAll:
PRINT "=== All tests done ==="
