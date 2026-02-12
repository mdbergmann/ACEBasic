{* test_https.b - Test HTTPS support via AmiSSL *}
REM #using ace:submods/httpclient/httpclient.o

#include <submods/httpclient.h>

EXTERNAL httpclient

STRING resp$ SIZE 8192
ADDRESS respBuf
LONGINT statusCode

respBuf = SADD(resp$)

PRINT "=== HTTPS Test ==="
PRINT

' --- Test 1: HTTPS GET ---
PRINT "Test 1: HttpGet https://httpbin.org/get"
statusCode = HttpGet("https://httpbin.org/get", respBuf)
IF statusCode = HTTP_ERR_NO_LIB THEN
  PRINT "  SKIP (AmiSSL not installed)"
  PRINT
  GOTO SkipAll
END IF
IF statusCode = HTTP_ERR_SSL_INIT THEN
  PRINT "  SKIP (AmiSSL init failed)"
  PRINT
  GOTO SkipAll
END IF
PRINT "  Status: "; statusCode
IF statusCode = 200 THEN
  PRINT "  Body length: "; LEN(CSTR(respBuf))
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

' --- Test 2: HTTPS POST ---
PRINT "Test 2: HttpPost https://httpbin.org/post"
statusCode = HttpPost("https://httpbin.org/post", ~
                      "application/x-www-form-urlencoded", ~
                      "greeting=hello", respBuf)
PRINT "  Status: "; statusCode
IF statusCode = 200 THEN
  PRINT "  Body length: "; LEN(CSTR(respBuf))
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

' --- Test 3: Low-level HTTPS ---
PRINT "Test 3: Low-level HttpOpen with SSL"
LONGINT hConn, rc
hConn = HttpOpen("httpbin.org", 443, HTTP_SSL)
IF hConn < 1 THEN
  PRINT "  Open failed: "; hConn
  PRINT "  FAIL"
  GOTO SkipLowLevel
END IF
rc = HttpSendRequest(hConn, "GET", "/get")
IF rc < 0 THEN
  PRINT "  SendRequest failed: "; rc
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO SkipLowLevel
END IF
statusCode = HttpReadStatus(hConn)
PRINT "  Status: "; statusCode
IF statusCode = 200 THEN
  LONGINT totalRd, bytesGot, rdDone
  totalRd = 0
  rdDone = 0
  WHILE rdDone = 0
    bytesGot = HttpReadBody(hConn, respBuf + totalRd, 4096)
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
HttpClose(hConn)
SkipLowLevel:
PRINT

SkipAll:
PRINT "=== All tests done ==="
