{* test_tcpclient.b - Test TCP client submodule *}
{* Tests plain TCP, SSL, buffered reads, and multi-connection *}

#include <submods/tcpclient.h>
EXTERNAL tcpclient
EXTERNAL amissl

LONGINT rc, h1, h2, nBytes, lineLen
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

h1 = TcpOpen("www.google.com", 80, 0)
IF h1 < 1 THEN
  PRINT "  FAIL: TcpOpen returned"; h1
  failed = failed + 1
  GOTO test2
END IF

req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(h1, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend returned"; rc
  TcpClose(h1)
  failed = failed + 1
  GOTO test2
END IF

' Read status line using TcpRecvLine
lineLen = TcpRecvLine(h1, lineBuf, TCP_LINE_MAX)
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

TcpClose(h1)

test2:
{ --- Test 2: SSL to httpbin.org:443 --- }
PRINT "Test 2: SSL TCP connection..."

h1 = TcpOpen("httpbin.org", 443, 1)
IF h1 = TCP_ERR_SSL THEN
  PRINT "  SKIP (AmiSSL not available)"
  GOTO test3
END IF
IF h1 < 1 THEN
  PRINT "  FAIL: TcpOpen returned"; h1
  failed = failed + 1
  GOTO test3
END IF

req$ = "GET /get HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: httpbin.org" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(h1, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend returned"; rc
  TcpClose(h1)
  failed = failed + 1
  GOTO test3
END IF

nBytes = TcpRecv(h1, recvBuf, 4095)
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

TcpClose(h1)

test3:
{ --- Test 3: Multiple simultaneous connections --- }
PRINT "Test 3: Two simultaneous connections..."

h1 = TcpOpen("www.google.com", 80, 0)
h2 = TcpOpen("www.google.com", 80, 0)

IF h1 < 1 THEN
  PRINT "  FAIL: First TcpOpen returned"; h1
  failed = failed + 1
  GOTO testDone
END IF
IF h2 < 1 THEN
  PRINT "  FAIL: Second TcpOpen returned"; h2
  TcpClose(h1)
  failed = failed + 1
  GOTO testDone
END IF

IF h1 <> h2 THEN
  PRINT "  Handles:"; h1; " and"; h2; " (distinct)"
ELSE
  PRINT "  FAIL: Same handle for both connections"
  failed = failed + 1
  TcpClose(h1)
  GOTO testDone
END IF

' Send on connection 1
req$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: www.google.com" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = TcpSend(h1, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend on h1 returned"; rc
  TcpClose(h1)
  TcpClose(h2)
  failed = failed + 1
  GOTO testDone
END IF

' Send on connection 2
rc = TcpSend(h2, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: TcpSend on h2 returned"; rc
  TcpClose(h1)
  TcpClose(h2)
  failed = failed + 1
  GOTO testDone
END IF

' Read from connection 1
nBytes = TcpRecv(h1, recvBuf, 4095)
IF nBytes <= 0 THEN
  PRINT "  FAIL: TcpRecv on h1 returned"; nBytes
  TcpClose(h1)
  TcpClose(h2)
  failed = failed + 1
  GOTO testDone
END IF
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  h1 response: "; resp$; " ("; nBytes; " bytes)"

' Read from connection 2
nBytes = TcpRecv(h2, recvBuf, 4095)
IF nBytes <= 0 THEN
  PRINT "  FAIL: TcpRecv on h2 returned"; nBytes
  TcpClose(h1)
  TcpClose(h2)
  failed = failed + 1
  GOTO testDone
END IF
POKE recvBuf + nBytes, 0
resp$ = LEFT$(CSTR(recvBuf), 15)
PRINT "  h2 response: "; resp$; " ("; nBytes; " bytes)"

PRINT "  PASS: Both connections worked"
passed = passed + 1

TcpClose(h1)
TcpClose(h2)

testDone:
TcpCleanup

PRINT ""
PRINT "Results:"; passed; " passed,"; failed; " failed"
IF failed = 0 AND passed > 0 THEN PRINT "ALL TESTS PASSED"

STOP
