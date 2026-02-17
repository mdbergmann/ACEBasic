REM -- test_notrace.b: same program WITHOUT tracing --

DECLARE SUB LONGINT Add(LONGINT a, LONGINT b)

LONGINT result

result = Add(3, 5)
PRINT "Add(3,5) ="; result
PRINT "Done."

END

SUB LONGINT Add(LONGINT a, LONGINT b)
  Add = a + b
END SUB
