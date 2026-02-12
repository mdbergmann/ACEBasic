REM test_tcp.b - Phase 1 TCP foundation test
REM Connect to HTTP server, send raw GET, print response
REM #using ace:submods/httpclient/httpclient.o

#include <submods/HTTPClient.h>

' Phase 1 test helper declarations (not in header)
DECLARE SUB LONGINT HttpSendRawBytes(LONGINT hConn, ~
                                     STRING msg) EXTERNAL
DECLARE SUB LONGINT HttpRecvRawBytes(LONGINT hConn, ~
                                     ADDRESS rcvBuf, ~
                                     LONGINT rcvSize) EXTERNAL

LONGINT hConn, n
ADDRESS rcvBuf
STRING request SIZE 256

PRINT "=== HTTP TCP Test ==="

hConn = HttpOpen("www.google.com", 80, HTTP_PLAIN)
IF hConn < 1 THEN
  PRINT "HttpOpen failed:"; hConn
  STOP
END IF
PRINT "Connected, handle:"; hConn

' Send raw HTTP GET
request = "GET / HTTP/1.1" + CHR$(13) + CHR$(10) + ~
          "Host: www.google.com" + CHR$(13) + CHR$(10) + ~
          "Connection: close" + CHR$(13) + CHR$(10) + ~
          CHR$(13) + CHR$(10)
n = HttpSendRawBytes(hConn, request)
PRINT "Sent"; n; "bytes"

IF n < 1 THEN
  PRINT "Send failed"
  HttpClose(hConn)
  STOP
END IF

' Read response (first chunk)
rcvBuf = ALLOC(4096)
n = HttpRecvRawBytes(hConn, rcvBuf, 4095)
IF n > 0 THEN
  POKE rcvBuf + n, 0   ' null terminate
  PRINT "Received"; n; "bytes"
  PRINT "--- Response ---"
  PRINT CSTR(rcvBuf)
  PRINT "--- End ---"
ELSE
  PRINT "Recv failed:"; n
END IF

HttpClose(hConn)
PRINT "Connection closed."
PRINT "=== Test Done ==="
