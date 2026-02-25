REM test_chunked.b - Chunked transfer decoding test
REM Tests that chunked responses are decoded transparently
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, sc, n, totalBytes
LONGINT dataBuf, rdDone
STRING xferHdr$ SIZE 256
STRING resp$ SIZE 16384

PRINT "=== Chunked Transfer Decoding Test ==="

TkInit

' --- Test 1: Low-level API with chunked response ---
PRINT "T1: Low-level chunked read"

rc = HttpOpen(myReq, myTcp, "www.google.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "T1: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO test2

rc = HttpSendRequest(myReq, myTcp, "GET", "/")
TkAssertTrue(rc >= 0, "T1: HttpSendRequest")

sc = HttpReadStatus(myTcp, myResp)
TkAssertEq&(sc, 200, "T1: status 200")
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
TkAssertTrue(totalBytes > 0, "T1: body bytes received")
HttpClose(myTcp)

test2:
' --- Test 2: High-level HttpGet with chunked ---
PRINT "T2: HttpGet (chunked transparent)"

LONGINT bodyAddr, bodyRc
bodyRc = HttpGet(myReq, myResp, myTcp, ~
                 "http://www.google.com/")
TkAssertTrue(bodyRc > 0, "T2: HttpGet returns body")
IF bodyRc <= 0 THEN GOTO done

bodyAddr = bodyRc
PRINT "GET status:"; myResp->statusCode
TkAssertEq&(myResp->statusCode, 200, "T2: HttpGet status 200")
PRINT "Body length:"; myResp->contentLen
TkAssertTrue(myResp->contentLen > 0, "T2: non-empty body")
IF myResp->contentLen > 0 THEN
  PRINT "Starts with: "; LEFT$(CSTR(bodyAddr), 60)
END IF
HttpFreeBuf(bodyAddr)

done:
TkSummary
