{* test_lowlevel_full.b - Comprehensive low-level API test *}
{* Tests: HttpSetHeader, header enumeration, HttpWriteBody, HttpWriteBodyChunked *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, sc
LONGINT totalRd, bytesGot, rdDone
STRING resp$ SIZE 16384
ADDRESS respBuf
STRING ct$ SIZE 256

respBuf = SADD(resp$)

PRINT "=== Comprehensive Low-Level API Test ==="
PRINT

' ---------------------------------------------------------------
' T1: Custom headers via HttpSetHeader
' ---------------------------------------------------------------
PRINT "T1: Custom headers via HttpSetHeader"
rc = HttpOpen(myReq, myTcp, "httpbin.org", 80, HTTP_PLAIN)
IF rc <> HTTP_SUCCESS THEN
  PRINT "  HttpOpen failed:"; rc
  PRINT "  FAIL"
  GOTO EndT1
END IF

HttpSetHeader(myReq, "Accept", "application/json")
HttpSetHeader(myReq, "X-Test-Custom", "hello-ace")

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT1
END IF

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status:"; sc

' Read full response body
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

HttpClose(myTcp)

' Check: status=200 AND body contains our custom header
IF sc = 200 THEN
  IF INSTR(CSTR(respBuf), "hello-ace") > 0 THEN
    PRINT "  Found custom header in response"
    PRINT "  PASS"
  ELSE
    PRINT "  Custom header NOT found in response"
    PRINT "  FAIL"
  END IF
ELSE
  PRINT "  Expected 200, got"; sc
  PRINT "  FAIL"
END IF
EndT1:
PRINT

' ---------------------------------------------------------------
' T2: Response header enumeration
' ---------------------------------------------------------------
PRINT "T2: Response header enumeration"
rc = HttpOpen(myReq, myTcp, "httpbin.org", 80, HTTP_PLAIN)
IF rc <> HTTP_SUCCESS THEN
  PRINT "  HttpOpen failed:"; rc
  PRINT "  FAIL"
  GOTO EndT2
END IF

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT2
END IF

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status:"; sc

LONGINT cnt, i
STRING hn$ SIZE 256
STRING hv$ SIZE 256
cnt = HttpResponseHeaderCount(myResp)
PRINT "  Header count:"; cnt

' Print all headers
FOR i = 0 TO cnt - 1
  hn$ = HttpResponseHeaderName(myResp, i)
  hv$ = HttpResponseHeaderVal(myResp, i)
  PRINT "  ["; i; "] "; hn$; ": "; hv$
NEXT i

' Check Content-Type header
ct$ = HttpGetResponseHeader(myResp, "Content-Type")
PRINT "  Content-Type: "; ct$

' Drain body to properly close connection
rdDone = 0
WHILE rdDone = 0
  bytesGot = HttpReadBody(myTcp, myResp, respBuf, 4096)
  IF bytesGot <= 0 THEN rdDone = 1
WEND

HttpClose(myTcp)

IF cnt > 0 AND INSTR(ct$, "json") > 0 THEN
  PRINT "  PASS"
ELSE
  PRINT "  Expected count>0 and json content-type"
  PRINT "  FAIL"
END IF
EndT2:
PRINT

' ---------------------------------------------------------------
' T3: Low-level POST with HttpWriteBody (Content-Length)
' ---------------------------------------------------------------
PRINT "T3: Low-level POST with HttpWriteBody"
rc = HttpOpen(myReq, myTcp, "httpbin.org", 80, HTTP_PLAIN)
IF rc <> HTTP_SUCCESS THEN
  PRINT "  HttpOpen failed:"; rc
  PRINT "  FAIL"
  GOTO EndT3
END IF

STRING postBody$ SIZE 64
postBody$ = "greeting=hello&who=amiga"

HttpSetHeader(myReq, "Content-Type", "application/x-www-form-urlencoded")
HttpSetHeader(myReq, "Content-Length", "24")

rc = HttpSendRequest(myReq, myTcp, "POST", "/post")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT3
END IF

rc = HttpWriteBody(myTcp, SADD(postBody$), LEN(postBody$))
PRINT "  WriteBody rc:"; rc
IF rc < 0 THEN
  PRINT "  WriteBody failed"
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT3
END IF

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status:"; sc

' Read response body
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

HttpClose(myTcp)

IF sc = 200 THEN
  IF INSTR(CSTR(respBuf), "greeting") > 0 AND ~
     INSTR(CSTR(respBuf), "hello") > 0 THEN
    PRINT "  Found form data in response"
    PRINT "  PASS"
  ELSE
    PRINT "  Form data NOT found in response"
    PRINT "  Body (first 400): "; LEFT$(CSTR(respBuf), 400)
    PRINT "  FAIL"
  END IF
ELSE
  PRINT "  Expected 200, got"; sc
  PRINT "  FAIL"
END IF
EndT3:
PRINT

' ---------------------------------------------------------------
' T4: Low-level POST with HttpWriteBodyChunked
' ---------------------------------------------------------------
PRINT "T4: Low-level POST with HttpWriteBodyChunked"
rc = HttpOpen(myReq, myTcp, "httpbin.org", 80, HTTP_PLAIN)
IF rc <> HTTP_SUCCESS THEN
  PRINT "  HttpOpen failed:"; rc
  PRINT "  FAIL"
  GOTO EndT4
END IF

HttpSetHeader(myReq, "Content-Type", "text/plain")
HttpSetHeader(myReq, "Transfer-Encoding", "chunked")

rc = HttpSendRequest(myReq, myTcp, "POST", "/post")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT4
END IF

STRING chunk1$ SIZE 32
STRING chunk2$ SIZE 32
chunk1$ = "Hello "
chunk2$ = "World"

rc = HttpWriteBodyChunked(myTcp, SADD(chunk1$), LEN(chunk1$))
PRINT "  Chunk1 rc:"; rc
IF rc < 0 THEN
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT4
END IF

rc = HttpWriteBodyChunked(myTcp, SADD(chunk2$), LEN(chunk2$))
PRINT "  Chunk2 rc:"; rc
IF rc < 0 THEN
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT4
END IF

' Send final empty chunk
rc = HttpWriteBodyChunked(myTcp, 0&, 0)
PRINT "  Final chunk rc:"; rc
IF rc < 0 THEN
  HttpClose(myTcp)
  PRINT "  FAIL"
  GOTO EndT4
END IF

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status:"; sc

' Read response body
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

HttpClose(myTcp)

IF sc = 200 THEN
  IF INSTR(CSTR(respBuf), "Hello World") > 0 THEN
    PRINT "  Found chunked body in response"
    PRINT "  PASS"
  ELSE
    PRINT "  Chunked body NOT found in response"
    PRINT "  Body (first 400): "; LEFT$(CSTR(respBuf), 400)
    PRINT "  FAIL"
  END IF
ELSE
  PRINT "  Expected 200, got"; sc
  PRINT "  FAIL"
END IF
EndT4:
PRINT

PRINT "=== All tests done ==="
