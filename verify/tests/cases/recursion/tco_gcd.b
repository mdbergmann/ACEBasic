REM Test: Tail-Call Optimized GCD
REM With TCO, GCD can handle arbitrarily deep recursion
REM GCD(1000000, 3) requires ~333K iterations - would
REM crash without TCO due to stack overflow
OPTION O+

SUB LONGINT Gcd(a&, b&)
  IF b& = 0 THEN
    Gcd = a&
  ELSE
    Gcd = Gcd(b&, a& MOD b&)
  END IF
END SUB

REM Basic correctness (same as gcd.b regression)
ASSERT Gcd(12, 8) = 4, "GCD(12,8) = 4"
ASSERT Gcd(100, 75) = 25, "GCD(100,75) = 25"
ASSERT Gcd(17, 13) = 1, "GCD(17,13) = 1 (coprime)"
ASSERT Gcd(48, 18) = 6, "GCD(48,18) = 6"
ASSERT Gcd(7, 0) = 7, "GCD(7,0) = 7"
ASSERT Gcd(0, 5) = 5, "GCD(0,5) = 5"

REM Deep recursion - only possible with TCO
ASSERT Gcd(1000000, 3) = 1, "GCD(1000000,3) = 1 (deep)"
ASSERT Gcd(999999, 6) = 3, "GCD(999999,6) = 3 (deep)"
