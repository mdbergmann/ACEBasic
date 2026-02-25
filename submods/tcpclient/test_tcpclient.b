REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

{* test_tcpclient.b - Test TCP client submodule *}
{* Tests plain TCP, SSL, buffered reads, and multi-connection *}

#include <submods/tcpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn conn1
DECLARE STRUCT TcpConn conn2

LONGINT rc, nBytes, lineLen
ADDRESS recvBuf, lineBuf
STRING req$ SIZE 256
STRING resp$ SIZE 256

recvBuf = ALLOC(4096)
lineBuf = ALLOC(TCP_LINE_MAX + 1)

PRINT "=== TCP Client Tests ==="

TkInit

{ --- Test 1: Plain TCP to www.google.com:80 --- }
PRINT "T1: Plain TCP + TcpRecvLine"

rc = TcpOpen(conn1, "www.google.com", 80, 0)
TkAssertEq&(rc, TCP_SUCCESS, "T1: TcpOpen")
IF rc <> TCP_SUCCESS THEN GOTO test2

req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
TkAssertTrue(rc > 0, "T1: TcpSend")

' Read status line using TcpRecvLine
lineLen = TcpRecvLine(conn1, lineBuf, TCP_LINE_MAX)
TkAssertTrue(lineLen >= 0, "T1: TcpRecvLine")
resp$ = CSTR(lineBuf)
PRINT "  Status line: "; resp$
TkAssertEqStr(LEFT$(resp$, 5), "HTTP/", "T1: HTTP/ prefix")

TcpClose(conn1)

test2:
{ --- Test 2: SSL to httpbin.org:443 --- }
PRINT "T2: SSL TCP connection"

rc = TcpOpen(conn1, "httpbin.org", 443, 1)
IF rc = TCP_ERR_SSL THEN
  PRINT "SKIPPED: AmiSSL not available"
  GOTO test3
END IF
TkAssertEq&(rc, TCP_SUCCESS, "T2: TcpOpen SSL")
IF rc <> TCP_SUCCESS THEN GOTO test3

req$ = "GET /get HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: httpbin.org" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
TkAssertTrue(rc > 0, "T2: TcpSend")

nBytes = TcpRecv(conn1, recvBuf, 4095)
TkAssertTrue(nBytes > 0, "T2: TcpRecv returns data")
IF nBytes > 0 THEN
  POKE recvBuf + nBytes, 0
  resp$ = LEFT$(CSTR(recvBuf), 15)
  PRINT "  SSL response ("; nBytes; " bytes): "; resp$
  TkAssertEqStr(LEFT$(resp$, 5), "HTTP/", "T2: HTTP/ prefix")
END IF

TcpClose(conn1)

test3:
{ --- Test 3: Multiple simultaneous connections --- }
PRINT "T3: Two simultaneous connections"

rc = TcpOpen(conn1, "www.google.com", 80, 0)
TkAssertEq&(rc, TCP_SUCCESS, "T3: First TcpOpen")
IF rc <> TCP_SUCCESS THEN GOTO test4

rc = TcpOpen(conn2, "www.google.com", 80, 0)
IF rc <> TCP_SUCCESS THEN
  TcpClose(conn1)
END IF
TkAssertEq&(rc, TCP_SUCCESS, "T3: Second TcpOpen")
IF rc <> TCP_SUCCESS THEN GOTO test4

' Send on connection 1
req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
TkAssertTrue(rc > 0, "T3: TcpSend on conn1")

' Send on connection 2
rc = TcpSend(conn2, SADD(req$), LEN(req$))
TkAssertTrue(rc > 0, "T3: TcpSend on conn2")

' Read from connection 1
nBytes = TcpRecv(conn1, recvBuf, 4095)
TkAssertTrue(nBytes > 0, "T3: TcpRecv on conn1")
IF nBytes > 0 THEN
  POKE recvBuf + nBytes, 0
  resp$ = LEFT$(CSTR(recvBuf), 15)
  PRINT "  conn1 response: "; resp$; " ("; nBytes; " bytes)"
END IF

' Read from connection 2
nBytes = TcpRecv(conn2, recvBuf, 4095)
TkAssertTrue(nBytes > 0, "T3: TcpRecv on conn2")
IF nBytes > 0 THEN
  POKE recvBuf + nBytes, 0
  resp$ = LEFT$(CSTR(recvBuf), 15)
  PRINT "  conn2 response: "; resp$; " ("; nBytes; " bytes)"
END IF

TcpClose(conn1)
TcpClose(conn2)

test4:
{ --- Test 4: TcpRecvBuf buffered read --- }
PRINT "T4: TcpRecvBuf buffered read"

rc = TcpOpen(conn1, "www.google.com", 80, 0)
TkAssertEq&(rc, TCP_SUCCESS, "T4: TcpOpen")
IF rc <> TCP_SUCCESS THEN GOTO done

req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
TkAssertTrue(rc > 0, "T4: TcpSend")

' Read status line with TcpRecvLine, then body with TcpRecvBuf
' This tests that both share the internal buffer correctly
lineLen = TcpRecvLine(conn1, lineBuf, TCP_LINE_MAX)
TkAssertTrue(lineLen >= 0, "T4: TcpRecvLine")
resp$ = CSTR(lineBuf)
PRINT "  Status: "; resp$

' Now read remaining data via TcpRecvBuf (shares buffer with RecvLine)
nBytes = TcpRecvBuf(conn1, recvBuf, 512)
TkAssertTrue(nBytes > 0, "T4: TcpRecvBuf returns data")
PRINT "  TcpRecvBuf read"; nBytes; " bytes after TcpRecvLine"

TcpClose(conn1)

done:
TcpCleanup

TkSummary
