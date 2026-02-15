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
STRING respDump$ SIZE 8192

respBuf = SADD(resp$)

PRINT "=== Comprehensive Low-Level API Test ==="
PRINT

' ---------------------------------------------------------------
' T1: Custom headers via HttpSetHeader
' ---------------------------------------------------------------
PRINT "T1: Custom headers via HttpSetHeader"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "T1: HttpOpen failed"

HttpSetHeader(myReq, "Accept", "application/json")
HttpSetHeader(myReq, "X-Test-Custom", "hello-ace")

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
ASSERT rc >= 0, "T1: HttpSendRequest failed"

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

ASSERT sc = 200, "T1: status not 200"
ASSERT INSTR(CSTR(respBuf), "hello-ace") > 0, "T1: custom header not in response"
PRINT "  Found custom header in response"
PRINT

' ---------------------------------------------------------------
' T2: Response header enumeration
' ---------------------------------------------------------------
PRINT "T2: Response header enumeration"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "T2: HttpOpen failed"

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
ASSERT rc >= 0, "T2: HttpSendRequest failed"

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

ASSERT sc = 200, "T2: status not 200"
ASSERT cnt > 0, "T2: no response headers"
ASSERT INSTR(ct$, "json") > 0, "T2: Content-Type not json"
PRINT

' ---------------------------------------------------------------
' T3: Low-level POST with HttpWriteBody (Content-Length)
' ---------------------------------------------------------------
PRINT "T3: Low-level POST with HttpWriteBody"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "T3: HttpOpen failed"

STRING postBody$ SIZE 64
postBody$ = "greeting=hello&who=amiga"

HttpSetHeader(myReq, "Content-Type", "application/x-www-form-urlencoded")
HttpSetHeader(myReq, "Content-Length", "24")

rc = HttpSendRequest(myReq, myTcp, "POST", "/post")
ASSERT rc >= 0, "T3: HttpSendRequest failed"

rc = HttpWriteBody(myTcp, SADD(postBody$), LEN(postBody$))
PRINT "  WriteBody rc:"; rc
ASSERT rc >= 0, "T3: HttpWriteBody failed"

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

ASSERT sc = 200, "T3: status not 200"
ASSERT INSTR(CSTR(respBuf), "greeting") > 0, "T3: form data not in response"
PRINT "  Found form data in response"
PRINT

' ---------------------------------------------------------------
' T4: Low-level POST with HttpWriteBodyChunked
' ---------------------------------------------------------------
PRINT "T4: Low-level POST with HttpWriteBodyChunked"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "T4: HttpOpen failed"

HttpSetHeader(myReq, "Content-Type", "text/plain")
HttpSetHeader(myReq, "Transfer-Encoding", "chunked")

rc = HttpSendRequest(myReq, myTcp, "POST", "/post")
ASSERT rc >= 0, "T4: HttpSendRequest failed"

STRING chunk1$ SIZE 32
STRING chunk2$ SIZE 32
chunk1$ = "Hello "
chunk2$ = "World"

rc = HttpWriteBodyChunked(myTcp, SADD(chunk1$), LEN(chunk1$))
PRINT "  Chunk1 rc:"; rc
ASSERT rc >= 0, "T4: chunk1 failed"

rc = HttpWriteBodyChunked(myTcp, SADD(chunk2$), LEN(chunk2$))
PRINT "  Chunk2 rc:"; rc
ASSERT rc >= 0, "T4: chunk2 failed"

' Send final empty chunk
rc = HttpWriteBodyChunked(myTcp, 0&, 0)
PRINT "  Final chunk rc:"; rc
ASSERT rc >= 0, "T4: final chunk failed"

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

ASSERT sc = 200, "T4: status not 200"
ASSERT INSTR(CSTR(respBuf), "Hello World") > 0, "T4: chunked body not in response"
PRINT "  Found chunked body in response"
PRINT

' ---------------------------------------------------------------
' T5: HttpDumpRespHeaders
' ---------------------------------------------------------------
PRINT "T5: HttpDumpRespHeaders"
rc = HttpOpen(myReq, myTcp, "httpbun.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "T5: HttpOpen failed"

rc = HttpSendRequest(myReq, myTcp, "GET", "/get")
ASSERT rc >= 0, "T5: HttpSendRequest failed"

sc = HttpReadStatus(myTcp, myResp)
PRINT "  Status:"; sc

respDump$ = HttpDumpRespHeaders(myResp)
PRINT "  Response headers:"
PRINT respDump$
ASSERT LEN(respDump$) > 0, "T5: response header dump empty"
ASSERT INSTR(respDump$, "Content-Type") > 0, "T5: Content-Type not in dump"
PRINT "  Found Content-Type in dump"

' Drain body
rdDone = 0
WHILE rdDone = 0
  bytesGot = HttpReadBody(myTcp, myResp, respBuf, 4096)
  IF bytesGot <= 0 THEN rdDone = 1
WEND

HttpClose(myTcp)

ASSERT sc = 200, "T5: status not 200"
PRINT

PRINT "=== Test Done ==="
