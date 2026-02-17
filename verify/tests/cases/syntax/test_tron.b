REM -- test_tron.b: TRON/TROFF selective tracing test --
REM Compile with: bas -t test_tron
REM Only calls between TRON and TROFF appear in T:ace_trace.log

DECLARE SUB LONGINT Double(LONGINT x)

LONGINT result

REM This call should NOT be traced (tracing starts ON but we TROFF first)
TROFF
result = Double(10)
PRINT "Double(10) ="; result

REM This call SHOULD be traced
TRON
result = Double(20)
PRINT "Double(20) ="; result

REM This call should NOT be traced
TROFF
result = Double(30)
PRINT "Double(30) ="; result

PRINT "Done."

END

SUB LONGINT Double(LONGINT x)
  Double = x * 2
END SUB
