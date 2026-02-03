REM Test: ELSEIF syntax construct

REM Test 1: Basic ELSEIF (should match second condition)
x% = 2
IF x% = 1 THEN
  PRINT "one"
ELSEIF x% = 2 THEN
  PRINT "two"
ELSEIF x% = 3 THEN
  PRINT "three"
ELSE
  PRINT "other"
END IF

REM Test 2: ELSEIF without ELSE (no match, should skip all)
y% = 5
IF y% = 1 THEN
  PRINT "y one"
ELSEIF y% = 2 THEN
  PRINT "y two"
END IF
PRINT "after"

REM Test 3: First IF condition matches (skip all ELSEIF)
z% = 1
IF z% = 1 THEN
  PRINT "z first"
ELSEIF z% = 2 THEN
  PRINT "z second"
ELSE
  PRINT "z else"
END IF

REM Test 4: Fall through to ELSE (no conditions match)
w% = 99
IF w% = 1 THEN
  PRINT "w one"
ELSEIF w% = 2 THEN
  PRINT "w two"
ELSE
  PRINT "w else"
END IF

REM Test 5: Many ELSEIF clauses
n% = 5
IF n% = 1 THEN
  PRINT "n1"
ELSEIF n% = 2 THEN
  PRINT "n2"
ELSEIF n% = 3 THEN
  PRINT "n3"
ELSEIF n% = 4 THEN
  PRINT "n4"
ELSEIF n% = 5 THEN
  PRINT "n5"
ELSEIF n% = 6 THEN
  PRINT "n6"
ELSE
  PRINT "n other"
END IF

REM Test 6: Nested IF inside ELSEIF block
a% = 2
b% = 1
IF a% = 1 THEN
  PRINT "a1"
ELSEIF a% = 2 THEN
  IF b% = 1 THEN
    PRINT "a2 b1"
  ELSE
    PRINT "a2 b other"
  END IF
ELSE
  PRINT "a other"
END IF

REM Test 7: Complex expressions in conditions
v% = 10
IF v% > 20 THEN
  PRINT "big"
ELSEIF v% > 5 AND v% <= 15 THEN
  PRINT "medium"
ELSEIF v% > 0 THEN
  PRINT "small"
ELSE
  PRINT "zero or negative"
END IF

REM Test 8: Nested ELSEIF inside ELSEIF block
p% = 2
q% = 3
IF p% = 1 THEN
  PRINT "p1"
ELSEIF p% = 2 THEN
  IF q% = 1 THEN
    PRINT "p2 q1"
  ELSEIF q% = 2 THEN
    PRINT "p2 q2"
  ELSEIF q% = 3 THEN
    PRINT "p2 q3"
  ELSE
    PRINT "p2 q other"
  END IF
ELSEIF p% = 3 THEN
  PRINT "p3"
ELSE
  PRINT "p other"
END IF

REM Test 9: Deeply nested ELSEIF
r% = 2
s% = 2
t% = 2
IF r% = 1 THEN
  PRINT "r1"
ELSEIF r% = 2 THEN
  IF s% = 1 THEN
    PRINT "r2 s1"
  ELSEIF s% = 2 THEN
    IF t% = 1 THEN
      PRINT "r2 s2 t1"
    ELSEIF t% = 2 THEN
      PRINT "r2 s2 t2"
    ELSE
      PRINT "r2 s2 t other"
    END IF
  ELSE
    PRINT "r2 s other"
  END IF
ELSE
  PRINT "r other"
END IF

REM Test 10: Single-line IF THEN (true)
c% = 5
IF c% = 5 THEN PRINT "c five"

REM Test 11: Single-line IF THEN (false, no output)
d% = 3
IF d% = 5 THEN PRINT "d five"
PRINT "after d"

REM Test 12: Single-line IF THEN ELSE (true branch)
e% = 1
IF e% = 1 THEN PRINT "e one" ELSE PRINT "e not one"

REM Test 13: Single-line IF THEN ELSE (false branch)
f% = 2
IF f% = 1 THEN PRINT "f one" ELSE PRINT "f not one"

REM Test 14: Single-line IF with multiple statements using colon
g% = 3
IF g% = 3 THEN PRINT "g"; : PRINT " three"

REM Test 15: Mix single-line and block IF
h% = 2
IF h% = 1 THEN PRINT "h one"
IF h% = 2 THEN
  PRINT "h two block"
END IF

REM Test 16: Block IF/ELSE (no ELSEIF) - true branch
i% = 1
IF i% = 1 THEN
  PRINT "i one"
ELSE
  PRINT "i else"
END IF

REM Test 17: Block IF/ELSE (no ELSEIF) - false branch
j% = 5
IF j% = 1 THEN
  PRINT "j one"
ELSE
  PRINT "j else"
END IF

REM Test 18: Simple IF/ELSEIF/ELSE - first matches
k% = 1
IF k% = 1 THEN
  PRINT "k one"
ELSEIF k% = 2 THEN
  PRINT "k two"
ELSE
  PRINT "k else"
END IF

REM Test 19: Simple IF/ELSEIF/ELSE - elseif matches
l% = 2
IF l% = 1 THEN
  PRINT "l one"
ELSEIF l% = 2 THEN
  PRINT "l two"
ELSE
  PRINT "l else"
END IF

REM Test 20: Simple IF/ELSEIF/ELSE - else matches
m% = 9
IF m% = 1 THEN
  PRINT "m one"
ELSEIF m% = 2 THEN
  PRINT "m two"
ELSE
  PRINT "m else"
END IF
