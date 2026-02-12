REM test_chunked.b - Phase 3 chunked transfer decoding test
REM Tests that chunked responses are decoded transparently
REM #using ace:submods/httpclient/httpclient.o

#include <submods/HTTPClient.h>

LONGINT hConn, statusCode, n, totalBytes
LONGINT dataBuf, rdDone
STRING xferHdr$ SIZE 256
STRING resp$ SIZE 16384

PRINT "=== Chunked Transfer Decoding Test ==="

' --- Test 1: Low-level API with chunked response ---
PRINT "--- Test 1: Low-level chunked read ---"

hConn = HttpOpen("www.google.com", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "HttpOpen failed:"; hConn
  STOP
END IF
PRINT "Connected, handle:"; hConn

statusCode = HttpSendRequest(hConn, "GET", "/")
IF statusCode < 0 THEN
  PRINT "HttpSendRequest failed:"; statusCode
  HttpClose(hConn)
  STOP
END IF

statusCode = HttpReadStatus(hConn)
IF statusCode < 0 THEN
  PRINT "HttpReadStatus failed:"; statusCode
  HttpClose(hConn)
  STOP
END IF
PRINT "Status:"; statusCode

xferHdr$ = HttpGetResponseHeader(hConn, "Transfer-Encoding")
PRINT "Transfer-Encoding: "; xferHdr$

' Read full body in a loop
dataBuf = ALLOC(4096)
totalBytes = 0
rdDone = 0
WHILE rdDone = 0
  n = HttpReadBody(hConn, dataBuf, 4095)
  IF n > 0 THEN
    IF totalBytes = 0 THEN
      ' Show first 100 chars of decoded body
      POKE dataBuf + n, 0
      PRINT "First bytes: "; LEFT$(CSTR(dataBuf), 100)
    END IF
    totalBytes = totalBytes + n
  ELSE
    rdDone = 1
  END IF
WEND

PRINT "Total body bytes:"; totalBytes
HttpClose(hConn)

' --- Test 2: High-level HttpGet with chunked ---
PRINT "--- Test 2: HttpGet (chunked transparent) ---"

statusCode = HttpGet("http://www.google.com/", SADD(resp$), 16384)
PRINT "GET status:"; statusCode
PRINT "Body length:"; LEN(resp$)
IF LEN(resp$) > 0 THEN
  PRINT "Starts with: "; LEFT$(resp$, 60)
END IF

PRINT "=== Test Done ==="
