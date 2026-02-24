REM Error test: TYPECASE with non-class variable should fail
LONGINT x
x = 42
TYPECASE x
  CASE ELSE
    PRINT "should not get here"
END TYPECASE
