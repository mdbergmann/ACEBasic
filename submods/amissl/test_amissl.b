REM #using ace:submods/amissl/amissl.o

{* test_amissl.b - Test AmiSSL submodule *}
{* Tests SSL init, handshake, write, read, and cleanup *}

#include <submods/amissl.h>

' bsdsocket.library declarations for raw TCP
DECLARE FUNCTION socket& LIBRARY bsdsocket
DECLARE FUNCTION connect& LIBRARY bsdsocket
DECLARE FUNCTION CloseSocket& LIBRARY bsdsocket
DECLARE FUNCTION gethostbyname& LIBRARY bsdsocket

CONST AF_INET     = 2
CONST SOCK_STREAM = 1

LONGINT sock, ipAddr, he, addrList, addrPtr
LONGINT rc, ssl, nBytes
ADDRESS sockBuf, respAddr
STRING resp$ SIZE 256
STRING req$ SIZE 256

LIBRARY "bsdsocket.library"

' Allocate sockaddr buffer
sockBuf = ALLOC(16)

{ --- Test 1: SslInit --- }
PRINT "Test 1: SslInit..."

rc = SslInit
IF rc = SSL_ERR_NO_LIB THEN
  PRINT "  SKIP (AmiSSL not installed)"
  GOTO skipAll
END IF
ASSERT rc = SSL_SUCCESS, "SslInit failed"
PRINT "  SslInit succeeded"

{ --- Test 2: SSL connection to httpbin.org:443 --- }
PRINT "Test 2: SSL connection + HTTP GET..."

' DNS resolve httpbin.org
he = gethostbyname(SADD("httpbin.org"))
ASSERT he <> 0, "DNS failed"

addrList = PEEKL(he + 16)
addrPtr = PEEKL(addrList)
ipAddr = PEEKL(addrPtr)

' Create socket and connect
sock = socket(AF_INET, SOCK_STREAM, 0)
ASSERT sock >= 0, "socket() failed"

POKE sockBuf, 16
POKE sockBuf + 1, 2
POKEW sockBuf + 2, 443
POKEL sockBuf + 4, ipAddr

rc = connect(sock, sockBuf, 16)
IF rc < 0 THEN
  CloseSocket(sock)
END IF
ASSERT rc >= 0, "connect() failed"

' SSL handshake
ssl = SslNewConn(sock, SADD("httpbin.org"))
IF ssl = 0 THEN
  CloseSocket(sock)
END IF
ASSERT ssl <> 0, "SslNewConn returned 0"

' Send HTTP GET
req$ = "GET /get HTTP/1.1" + CHR$(13) + CHR$(10)
req$ = req$ + "Host: httpbin.org" + CHR$(13) + CHR$(10)
req$ = req$ + "Connection: close" + CHR$(13) + CHR$(10)
req$ = req$ + CHR$(13) + CHR$(10)

rc = SslWrite(ssl, SADD(req$), LEN(req$))
IF rc <= 0 THEN
  SslFreeConn(ssl)
  CloseSocket(sock)
END IF
ASSERT rc > 0, "SslWrite failed"

' Read response
respAddr = ALLOC(512)
nBytes = SslRead(ssl, respAddr, 511)
ASSERT nBytes > 0, "SslRead returned no data"
POKE respAddr + nBytes, 0
resp$ = CSTR(respAddr)
PRINT "  Got"; nBytes; " bytes"
ASSERT LEFT$(resp$, 5) = "HTTP/", "Response does not start with HTTP/"
PRINT "  Response starts with HTTP/"

' Cleanup SSL + socket
SslFreeConn(ssl)
CloseSocket(sock)

SslCleanup

skipAll:
PRINT "=== Test Done ==="

STOP
