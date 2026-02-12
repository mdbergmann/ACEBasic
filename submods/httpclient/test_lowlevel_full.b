{* test_lowlevel_full.b - Comprehensive low-level API test *}
{* Tests: HttpSetHeader, header enumeration, HttpWriteBody, HttpWriteBodyChunked *}
REM #using ace:submods/httpclient/httpclient.o

#include <submods/HTTPClient.h>

EXTERNAL httpclient

LONGINT hConn, statusCode, rc
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
hConn = HttpOpen("httpbin.org", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "  HttpOpen failed:"; hConn
  PRINT "  FAIL"
  GOTO EndT1
END IF

HttpSetHeader(hConn, "Accept", "application/json")
HttpSetHeader(hConn, "X-Test-Custom", "hello-ace")

rc = HttpSendRequest(hConn, "GET", "/get")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT1
END IF

statusCode = HttpReadStatus(hConn)
PRINT "  Status:"; statusCode

' Read full response body
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

HttpClose(hConn)

' Check: status=200 AND body contains our custom header
IF statusCode = 200 THEN
  IF INSTR(CSTR(respBuf), "hello-ace") > 0 THEN
    PRINT "  Found custom header in response"
    PRINT "  PASS"
  ELSE
    PRINT "  Custom header NOT found in response"
    PRINT "  FAIL"
  END IF
ELSE
  PRINT "  Expected 200, got"; statusCode
  PRINT "  FAIL"
END IF
EndT1:
PRINT

' ---------------------------------------------------------------
' T2: Response header enumeration
' ---------------------------------------------------------------
PRINT "T2: Response header enumeration"
hConn = HttpOpen("httpbin.org", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "  HttpOpen failed:"; hConn
  PRINT "  FAIL"
  GOTO EndT2
END IF

rc = HttpSendRequest(hConn, "GET", "/get")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT2
END IF

statusCode = HttpReadStatus(hConn)
PRINT "  Status:"; statusCode

LONGINT cnt, i
STRING hn$ SIZE 256
STRING hv$ SIZE 256
cnt = HttpResponseHeaderCount(hConn)
PRINT "  Header count:"; cnt

' Print all headers
FOR i = 0 TO cnt - 1
  hn$ = HttpResponseHeaderName(hConn, i)
  hv$ = HttpResponseHeaderVal(hConn, i)
  PRINT "  ["; i; "] "; hn$; ": "; hv$
NEXT i

' Check Content-Type header
ct$ = HttpGetResponseHeader(hConn, "Content-Type")
PRINT "  Content-Type: "; ct$

' Drain body to properly close connection
rdDone = 0
WHILE rdDone = 0
  bytesGot = HttpReadBody(hConn, respBuf, 4096)
  IF bytesGot <= 0 THEN rdDone = 1
WEND

HttpClose(hConn)

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
hConn = HttpOpen("httpbin.org", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "  HttpOpen failed:"; hConn
  PRINT "  FAIL"
  GOTO EndT3
END IF

STRING postBody$ SIZE 64
postBody$ = "greeting=hello&who=amiga"

HttpSetHeader(hConn, "Content-Type", "application/x-www-form-urlencoded")
HttpSetHeader(hConn, "Content-Length", "24")

rc = HttpSendRequest(hConn, "POST", "/post")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT3
END IF

rc = HttpWriteBody(hConn, SADD(postBody$), LEN(postBody$))
PRINT "  WriteBody rc:"; rc
IF rc < 0 THEN
  PRINT "  WriteBody failed"
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT3
END IF

statusCode = HttpReadStatus(hConn)
PRINT "  Status:"; statusCode

' Read response body
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

HttpClose(hConn)

IF statusCode = 200 THEN
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
  PRINT "  Expected 200, got"; statusCode
  PRINT "  FAIL"
END IF
EndT3:
PRINT

' ---------------------------------------------------------------
' T4: Low-level POST with HttpWriteBodyChunked
' ---------------------------------------------------------------
PRINT "T4: Low-level POST with HttpWriteBodyChunked"
hConn = HttpOpen("httpbin.org", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "  HttpOpen failed:"; hConn
  PRINT "  FAIL"
  GOTO EndT4
END IF

HttpSetHeader(hConn, "Content-Type", "text/plain")
HttpSetHeader(hConn, "Transfer-Encoding", "chunked")

rc = HttpSendRequest(hConn, "POST", "/post")
IF rc < 0 THEN
  PRINT "  SendRequest failed:"; rc
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT4
END IF

STRING chunk1$ SIZE 32
STRING chunk2$ SIZE 32
chunk1$ = "Hello "
chunk2$ = "World"

rc = HttpWriteBodyChunked(hConn, SADD(chunk1$), LEN(chunk1$))
PRINT "  Chunk1 rc:"; rc
IF rc < 0 THEN
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT4
END IF

rc = HttpWriteBodyChunked(hConn, SADD(chunk2$), LEN(chunk2$))
PRINT "  Chunk2 rc:"; rc
IF rc < 0 THEN
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT4
END IF

' Send final empty chunk
rc = HttpWriteBodyChunked(hConn, 0&, 0)
PRINT "  Final chunk rc:"; rc
IF rc < 0 THEN
  HttpClose(hConn)
  PRINT "  FAIL"
  GOTO EndT4
END IF

statusCode = HttpReadStatus(hConn)
PRINT "  Status:"; statusCode

' Read response body
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

HttpClose(hConn)

IF statusCode = 200 THEN
  IF INSTR(CSTR(respBuf), "Hello World") > 0 THEN
    PRINT "  Found chunked body in response"
    PRINT "  PASS"
  ELSE
    PRINT "  Chunked body NOT found in response"
    PRINT "  Body (first 400): "; LEFT$(CSTR(respBuf), 400)
    PRINT "  FAIL"
  END IF
ELSE
  PRINT "  Expected 200, got"; statusCode
  PRINT "  FAIL"
END IF
EndT4:
PRINT

' ---------------------------------------------------------------
' T5: Header enumeration on invalid handle
' ---------------------------------------------------------------
PRINT "T5: Header enumeration on invalid handle"
LONGINT badCnt
STRING badNm$ SIZE 64
STRING badVl$ SIZE 64

badCnt = HttpResponseHeaderCount(0&)
badNm$ = HttpResponseHeaderName(0&, 0)
badVl$ = HttpResponseHeaderVal(0&, 0)

PRINT "  Count(0):"; badCnt
PRINT "  Name(0,0): '"; badNm$; "'"
PRINT "  Val(0,0): '"; badVl$; "'"

IF badCnt = 0 AND LEN(badNm$) = 0 AND LEN(badVl$) = 0 THEN
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

PRINT "=== All tests done ==="
