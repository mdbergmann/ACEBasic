REM Test: Tail-Call Optimized Factorial with Accumulator
REM Uses accumulator pattern to make factorial tail-recursive
OPTION O+

SUB LONGINT FactAcc(n%, acc&)
  IF n% <= 1 THEN
    FactAcc = acc&
  ELSE
    FactAcc = FactAcc(n% - 1, n% * acc&)
  END IF
END SUB

REM Basic correctness
ASSERT FactAcc(0, 1) = 1, "0! = 1"
ASSERT FactAcc(1, 1) = 1, "1! = 1"
ASSERT FactAcc(5, 1) = 120, "5! = 120"
ASSERT FactAcc(10, 1) = 3628800, "10! = 3628800"
ASSERT FactAcc(12, 1) = 479001600, "12! = 479001600"
