{* test_stream.b - Test streaming callbacks for HTTP client *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT totalBytes
LONGINT sendDone

' --- Receive callback: count bytes ---
SUB LONGINT CountBytes(LONGINT bufAddr, LONGINT bufLen) INVOKABLE
  SHARED totalBytes
  totalBytes = totalBytes + bufLen
  CountBytes = HTTP_CONTINUE
END SUB

' --- Send callback: send form data once, then 0 ---
SUB LONGINT SendBody(LONGINT bufAddr, LONGINT bufSize) INVOKABLE
  SHARED sendDone
  LONGINT i, c
  STRING formData$ SIZE 64

  IF sendDone THEN
    SendBody = 0
    EXIT SUB
  END IF

  formData$ = "greeting=hello&who=world"

  ' Copy form data into the provided buffer
  FOR i = 1 TO LEN(formData$)
    c = ASC(MID$(formData$, i, 1))
    POKE bufAddr + i - 1, c
  NEXT i

  sendDone = 1
  SendBody = LEN(formData$)
END SUB


LONGINT sc

PRINT "=== HTTP Streaming Test ==="

TkInit

' --- Test 1: HttpGetStream ---
PRINT "T1: HttpGetStream httpbun.com/get"
totalBytes = 0
sc = HttpGetStream(myReq, myResp, myTcp, ~
                   "http://httpbun.com/get", BIND(@CountBytes))
PRINT "  Status: "; sc
PRINT "  Bytes received: "; totalBytes
TkAssertEq&(sc, 200, "T1: HttpGetStream status 200")
TkAssertTrue(totalBytes > 0, "T1: bytes received")

' --- Test 2: HttpPostStream with send callback ---
PRINT "T2: HttpPostStream httpbun.com/post"
totalBytes = 0
sendDone = 0
sc = HttpPostStream(myReq, myResp, myTcp, ~
                    "http://httpbun.com/post", ~
                    "application/x-www-form-urlencoded", ~
                    BIND(@SendBody), BIND(@CountBytes))
PRINT "  Status: "; sc
PRINT "  Bytes received: "; totalBytes
TkAssertEq&(sc, 200, "T2: HttpPostStream status 200")
TkAssertTrue(totalBytes > 0, "T2: bytes received")

' --- Test 3: HttpPutStream with send + receive callbacks ---
PRINT "T3: HttpPutStream httpbun.com/put"
totalBytes = 0
sendDone = 0
sc = HttpPutStream(myReq, myResp, myTcp, ~
                   "http://httpbun.com/put", ~
                   "application/x-www-form-urlencoded", ~
                   BIND(@SendBody), BIND(@CountBytes))
PRINT "  Status: "; sc
PRINT "  Bytes received: "; totalBytes
TkAssertEq&(sc, 200, "T3: HttpPutStream status 200")
TkAssertTrue(totalBytes > 0, "T3: bytes received")

' --- Test 4: HttpRequestStream with DELETE (no send body) ---
PRINT "T4: HttpRequestStream DELETE httpbun.com/anything"
totalBytes = 0
sc = HttpRequestStream(myReq, myResp, myTcp, ~
                       "http://httpbun.com/anything", ~
                       "DELETE", "", ~
                       0&, BIND(@CountBytes))
PRINT "  Status: "; sc
PRINT "  Bytes received: "; totalBytes
TkAssertEq&(sc, 200, "T4: HttpRequestStream status 200")
TkAssertTrue(totalBytes > 0, "T4: bytes received")

TkSummary
