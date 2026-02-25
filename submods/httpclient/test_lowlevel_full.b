{* test_lowlevel_full.b - Comprehensive low-level API test *}
{* Tests: HttpSetHeader, header enumeration, HttpWriteBody, HttpWriteBodyChunked *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, sc
LONGINT totalRd, bytesGot, rdDone
STRING resp$ SIZE 16384
ADDRESS respBuf
STRING ct$ SIZE 256
STRING respDump$ SIZE 8192

respBuf = SADD(resp$)

PRINT "=== Comprehensive Low-Level API Test ==="

TkInit

' ---------------------------------------------------------------
' T1: Custom headers via HttpSetHeader
' ---------------------------------------------------------------
PRINT "T1: Custom headers via HttpSetHeader"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "T1: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO test2

HttpSetHeader(myReq, "Accept", "application/json")
HttpSetHeader(myReq, "X-Test-Custom", "hello-ace")

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
TkAssertTrue(rc >= 0, "T1: HttpSendRequest")

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

TkAssertEq&(sc, 200, "T1: status 200")
TkAssertTrue(INSTR(CSTR(respBuf), "hello-ace") > 0, "T1: custom header in response")

test2:
' ---------------------------------------------------------------
' T2: Response header enumeration
' ---------------------------------------------------------------
PRINT "T2: Response header enumeration"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "T2: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO test3

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
TkAssertTrue(rc >= 0, "T2: HttpSendRequest")

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

TkAssertEq&(sc, 200, "T2: status 200")
TkAssertTrue(cnt > 0, "T2: response headers present")
TkAssertTrue(INSTR(ct$, "json") > 0, "T2: Content-Type json")

test3:
' ---------------------------------------------------------------
' T3: Low-level POST with HttpWriteBody (Content-Length)
' ---------------------------------------------------------------
PRINT "T3: Low-level POST with HttpWriteBody"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "T3: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO test4

STRING postBody$ SIZE 64
postBody$ = "greeting=hello&who=amiga"

HttpSetHeader(myReq, "Content-Type", "application/x-www-form-urlencoded")
HttpSetHeader(myReq, "Content-Length", "24")

rc = HttpSendRequest(myReq, myTcp, "POST", "/post")
TkAssertTrue(rc >= 0, "T3: HttpSendRequest")

rc = HttpWriteBody(myTcp, SADD(postBody$), LEN(postBody$))
TkAssertTrue(rc >= 0, "T3: HttpWriteBody")

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

TkAssertEq&(sc, 200, "T3: status 200")
TkAssertTrue(INSTR(CSTR(respBuf), "greeting") > 0, "T3: form data in response")

test4:
' ---------------------------------------------------------------
' T4: Low-level POST with HttpWriteBodyChunked
' ---------------------------------------------------------------
PRINT "T4: Low-level POST with HttpWriteBodyChunked"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "T4: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO test5

HttpSetHeader(myReq, "Content-Type", "text/plain")
HttpSetHeader(myReq, "Transfer-Encoding", "chunked")

rc = HttpSendRequest(myReq, myTcp, "POST", "/post")
TkAssertTrue(rc >= 0, "T4: HttpSendRequest")

STRING chunk1$ SIZE 32
STRING chunk2$ SIZE 32
chunk1$ = "Hello "
chunk2$ = "World"

rc = HttpWriteBodyChunked(myTcp, SADD(chunk1$), LEN(chunk1$))
TkAssertTrue(rc >= 0, "T4: chunk1")

rc = HttpWriteBodyChunked(myTcp, SADD(chunk2$), LEN(chunk2$))
TkAssertTrue(rc >= 0, "T4: chunk2")

' Send final empty chunk
rc = HttpWriteBodyChunked(myTcp, 0&, 0)
TkAssertTrue(rc >= 0, "T4: final chunk")

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

TkAssertEq&(sc, 200, "T4: status 200")
TkAssertTrue(INSTR(CSTR(respBuf), "Hello World") > 0, "T4: chunked body in response")

test5:
' ---------------------------------------------------------------
' T5: HttpDumpRespHeaders
' ---------------------------------------------------------------
PRINT "T5: HttpDumpRespHeaders"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "T5: HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO done

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
TkAssertTrue(rc >= 0, "T5: HttpSendRequest")

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status:"; sc

respDump$ = HttpDumpRespHeaders(myResp)
TkAssertTrue(LEN(respDump$) > 0, "T5: resp header dump non-empty")
TkAssertTrue(INSTR(respDump$, "Content-Type") > 0, "T5: Content-Type in dump")

' Drain body
rdDone = 0
WHILE rdDone = 0
  bytesGot = HttpReadBody(myTcp, myResp, respBuf, 4096)
  IF bytesGot <= 0 THEN rdDone = 1
WEND

HttpClose(myTcp)

TkAssertEq&(sc, 200, "T5: status 200")

done:
TkSummary
