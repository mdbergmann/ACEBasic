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
PRINT "  Encode 'hello world' = "; UrlEncode("hello world")
PRINT "  Encode 'a=1&b=2'     = "; UrlEncode("a=1&b=2")
PRINT "  Encode 'foo@bar.com' = "; UrlEncode("foo@bar.com")
PRINT "  Encode 'no-change_ok.txt~' = "; UrlEncode("no-change_ok.txt~")
PRINT

' --- Test 2: POST form data ---
PRINT "Test 2: POST to httpbin.org/post"
sc = HttpPost(myReq, myResp, myTcp, ~
              "http://httpbin.org/post", ~
              "application/x-www-form-urlencoded", ~
              "greeting=hello&who=world", ~
              SADD(resp$), 32768)
PRINT "  Status: "; sc
IF sc = 200 THEN
  PRINT "  PASS - got 200"
  ' Show first 400 chars of response
  IF LEN(resp$) > 400 THEN
    PRINT "  Body (first 400): "; LEFT$(resp$, 400)
  ELSE
    PRINT "  Body: "; resp$
  END IF
ELSE
  PRINT "  FAIL - expected 200, got "; sc
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
IF sc = 200 THEN
  PRINT "  PASS - got 200"
  IF LEN(resp$) > 400 THEN
    PRINT "  Body (first 400): "; LEFT$(resp$, 400)
  ELSE
    PRINT "  Body: "; resp$
  END IF
ELSE
  PRINT "  FAIL - expected 200, got "; sc
END IF
PRINT

' --- Test 4: HttpRequest with GET (generic) ---
PRINT "Test 4: HttpRequest GET httpbin.org/get"
resp$ = ""
sc = HttpRequest(myReq, myResp, myTcp, ~
                 "http://httpbin.org/get", ~
                 "GET", "", "", SADD(resp$), 32768)
PRINT "  Status: "; sc
IF sc = 200 THEN
  PRINT "  PASS - got 200"
  IF LEN(resp$) > 400 THEN
    PRINT "  Body (first 400): "; LEFT$(resp$, 400)
  ELSE
    PRINT "  Body: "; resp$
  END IF
ELSE
  PRINT "  FAIL - expected 200, got "; sc
END IF
PRINT

PRINT "=== All tests done ==="
