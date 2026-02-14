{* test_stream.b - Test streaming callbacks for HTTP client *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

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


LONGINT statusCode

PRINT "=== HTTP Streaming Test ==="
PRINT

' --- Test 1: HttpGetStream ---
PRINT "Test 1: HttpGetStream httpbin.org/get"
totalBytes = 0
statusCode = HttpGetStream("http://httpbin.org/get", BIND(@CountBytes))
PRINT "  Status: "; statusCode
PRINT "  Bytes received: "; totalBytes
IF statusCode = 200 AND totalBytes > 0 THEN
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

' --- Test 2: HttpPostStream with send callback ---
PRINT "Test 2: HttpPostStream httpbin.org/post"
totalBytes = 0
sendDone = 0
statusCode = HttpPostStream("http://httpbin.org/post", ~
                            "application/x-www-form-urlencoded", ~
                            BIND(@SendBody), BIND(@CountBytes))
PRINT "  Status: "; statusCode
PRINT "  Bytes received: "; totalBytes
IF statusCode = 200 AND totalBytes > 0 THEN
  PRINT "  PASS"
ELSE
  PRINT "  FAIL"
END IF
PRINT

PRINT "=== All tests done ==="
