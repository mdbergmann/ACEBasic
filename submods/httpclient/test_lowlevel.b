REM test_lowlevel.b - Phase 2 low-level API test
REM Connect via HttpOpen, send GET via low-level API, print status + headers + body
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/HTTPClient.h>

LONGINT hConn, statusCode, n
LONGINT dataBuf
STRING ctHdr$ SIZE 256
STRING srvHdr$ SIZE 256

PRINT "=== HTTP Low-Level API Test ==="

' Open connection
hConn = HttpOpen("www.google.com", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "HttpOpen failed:"; hConn
  STOP
END IF
PRINT "Connected, handle:"; hConn

' Send GET request using low-level API
statusCode = HttpSendRequest(hConn, "GET", "/")
IF statusCode < 0 THEN
  PRINT "HttpSendRequest failed:"; statusCode
  HttpClose(hConn)
  STOP
END IF
PRINT "Request sent"

' Read status line + headers
statusCode = HttpReadStatus(hConn)
IF statusCode < 0 THEN
  PRINT "HttpReadStatus failed:"; statusCode
  HttpClose(hConn)
  STOP
END IF
PRINT "Status code:"; statusCode

' Read some response headers
ctHdr$ = HttpGetResponseHeader(hConn, "Content-Type")
PRINT "Content-Type: "; ctHdr$

srvHdr$ = HttpGetResponseHeader(hConn, "Server")
PRINT "Server: "; srvHdr$

' Read body (first chunk)
dataBuf = ALLOC(4096)
n = HttpReadBody(hConn, dataBuf, 4095)
IF n > 0 THEN
  POKE dataBuf + n, 0
  PRINT "Body bytes:"; n
  PRINT "--- Body (first 200 chars) ---"
  PRINT LEFT$(CSTR(dataBuf), 200)
  PRINT "--- End ---"
ELSE
  PRINT "HttpReadBody returned:"; n
END IF

HttpClose(hConn)
PRINT "Connection closed."
PRINT "=== Test Done ==="
