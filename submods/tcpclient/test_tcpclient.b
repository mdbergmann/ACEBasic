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
LONGINT passed, failed

passed = 0
failed = 0

recvBuf = ALLOC(4096)
lineBuf = ALLOC(TCP_LINE_MAX + 1)

{ --- Test 1: Plain TCP to www.google.com:80 --- }
PRINT "Test 1: Plain TCP + TcpRecvLine..."

rc = TcpOpen(conn1, "www.google.com", 80, 0)
IF rc <> TCP_SUCCESS THEN
  PRINT "  FAIL: TcpOpen returned"; rc
  failed = failed + 1
  GOTO test2
END IF

req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend returned"; rc
  TcpClose(conn1)
  failed = failed + 1
  GOTO test2
END IF

' Read status line using TcpRecvLine
lineLen = TcpRecvLine(conn1, lineBuf, TCP_LINE_MAX)
IF lineLen >= 0 THEN
  resp$ = CSTR(lineBuf)
  IF LEFT$(resp$, 5) = "HTTP/" THEN
    PRINT "  PASS: Got status line: "; resp$
    passed = passed + 1
  ELSE
    PRINT "  FAIL: Expected HTTP/, got: "; resp$
    failed = failed + 1
  END IF
ELSE
  PRINT "  FAIL: TcpRecvLine returned"; lineLen
  failed = failed + 1
END IF

TcpClose(conn1)

test2:
{ --- Test 2: SSL to httpbin.org:443 --- }
PRINT "Test 2: SSL TCP connection..."

rc = TcpOpen(conn1, "httpbin.org", 443, 1)
IF rc = TCP_ERR_SSL THEN
  PRINT "  SKIP (AmiSSL not available)"
  GOTO test3
END IF
IF rc <> TCP_SUCCESS THEN
  PRINT "  FAIL: TcpOpen returned"; rc
  failed = failed + 1
  GOTO test3
END IF

req$ = "GET /get HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: httpbin.org" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend returned"; rc
  TcpClose(conn1)
  failed = failed + 1
  GOTO test3
END IF

nBytes = TcpRecv(conn1, recvBuf, 4095)
IF nBytes > 0 THEN
  POKE recvBuf + nBytes, 0
  resp$ = LEFT$(CSTR(recvBuf), 15)
  IF LEFT$(resp$, 5) = "HTTP/" THEN
    PRINT "  PASS: SSL response ("; nBytes; " bytes)"
    passed = passed + 1
  ELSE
    PRINT "  FAIL: Expected HTTP/, got: "; resp$
    failed = failed + 1
  END IF
ELSE
  PRINT "  FAIL: TcpRecv returned"; nBytes
  failed = failed + 1
END IF

TcpClose(conn1)

test3:
{ --- Test 3: Multiple simultaneous connections --- }
PRINT "Test 3: Two simultaneous connections..."

rc = TcpOpen(conn1, "www.google.com", 80, 0)
IF rc <> TCP_SUCCESS THEN
  PRINT "  FAIL: First TcpOpen returned"; rc
  failed = failed + 1
  GOTO testDone
END IF

rc = TcpOpen(conn2, "www.google.com", 80, 0)
IF rc <> TCP_SUCCESS THEN
  PRINT "  FAIL: Second TcpOpen returned"; rc
  TcpClose(conn1)
  failed = failed + 1
  GOTO testDone
END IF

' Send on connection 1
req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(conn1, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend on conn1 returned"; rc
  TcpClose(conn1)
  TcpClose(conn2)
  failed = failed + 1
  GOTO testDone
END IF

' Send on connection 2
rc = TcpSend(conn2, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend on conn2 returned"; rc
  TcpClose(conn1)
  TcpClose(conn2)
  failed = failed + 1
  GOTO testDone
END IF

' Read from connection 1
nBytes = TcpRecv(conn1, recvBuf, 4095)
IF nBytes <= 0 THEN
  PRINT "  FAIL: TcpRecv on conn1 returned"; nBytes
  TcpClose(conn1)
  TcpClose(conn2)
  failed = failed + 1
  GOTO testDone
END IF
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  conn1 response: "; resp$; " ("; nBytes; " bytes)"

' Read from connection 2
nBytes = TcpRecv(conn2, recvBuf, 4095)
IF nBytes <= 0 THEN
  PRINT "  FAIL: TcpRecv on conn2 returned"; nBytes
  TcpClose(conn1)
  TcpClose(conn2)
  failed = failed + 1
  GOTO testDone
END IF
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  conn2 response: "; resp$; " ("; nBytes; " bytes)"

PRINT "  PASS: Both connections worked"
passed = passed + 1

TcpClose(conn1)
TcpClose(conn2)

testDone:
TcpCleanup

PRINT ""
PRINT "Results:"; passed; " passed,"; failed; " failed"
IF failed = 0 AND passed > 0 THEN PRINT "ALL TESTS PASSED"

STOP
