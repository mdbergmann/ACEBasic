{* test_post.b - Test POST/PUT and UrlEncode for HTTP client *}
REM #using ace:submods/httpclient/httpclient.o
REM #using ace:submods/tcpclient/tcpclient.o
REM #using ace:submods/amissl/amissl.o

#include <submods/httpclient.h>

DECLARE STRUCT TcpConn myTcp
DECLARE STRUCT HttpRequest myReq
DECLARE STRUCT HttpResponse myResp

STRING resp$ SIZE 32768
LONGINT sc

PRINT "=== HTTP POST/PUT Test ==="
PRINT

' --- Test 1: UrlEncode ---
PRINT "Test 1: UrlEncode"
ASSERT UrlEncode("hello world") = "hello%20world", "T1: space encode"
ASSERT UrlEncode("a=1&b=2") = "a%3D1%26b%3D2", "T1: special chars"
ASSERT UrlEncode("foo@bar.com") = "foo%40bar.com", "T1: @ encode"
ASSERT UrlEncode("no-change_ok.txt~") = "no-change_ok.txt~", "T1: unreserved"
PRINT "  UrlEncode results OK"
PRINT

' --- Test 2: POST form data ---
PRINT "Test 2: POST to httpbin.org/post"
sc = HttpPost(myReq, myResp, myTcp, ~
              "http://httpbin.org/post", ~
              "application/x-www-form-urlencoded", ~
              "greeting=hello&who=world", ~
              SADD(resp$), 32768)
PRINT "  Status: "; sc
ASSERT sc = 200, "T2: POST status not 200"
IF LEN(resp$) > 400 THEN
  PRINT "  Body (first 400): "; LEFT$(resp$, 400)
ELSE
  PRINT "  Body: "; resp$
END IF
PRINT

' --- Test 3: PUT JSON data ---
PRINT "Test 3: PUT to httpbin.org/put"
resp$ = ""
STRING q$ SIZE 4
STRING jsonBody$ SIZE 64
q$ = CHR$(34)
jsonBody$ = "{" + q$ + "key" + q$ + ":" + q$ + "value" + q$ + "}"
sc = HttpPut(myReq, myResp, myTcp, ~
             "http://httpbin.org/put", ~
             "application/json", ~
             jsonBody$, ~
             SADD(resp$), 32768)
PRINT "  Status: "; sc
ASSERT sc = 200, "T3: PUT status not 200"
IF LEN(resp$) > 400 THEN
  PRINT "  Body (first 400): "; LEFT$(resp$, 400)
ELSE
  PRINT "  Body: "; resp$
END IF
PRINT

' --- Test 4: HttpRequest with GET (generic) ---
PRINT "Test 4: HttpRequest GET httpbin.org/get"
resp$ = ""
sc = HttpRequest(myReq, myResp, myTcp, ~
                 "http://httpbin.org/get", ~
                 "GET", "", "", SADD(resp$), 32768)
PRINT "  Status: "; sc
ASSERT sc = 200, "T4: GET status not 200"
IF LEN(resp$) > 400 THEN
  PRINT "  Body (first 400): "; LEFT$(resp$, 400)
ELSE
  PRINT "  Body: "; resp$
END IF
PRINT

PRINT "=== Test Done ==="
