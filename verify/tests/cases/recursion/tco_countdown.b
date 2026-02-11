REM Test: Tail-Call Optimized Countdown
REM Simplest possible tail call: single param, decrements to 0
OPTION O+

SUB LONGINT CountDown(n&)
  IF n& = 0 THEN
    CountDown = 0
  ELSE
    CountDown = CountDown(n& - 1)
  END IF
END SUB

REM Basic correctness
ASSERT CountDown(0) = 0, "CountDown(0) = 0"
ASSERT CountDown(1) = 0, "CountDown(1) = 0"
ASSERT CountDown(10) = 0, "CountDown(10) = 0"

REM Deep recursion - only possible with TCO
ASSERT CountDown(5000) = 0, "CountDown(5000) = 0 (deep)"
