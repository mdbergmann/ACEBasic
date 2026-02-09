REM ============================================================
REM BenchCodegen -- Measure codegen abstraction improvements
REM ============================================================
REM Compile with old and new compiler, compare elapsed times.
REM Each section isolates one pattern changed by the refactoring.
REM
REM Patterns exercised:
REM   Section 1: Boolean tests      (Phase 2 + Phase 6 peephole)
REM   Section 2: Stack cleanup       (Phase 3)
REM   Section 3: Type coercion       (Phase 4 + peephole)
REM   Section 4: Array indexing      (Phase 5)
REM   Section 5: Combined workload   (all patterns together)
REM ============================================================

DEFLNG a-z
CONST ITERATIONS& = 200000
CONST ARR_ITERS&  = 50000

DIM result&(500)

PRINT "Codegen Abstraction Benchmark"
PRINT "Iterations per section:"; ITERATIONS&
PRINT

REM === Section 1: Boolean tests ===
REM Each IF generates: move.l (sp)+,d0 / tst.l d0 / bne.s
REM Phase 2: cmpi.l #0 -> tst.l  (saves 2 bytes each)
REM Phase 6: move sets flags, tst.l eliminated (saves 2 more)

t1! = TIMER
s = 0
FOR i = 1 TO ITERATIONS&
  a = i
  IF a > 100 THEN
    s = s + 1
  END IF
  IF a > 200 THEN
    s = s + 1
  END IF
  IF a > 300 THEN
    s = s + 1
  END IF
  IF a > 400 THEN
    s = s + 1
  END IF
NEXT
t2! = TIMER
PRINT "Section 1 (boolean tests):"; t2! - t1!; "s  check:"; s

REM === Section 2: Stack cleanup after SUB calls ===
REM Each call generates push args + jsr + addq/add.l to clean stack
REM Phase 3: add.l #N -> addq #N for N<=8  (saves 4 bytes each)

t1! = TIMER
s = 0
FOR i = 1 TO ITERATIONS&
  AddThree(i, i, i)
  s = s + 1
NEXT
t2! = TIMER
PRINT "Section 2 (SUB calls):   "; t2! - t1!; "s  check:"; s

REM === Section 3: Short-to-long coercion ===
REM Mixing SHORT% and LONG& forces ext.l coercion at each operation
REM Phase 4: byte-to-long uses extb.l on 68020+
REM Phase 6 peephole: catches remaining ext.w+ext.l pairs

t1! = TIMER
s = 0
a% = 7
b% = 13
FOR i = 1 TO ITERATIONS&
  c = a% + b%
  d = a% * b%
  e = c + d
  s = s + e
  a% = b%
  b% = (a% + 1) MOD 100
NEXT
t2! = TIMER
PRINT "Section 3 (coercion):    "; t2! - t1!; "s  check:"; s

REM === Section 4: Array indexing ===
REM Array element access generates index scaling (lsl.l #2,d7)
REM Phase 5 wraps this; future 68020+ can use scaled addressing

t1! = TIMER
s = 0
FOR i = 1 TO ARR_ITERS&
  j = i MOD 500
  result&(j) = result&(j) + 1
  s = s + result&(j)
NEXT
t2! = TIMER
PRINT "Section 4 (arrays):      "; t2! - t1!; "s  check:"; s

REM === Section 5: Combined workload ===
REM Exercises all patterns together in a realistic mix

t1! = TIMER
s = 0
a% = 1
FOR i = 1 TO ITERATIONS&
  c = a% + i
  IF c > 500 THEN
    j = c MOD 500
    result&(j) = result&(j) + c
    s = s + result&(j)
  ELSE
    AddThree(c, c, c)
    s = s + 1
  END IF
  a% = (a% + 3) MOD 50
NEXT
t2! = TIMER
PRINT "Section 5 (combined):    "; t2! - t1!; "s  check:"; s

PRINT
PRINT "Done."
STOP

REM --- Helper SUB: takes 3 long args (exercises stack cleanup) ---
SUB AddThree(LONG x, LONG y, LONG z) STATIC
  SHARED s
  s = s + x + y + z
END SUB
