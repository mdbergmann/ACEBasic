{* test_local.b - Offline tests for header management and error handling *}
{* No network needed for T1-T4, error path tests T5-T6 *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc
STRING dump$ SIZE 8192

PRINT "=== Offline Local Tests ==="

TkInit

' ---------------------------------------------------------------
' T1: HttpSetHeader + HttpDumpReqHeaders
' ---------------------------------------------------------------
PRINT "T1: HttpSetHeader + HttpDumpReqHeaders"
HttpSetHeader(myReq, "Accept", "application/json")
HttpSetHeader(myReq, "X-Custom", "test-value")

dump$ = HttpDumpReqHeaders(myReq)
TkAssertTrue(INSTR(dump$, "Accept") > 0, "T1: Accept in dump")
TkAssertTrue(INSTR(dump$, "application/json") > 0, "T1: Accept value")
TkAssertTrue(INSTR(dump$, "X-Custom") > 0, "T1: X-Custom in dump")
TkAssertTrue(INSTR(dump$, "test-value") > 0, "T1: X-Custom value")

' ---------------------------------------------------------------
' T2: HttpSetHeader overwrite
' ---------------------------------------------------------------
PRINT "T2: HttpSetHeader overwrite"
HttpSetHeader(myReq, "Accept", "text/html")

dump$ = HttpDumpReqHeaders(myReq)
TkAssertTrue(INSTR(dump$, "text/html") > 0, "T2: overwritten value")

' The old value should NOT appear
' Count occurrences of "Accept" - should be exactly 1 line
LONGINT pos1, pos2
pos1 = INSTR(dump$, "Accept")
pos2 = INSTR(pos1 + 1, dump$, "Accept")
TkAssertEq&(pos2, 0, "T2: no duplicate Accept header")

' ---------------------------------------------------------------
' T3: HttpClearReqHeaders
' ---------------------------------------------------------------
PRINT "T3: HttpClearReqHeaders"
HttpClearReqHeaders(myReq)

dump$ = HttpDumpReqHeaders(myReq)
TkAssertEq&(LEN(dump$), 0, "T3: dump empty after clear")

' ---------------------------------------------------------------
' T4: Set headers after clear
' ---------------------------------------------------------------
PRINT "T4: Set headers after clear"
HttpSetHeader(myReq, "Authorization", "Bearer tok123")

dump$ = HttpDumpReqHeaders(myReq)
TkAssertTrue(INSTR(dump$, "Authorization") > 0, "T4: Auth header")
TkAssertTrue(INSTR(dump$, "Bearer tok123") > 0, "T4: Auth value")

' Clean up for next tests
HttpClearReqHeaders(myReq)

' ---------------------------------------------------------------
' T5: Error handling - bad host (DNS failure)
' ---------------------------------------------------------------
PRINT "T5: Error handling - bad host"
rc = HttpOpen(myReq, myTcp, "this.host.does.not.exist.invalid", 80, HTTP_PLAIN)
PRINT "  HttpOpen rc:"; rc
TkAssertEq&(rc, HTTP_ERR_DNS, "T5: HTTP_ERR_DNS")

' ---------------------------------------------------------------
' T6: Error handling - bad port (connection refused)
' ---------------------------------------------------------------
PRINT "T6: Error handling - bad port"
rc = HttpOpen(myReq, myTcp, "127.0.0.1", 1, HTTP_PLAIN)
PRINT "  HttpOpen rc:"; rc
TkAssertTrue(rc < 0, "T6: negative error code")

TkSummary
