{* test_post.b - Test POST/PUT and UrlEncode for HTTP client *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o
REM #using ace:submods/testkit/testkit.o

#include <submods/httpclient.h>
#include <submods/testkit.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

LONGINT rc, bodyAddr

PRINT "=== HTTP POST/PUT Test ==="

TkInit

' --- Test 1: UrlEncode ---
PRINT "T1: UrlEncode"
TkAssertEqStr(UrlEncode("hello world"), "hello%20world", "T1: space encode")
TkAssertEqStr(UrlEncode("a=1&b=2"), "a%3D1%26b%3D2", "T1: special chars")
TkAssertEqStr(UrlEncode("foo@bar.com"), "foo%40bar.com", "T1: @ encode")
TkAssertEqStr(UrlEncode("no-change_ok.txt~"), "no-change_ok.txt~", "T1: unreserved")

' --- Test 2: POST form data ---
PRINT "T2: POST to httpbun.com/post"
rc = HttpPost(myReq, myResp, myTcp, ~
              "http://httpbun.com/post", ~
              "application/x-www-form-urlencoded", ~
              "greeting=hello&who=world")
TkAssertTrue(rc > 0, "T2: HttpPost returns body")
IF rc > 0 THEN
  bodyAddr = rc
  PRINT "  Status: "; myResp->statusCode
  TkAssertEq&(myResp->statusCode, 200, "T2: POST status 200")
  PRINT "  Body length: "; myResp->contentLen
  HttpFreeBuf(bodyAddr)
END IF

' --- Test 3: PUT JSON data ---
PRINT "T3: PUT to httpbun.com/put"
STRING q$ SIZE 4
STRING jsonBody$ SIZE 64
q$ = CHR$(34)
jsonBody$ = "{" + q$ + "key" + q$ + ":" + q$ + "value" + q$ + "}"
rc = HttpPut(myReq, myResp, myTcp, ~
             "http://httpbun.com/put", ~
             "application/json", ~
             jsonBody$)
TkAssertTrue(rc > 0, "T3: HttpPut returns body")
IF rc > 0 THEN
  bodyAddr = rc
  PRINT "  Status: "; myResp->statusCode
  TkAssertEq&(myResp->statusCode, 200, "T3: PUT status 200")
  PRINT "  Body length: "; myResp->contentLen
  HttpFreeBuf(bodyAddr)
END IF

' --- Test 4: HttpRequest with GET (generic) ---
PRINT "T4: HttpRequest GET httpbun.com/get"
rc = HttpRequest(myReq, myResp, myTcp, ~
                 "http://httpbun.com/get", ~
                 "GET", "", "")
TkAssertTrue(rc > 0, "T4: HttpRequest returns body")
IF rc > 0 THEN
  bodyAddr = rc
  PRINT "  Status: "; myResp->statusCode
  TkAssertEq&(myResp->statusCode, 200, "T4: GET status 200")
  PRINT "  Body length: "; myResp->contentLen
  HttpFreeBuf(bodyAddr)
END IF

TkSummary
