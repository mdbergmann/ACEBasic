{* test_local.b - Offline tests for header management and error handling *}
{* No network needed for T1-T4, error path tests T5-T6 *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc
STRING dump$ SIZE 8192

PRINT "=== Offline Local Tests ==="
PRINT

' ---------------------------------------------------------------
' T1: HttpSetHeader + HttpDumpReqHeaders
' ---------------------------------------------------------------
PRINT "T1: HttpSetHeader + HttpDumpReqHeaders"
HttpSetHeader(myReq, "Accept", "application/json")
HttpSetHeader(myReq, "X-Custom", "test-value")

dump$ = HttpDumpReqHeaders(myReq)
PRINT "  Dump:"
PRINT dump$
ASSERT INSTR(dump$, "Accept") > 0, "T1: Accept not in dump"
ASSERT INSTR(dump$, "application/json") > 0, "T1: Accept value missing"
ASSERT INSTR(dump$, "X-Custom") > 0, "T1: X-Custom not in dump"
ASSERT INSTR(dump$, "test-value") > 0, "T1: X-Custom value missing"
PRINT "  OK"
PRINT

' ---------------------------------------------------------------
' T2: HttpSetHeader overwrite
' ---------------------------------------------------------------
PRINT "T2: HttpSetHeader overwrite"
HttpSetHeader(myReq, "Accept", "text/html")

dump$ = HttpDumpReqHeaders(myReq)
PRINT "  Dump after overwrite:"
PRINT dump$
ASSERT INSTR(dump$, "text/html") > 0, "T2: overwritten value missing"

' The old value should NOT appear
' Count occurrences of "Accept" - should be exactly 1 line
LONGINT pos1, pos2
pos1 = INSTR(dump$, "Accept")
pos2 = INSTR(pos1 + 1, dump$, "Accept")
ASSERT pos2 = 0, "T2: duplicate Accept header found"
PRINT "  OK - single Accept with new value"
PRINT

' ---------------------------------------------------------------
' T3: HttpClearReqHeaders
' ---------------------------------------------------------------
PRINT "T3: HttpClearReqHeaders"
HttpClearReqHeaders(myReq)

dump$ = HttpDumpReqHeaders(myReq)
PRINT "  Dump after clear: ["; dump$; "]"
ASSERT LEN(dump$) = 0, "T3: dump not empty after clear"
PRINT "  OK - headers cleared"
PRINT

' ---------------------------------------------------------------
' T4: Set headers after clear
' ---------------------------------------------------------------
PRINT "T4: Set headers after clear"
HttpSetHeader(myReq, "Authorization", "Bearer tok123")

dump$ = HttpDumpReqHeaders(myReq)
PRINT "  Dump:"
PRINT dump$
ASSERT INSTR(dump$, "Authorization") > 0, "T4: Auth header missing"
ASSERT INSTR(dump$, "Bearer tok123") > 0, "T4: Auth value missing"

' Clean up for next tests
HttpClearReqHeaders(myReq)
PRINT "  OK"
PRINT

' ---------------------------------------------------------------
' T5: Error handling - bad host (DNS failure)
' ---------------------------------------------------------------
PRINT "T5: Error handling - bad host"
rc = HttpOpen(myReq, myTcp, "this.host.does.not.exist.invalid", 80, HTTP_PLAIN)
PRINT "  HttpOpen rc:"; rc
ASSERT rc = HTTP_ERR_DNS, "T5: expected HTTP_ERR_DNS"
PRINT "  OK - got HTTP_ERR_DNS"
PRINT

' ---------------------------------------------------------------
' T6: Error handling - bad port (connection refused)
' ---------------------------------------------------------------
PRINT "T6: Error handling - bad port"
rc = HttpOpen(myReq, myTcp, "127.0.0.1", 1, HTTP_PLAIN)
PRINT "  HttpOpen rc:"; rc
ASSERT rc < 0, "T6: expected negative error code"
PRINT "  OK - got error:"; rc
PRINT

PRINT "=== Test Done ==="
