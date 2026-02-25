REM testkit.b - shared test assertion library for ACE BASIC submodules

SHORTINT _tkPassed, _tkFailed

SUB TkInit EXTERNAL
  SHARED _tkPassed, _tkFailed
  _tkPassed = 0
  _tkFailed = 0
END SUB

SUB TkSummary EXTERNAL
  SHARED _tkPassed, _tkFailed
  PRINT ""
  PRINT "Results:"; _tkPassed; " passed,"; _tkFailed; " failed"
  ASSERT _tkFailed = 0, "Tests failed"
END SUB

SUB TkAssertTrue(SHORTINT condition, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF condition THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertFalse(SHORTINT condition, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF condition = 0 THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertEq%(SHORTINT actual, SHORTINT expected, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF actual = expected THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertEq&(LONGINT actual, LONGINT expected, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF actual = expected THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertEqAddr(ADDRESS actual, ADDRESS expected, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF actual = expected THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertEqStr(actual$, expected$, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF actual$ = expected$ THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected '"; expected$; "' got '"; actual$; "')"
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertEqFloat(SINGLE actual, SINGLE expected, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  SINGLE diff
  diff = actual - expected
  IF diff < 0 THEN diff = -diff
  IF diff < 0.001 THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (expected"; expected; " got"; actual; ")"
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertNeq&(LONGINT actual, LONGINT notExpected, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF actual <> notExpected THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (should not be"; notExpected; ")"
    _tkFailed = _tkFailed + 1
  END IF
END SUB

SUB TkAssertNeqAddr(ADDRESS actual, ADDRESS notExpected, msg$) EXTERNAL
  SHARED _tkPassed, _tkFailed
  IF actual <> notExpected THEN
    _tkPassed = _tkPassed + 1
  ELSE
    PRINT "FAIL: "; msg$; " (should not be"; notExpected; ")"
    _tkFailed = _tkFailed + 1
  END IF
END SUB
