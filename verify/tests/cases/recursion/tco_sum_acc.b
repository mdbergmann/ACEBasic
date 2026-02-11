REM Test: Tail-Call Optimized Sum with Accumulator
REM Demonstrates accumulator pattern for TCO

SUB LONGINT SumAcc(n%, acc&)
  IF n% <= 0 THEN
    SumAcc = acc&
  ELSE
    SumAcc = SumAcc(n% - 1, acc& + n%)
  END IF
END SUB

REM Basic correctness
ASSERT SumAcc(0, 0) = 0, "SumAcc(0,0) = 0"
ASSERT SumAcc(1, 0) = 1, "SumAcc(1,0) = 1"
ASSERT SumAcc(10, 0) = 55, "SumAcc(10,0) = 55"
ASSERT SumAcc(100, 0) = 5050, "SumAcc(100,0) = 5050"

REM Deep recursion - only possible with TCO
ASSERT SumAcc(5000, 0) = 12502500, "SumAcc(5000,0) deep"
