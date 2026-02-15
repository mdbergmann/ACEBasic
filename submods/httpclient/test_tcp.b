REM test_tcp.b - TCP-level raw send/recv test
REM Uses tcpclient directly (HttpSendRawBytes/HttpRecvRawBytes removed)
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/tcpclient.h>

DECLARE STRUCT TcpConn myTcp

LONGINT rc, n
ADDRESS rcvBuf
STRING request$ SIZE 256

PRINT "=== TCP Raw Send/Recv Test ==="

TcpInit

rc = TcpOpen(myTcp, "www.google.com", 80, 0)
ASSERT rc = TCP_SUCCESS, "TcpOpen failed"
PRINT "Connected"

' Send raw HTTP GET
request$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10) + ~
           "Host: www.google.com" + CHR$(13) + CHR$(10) + ~
           "Connection: close" + CHR$(13) + CHR$(10) + ~
           CHR$(13) + CHR$(10)
n = TcpSend(myTcp, SADD(request$), LEN(request$))
PRINT "Sent"; n; "bytes"
ASSERT n > 0, "TcpSend failed"

' Read response (first chunk)
rcvBuf = ALLOC(4096)
n = TcpRecv(myTcp, rcvBuf, 4095)
ASSERT n > 0, "TcpRecv failed"
POKE rcvBuf + n, 0
PRINT "Received"; n; "bytes"
PRINT "--- Response (first 200 chars) ---"
PRINT LEFT$(CSTR(rcvBuf), 200)
PRINT "--- End ---"

TcpClose(myTcp)
PRINT "Connection closed."
PRINT "=== Test Done ==="
