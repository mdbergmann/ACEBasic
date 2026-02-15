REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

{* test_tcpclient.b - Test TCP client submodule *}
{* Tests plain TCP, SSL, buffered reads, and multi-connection *}

#include <submods/tcpclient.h>

DECLARE STRUCT TcpConn conn1
DECLARE STRUCT TcpConn conn2

LONGINT rc, nBytes, lineLen
ADDRESS recvBuf, lineBuf
STRING req$ SIZE 256
STRING resp$ SIZE 256

recvBuf = ALLOC(4096)
lineBuf = ALLOC(TCP_LINE_MAX + 1)

{ --- Test 1: Plain TCP to www.google.com:80 --- }
PRINT "Test 1: Plain TCP + TcpRecvLine..."

rc = TcpOpen(conn1, "www.google.com", 80, 0)
ASSERT rc = TCP_SUCCESS, "T1: TcpOpen failed"

req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
ASSERT rc > 0, "T1: TcpSend failed"

' Read status line using TcpRecvLine
lineLen = TcpRecvLine(conn1, lineBuf, TCP_LINE_MAX)
ASSERT lineLen >= 0, "T1: TcpRecvLine failed"
resp$ = CSTR(lineBuf)
PRINT "  Status line: "; resp$
ASSERT LEFT$(resp$, 5) = "HTTP/", "T1: Expected HTTP/ prefix"

TcpClose(conn1)

{ --- Test 2: SSL to httpbin.org:443 --- }
PRINT "Test 2: SSL TCP connection..."

rc = TcpOpen(conn1, "httpbin.org", 443, 1)
IF rc = TCP_ERR_SSL THEN
  PRINT "  SKIP (AmiSSL not available)"
  GOTO test3
END IF
ASSERT rc = TCP_SUCCESS, "T2: TcpOpen failed"

req$ = "GET /get HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: httpbin.org" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
ASSERT rc > 0, "T2: TcpSend failed"

nBytes = TcpRecv(conn1, recvBuf, 4095)
ASSERT nBytes > 0, "T2: TcpRecv returned no data"
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  SSL response ("; nBytes; " bytes): "; resp$
ASSERT LEFT$(resp$, 5) = "HTTP/", "T2: Expected HTTP/ prefix"

TcpClose(conn1)

test3:
{ --- Test 3: Multiple simultaneous connections --- }
PRINT "Test 3: Two simultaneous connections..."

rc = TcpOpen(conn1, "www.google.com", 80, 0)
ASSERT rc = TCP_SUCCESS, "T3: First TcpOpen failed"

rc = TcpOpen(conn2, "www.google.com", 80, 0)
IF rc <> TCP_SUCCESS THEN
  TcpClose(conn1)
END IF
ASSERT rc = TCP_SUCCESS, "T3: Second TcpOpen failed"

' Send on connection 1
req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
ASSERT rc > 0, "T3: TcpSend on conn1 failed"

' Send on connection 2
rc = TcpSend(conn2, SADD(req$), LEN(req$))
ASSERT rc > 0, "T3: TcpSend on conn2 failed"

' Read from connection 1
nBytes = TcpRecv(conn1, recvBuf, 4095)
ASSERT nBytes > 0, "T3: TcpRecv on conn1 failed"
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  conn1 response: "; resp$; " ("; nBytes; " bytes)"

' Read from connection 2
nBytes = TcpRecv(conn2, recvBuf, 4095)
ASSERT nBytes > 0, "T3: TcpRecv on conn2 failed"
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  conn2 response: "; resp$; " ("; nBytes; " bytes)"

TcpClose(conn1)
TcpClose(conn2)

{ --- Test 4: TcpRecvBuf buffered read --- }
PRINT "Test 4: TcpRecvBuf buffered read..."

rc = TcpOpen(conn1, "www.google.com", 80, 0)
ASSERT rc = TCP_SUCCESS, "T4: TcpOpen failed"

req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
ASSERT rc > 0, "T4: TcpSend failed"

' Read status line with TcpRecvLine, then body with TcpRecvBuf
' This tests that both share the internal buffer correctly
lineLen = TcpRecvLine(conn1, lineBuf, TCP_LINE_MAX)
ASSERT lineLen >= 0, "T4: TcpRecvLine failed"
resp$ = CSTR(lineBuf)
PRINT "  Status: "; resp$

' Now read remaining data via TcpRecvBuf (shares buffer with RecvLine)
nBytes = TcpRecvBuf(conn1, recvBuf, 512)
ASSERT nBytes > 0, "T4: TcpRecvBuf returned no data"
PRINT "  TcpRecvBuf read"; nBytes; " bytes after TcpRecvLine"

TcpClose(conn1)

TcpCleanup

PRINT "=== Test Done ==="

STOP
