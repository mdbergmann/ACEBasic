REM *** Atom type test ***

DECLARE SUB TestAtom(ATOM a)

REM --- Declaration with initialization ---
ATOM state = :ready
ASSERT state = :ready, "atom declare and init"

REM --- Inequality ---
ASSERT state <> :done, "atom inequality"

REM --- Reassignment ---
state = :done
ASSERT state = :done, "atom reassignment"

REM --- Same atom literal produces same value ---
ATOM other = :done
ASSERT state = other, "same atom name equals same value"

REM --- Different atoms are not equal ---
other = :waiting
ASSERT state <> other, "different atoms not equal"

REM --- Declaration without initialization ---
ATOM unset
ASSERT unset <> :ready, "uninitialized atom is zero"

REM --- Atom in SUB parameter ---
CALL TestAtom(:hello)

REM --- Atom in CASE ---
ATOM action = :run
CASE
  action = :stop: ASSERT 0, "should not match stop"
  action = :run: ASSERT 1, "case matched run"
END CASE

PRINT "All atom tests passed."

SUB TestAtom(ATOM a)
  ASSERT a = :hello, "atom SUB parameter"
END SUB
