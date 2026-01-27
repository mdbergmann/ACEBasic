REM Test: Function pointer address can be stored and compared
REM Tests that @SubName produces a consistent address

DECLARE SUB LONGINT Add(LONGINT a, LONGINT b)

ptr1& = @Add
ptr2& = @Add

IF ptr1& = ptr2& THEN
  PRINT "pointers match"
ELSE
  PRINT "FAIL"
END IF

IF ptr1& <> 0 THEN
  PRINT "pointer is non-zero"
ELSE
  PRINT "FAIL"
END IF

SUB LONGINT Add(LONGINT a, LONGINT b)
  Add = a + b
END SUB
