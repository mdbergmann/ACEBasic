REM test_lowlevel.b - Low-level struct-based API test
REM Connect via HttpOpen, send GET via low-level API, print status + headers + body
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, sc, n
LONGINT dataBuf
STRING ctHdr$ SIZE 256
STRING srvHdr$ SIZE 256

PRINT "=== HTTP Low-Level API Test ==="

TkInit

' Open connection
rc = HttpOpen(myReq, myTcp, "www.google.com", 80, HTTP_PLAIN)
TkAssertEq&(rc, HTTP_SUCCESS, "HttpOpen")
IF rc <> HTTP_SUCCESS THEN GOTO done

' Send GET request using low-level API
rc = HttpSendRequest(myReq, myTcp, "GET", "/")
TkAssertTrue(rc >= 0, "HttpSendRequest")
IF rc < 0 THEN GOTO closeConn

' Read status line + headers
sc = HttpReadStatus(myTcp, myResp)
TkAssertTrue(sc > 0, "HttpReadStatus")
PRINT "Status code:"; sc

' Read some response headers
ctHdr$ = HttpGetResponseHeader(myResp, "Content-Type")
PRINT "Content-Type: "; ctHdr$

srvHdr$ = HttpGetResponseHeader(myResp, "Server")
PRINT "Server: "; srvHdr$

' Read body (first chunk)
dataBuf = ALLOC(4096)
n = HttpReadBody(myTcp, myResp, dataBuf, 4095)
TkAssertTrue(n > 0, "HttpReadBody returns data")
IF n > 0 THEN
  POKE dataBuf + n, 0
  PRINT "Body bytes:"; n
END IF

closeConn:
HttpClose(myTcp)

done:
TkSummary
