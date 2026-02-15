REM test_chunked.b - Chunked transfer decoding test
REM Tests that chunked responses are decoded transparently
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, sc, n, totalBytes
LONGINT dataBuf, rdDone
STRING xferHdr$ SIZE 256
STRING resp$ SIZE 16384

PRINT "=== Chunked Transfer Decoding Test ==="

' --- Test 1: Low-level API with chunked response ---
PRINT "--- Test 1: Low-level chunked read ---"

rc = HttpOpen(myReq, myTcp, "www.google.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "T1: HttpOpen failed"
PRINT "Connected"

rc = HttpSendRequest(myReq, myTcp, "GET", "/")
ASSERT rc >= 0, "T1: HttpSendRequest failed"

sc = HttpReadStatus(myTcp, myResp)
ASSERT sc = 200, "T1: status not 200"
PRINT "Status:"; sc

xferHdr$ = HttpGetResponseHeader(myResp, "Transfer-Encoding")
PRINT "Transfer-Encoding: "; xferHdr$

' Read full body in a loop
dataBuf = ALLOC(4096)
totalBytes = 0
rdDone = 0
WHILE rdDone = 0
  n = HttpReadBody(myTcp, myResp, dataBuf, 4095)
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
ASSERT totalBytes > 0, "T1: no body bytes received"
HttpClose(myTcp)

' --- Test 2: High-level HttpGet with chunked ---
PRINT "--- Test 2: HttpGet (chunked transparent) ---"

sc = HttpGet(myReq, myResp, myTcp, ~
             "http://www.google.com/", SADD(resp$), 16384)
PRINT "GET status:"; sc
ASSERT sc = 200, "T2: HttpGet status not 200"
PRINT "Body length:"; LEN(resp$)
ASSERT LEN(resp$) > 0, "T2: empty body"
IF LEN(resp$) > 0 THEN
  PRINT "Starts with: "; LEFT$(resp$, 60)
END IF

PRINT "=== Test Done ==="
