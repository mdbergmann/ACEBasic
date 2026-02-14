REM #using ace:submods/amissl/amissl.o

{* test_amissl.b - Test AmiSSL submodule *}
{* Tests SSL init, handshake, write, read, and cleanup *}

#include <submods/amissl.h>
EXTERNAL amissl

' bsdsocket.library declarations for raw TCP
DECLARE FUNCTION socket& LIBRARY bsdsocket
DECLARE FUNCTION connect& LIBRARY bsdsocket
DECLARE FUNCTION CloseSocket& LIBRARY bsdsocket
DECLARE FUNCTION gethostbyname& LIBRARY bsdsocket

CONST AF_INET     = 2
CONST SOCK_STREAM = 1

LONGINT bsdBase
LONGINT sock, ipAddr, he, addrList, addrPtr
LONGINT rc, ssl, nBytes
ADDRESS sockBuf, respAddr
STRING resp$ SIZE 256
STRING req$ SIZE 256
LONGINT passed, failed

passed = 0
failed = 0

LIBRARY "bsdsocket.library"

' Copy _BSDSOCKETBase (created by LIBRARY statement) into bsdBase
ASSEM
  move.l  _BSDSOCKETBase,_BSDBASE
END ASSEM

' Allocate sockaddr buffer
sockBuf = ALLOC(16)

{ --- Test 1: SslInit --- }
PRINT "Test 1: SslInit..."

rc = SslInit(bsdBase)
IF rc = SSL_SUCCESS THEN
  PRINT "  PASS: SslInit succeeded"
  passed = passed + 1
ELSEIF rc = SSL_ERR_NO_LIB THEN
  PRINT "  SKIP (AmiSSL not installed)"
  GOTO skipAll
ELSE
  PRINT "  FAIL: SslInit returned"; rc
  failed = failed + 1
  GOTO skipAll
END IF

{ --- Test 2: SSL connection to httpbin.org:443 --- }
PRINT "Test 2: SSL connection + HTTP GET..."

' DNS resolve httpbin.org
he = gethostbyname(SADD("httpbin.org"))
IF he = 0 THEN
  PRINT "  FAIL: DNS failed"
  failed = failed + 1
  GOTO doCleanup
END IF

addrList = PEEKL(he + 16)
addrPtr = PEEKL(addrList)
ipAddr = PEEKL(addrPtr)

' Create socket and connect
sock = socket(AF_INET, SOCK_STREAM, 0)
IF sock < 0 THEN
  PRINT "  FAIL: socket() failed"
  failed = failed + 1
  GOTO doCleanup
END IF

POKE sockBuf, 16
POKE sockBuf + 1, 2
POKEW sockBuf + 2, 443
POKEL sockBuf + 4, ipAddr

rc = connect(sock, sockBuf, 16)
IF rc < 0 THEN
  CloseSocket(sock)
  PRINT "  FAIL: connect() failed"
  failed = failed + 1
  GOTO doCleanup
END IF

' SSL handshake
ssl = SslNewConn(sock)
IF ssl = 0 THEN
  CloseSocket(sock)
  PRINT "  FAIL: SslNewConn returned 0"
  failed = failed + 1
  GOTO doCleanup
END IF

' Send HTTP GET
req$ = "GET /get HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: httpbin.org" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = SslWrite(ssl, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  PRINT "  FAIL: SslWrite returned"; rc
  SslFreeConn(ssl)
  CloseSocket(sock)
  failed = failed + 1
  GOTO doCleanup
END IF

' Read response
respAddr = ALLOC(512)
nBytes = SslRead(ssl, respAddr, 511)
IF nBytes > 0 THEN
  POKE respAddr + nBytes, 0
  resp$ = CSTR(respAddr)
  IF LEFT$(resp$, 5) = "HTTP/" THEN
    PRINT "  PASS: Got HTTP response ("; nBytes; " bytes)"
    passed = passed + 1
  ELSE
    PRINT "  FAIL: Response does not start with HTTP/"
    failed = failed + 1
  END IF
ELSE
  PRINT "  FAIL: SslRead returned"; nBytes
  failed = failed + 1
END IF

' Cleanup SSL + socket
SslFreeConn(ssl)
CloseSocket(sock)

doCleanup:
SslCleanup

skipAll:
PRINT ""
PRINT "Results:"; passed; " passed,"; failed; " failed"
IF failed = 0 AND passed > 0 THEN PRINT "ALL TESTS PASSED"

STOP
