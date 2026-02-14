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
IF rc <> TCP_SUCCESS THEN
  PRINT "TcpOpen failed:"; rc
  STOP
END IF
PRINT "Connected"

' Send raw HTTP GET
request$ = "GET / HTTP/1.1" + CHR$(13) + CHR$(10) + ~
           "Host: www.google.com" + CHR$(13) + CHR$(10) + ~
           "Connection: close" + CHR$(13) + CHR$(10) + ~
           CHR$(13) + CHR$(10)
n = TcpSend(myTcp, SADD(request$), LEN(request$))
PRINT "Sent"; n; "bytes"

IF n < 1 THEN
  PRINT "Send failed"
  TcpClose(myTcp)
  STOP
END IF

' Read response (first chunk)
rcvBuf = ALLOC(4096)
n = TcpRecv(myTcp, rcvBuf, 4095)
IF n > 0 THEN
  POKE rcvBuf + n, 0
  PRINT "Received"; n; "bytes"
  PRINT "--- Response ---"
  PRINT CSTR(rcvBuf)
  PRINT "--- End ---"
ELSE
  PRINT "Recv failed:"; n
END IF

TcpClose(myTcp)
PRINT "Connection closed."
PRINT "=== Test Done ==="
