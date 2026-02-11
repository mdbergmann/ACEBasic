REM test_http_get.b - Phase 2 high-level API test
REM Tests HttpGet and HttpHead convenience functions
REM #using ace:submods/httpclient/httpclient.o

#include <submods/HTTPClient.h>

LONGINT statusCode
STRING resp$ SIZE 16384

PRINT "=== HTTP High-Level API Test ==="

' Test HttpHead
PRINT "--- HttpHead ---"
statusCode = HttpHead("http://www.google.com/")
PRINT "HEAD status:"; statusCode

' Test HttpGet (pass SADD for direct buffer write)
PRINT "--- HttpGet ---"
statusCode = HttpGet("http://www.google.com/", SADD(resp$))
PRINT "GET status:"; statusCode
PRINT "Body length:"; LEN(resp$)
PRINT "--- Body (first 200 chars) ---"
PRINT LEFT$(resp$, 200)
PRINT "--- End ---"

PRINT "=== Test Done ==="
