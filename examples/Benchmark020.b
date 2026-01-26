REM Benchmark: 68020 native vs 68000 library long arithmetic
REM Run twice: once with OPTION 2+ uncommented, once commented out
REM Compare elapsed times

OPTION 2+

DEFLNG a-z

t1! = TIMER

s = 0
FOR i = 1 TO 100000
  a = i * 7
  b = a \ 3
  c = b MOD 5
  s = s + c
NEXT

t2! = TIMER

PRINT "Iterations: 100000"
PRINT "Checksum:"; s
PRINT "Elapsed:"; t2! - t1!; "seconds"
