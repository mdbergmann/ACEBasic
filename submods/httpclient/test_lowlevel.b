REM test_lowlevel.b - Low-level struct-based API test
REM Connect via HttpOpen, send GET via low-level API, print status + headers + body
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, sc, n
LONGINT dataBuf
STRING ctHdr$ SIZE 256
STRING srvHdr$ SIZE 256

PRINT "=== HTTP Low-Level API Test ==="

' Open connection
rc = HttpOpen(myReq, myTcp, "www.google.com", 80, HTTP_PLAIN)
ASSERT rc = HTTP_SUCCESS, "HttpOpen failed"
PRINT "Connected"

' Send GET request using low-level API
rc = HttpSendRequest(myReq, myTcp, "GET", "/")
ASSERT rc >= 0, "HttpSendRequest failed"
PRINT "Request sent"

' Read status line + headers
sc = HttpReadStatus(myTcp, myResp)
ASSERT sc > 0, "HttpReadStatus failed"
PRINT "Status code:"; sc

' Read some response headers
ctHdr$ = HttpGetResponseHeader(myResp, "Content-Type")
PRINT "Content-Type: "; ctHdr$

srvHdr$ = HttpGetResponseHeader(myResp, "Server")
PRINT "Server: "; srvHdr$

' Read body (first chunk)
dataBuf = ALLOC(4096)
n = HttpReadBody(myTcp, myResp, dataBuf, 4095)
ASSERT n > 0, "HttpReadBody returned no data"
POKE dataBuf + n, 0
PRINT "Body bytes:"; n
PRINT "--- Body (first 200 chars) ---"
PRINT LEFT$(CSTR(dataBuf), 200)
PRINT "--- End ---"

HttpClose(myTcp)
PRINT "Connection closed."
PRINT "=== Test Done ==="
