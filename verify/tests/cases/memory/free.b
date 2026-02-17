REM Test: FREE statement for per-block deallocation

REM Basic free: ALLOC then FREE, no crash
ADDRESS ptr
ptr = ALLOC(100, 7)
ASSERT ptr <> 0, "ALLOC should return non-zero"
FREE ptr

REM Free zero: safe no-op
FREE 0

REM Free + realloc: ALLOC, FREE, ALLOC again
ADDRESS ptr2
ptr2 = ALLOC(200, 7)
ASSERT ptr2 <> 0, "Second ALLOC should work"
FREE ptr2
ADDRESS ptr3
ptr3 = ALLOC(200, 7)
ASSERT ptr3 <> 0, "ALLOC after FREE should work"
FREE ptr3

REM Multiple allocs, free in arbitrary order
ADDRESS a, b, c
a = ALLOC(64, 7)
b = ALLOC(128, 7)
c = ALLOC(256, 7)
ASSERT a <> 0, "ALLOC a"
ASSERT b <> 0, "ALLOC b"
ASSERT c <> 0, "ALLOC c"
FREE b
FREE a
FREE c

REM Free + CLEAR ALLOC: free one, clear rest
ADDRESS d, e
d = ALLOC(100, 7)
e = ALLOC(100, 7)
ASSERT d <> 0, "ALLOC d"
ASSERT e <> 0, "ALLOC e"
FREE d
CLEAR ALLOC

REM POKE/PEEK between ALLOC and FREE
ADDRESS buf
buf = ALLOC(16, 7)
ASSERT buf <> 0, "ALLOC buf"
POKEL buf, 12345678
ASSERT PEEKL(buf) = 12345678, "PEEKL should match POKEL value"
FREE buf

REM Program exit with un-freed allocs: cleaned up automatically
ADDRESS leaked
leaked = ALLOC(512, 7)
ASSERT leaked <> 0, "ALLOC leaked"
REM intentionally not freed -- free_alloc handles it at exit

PRINT "ALL FREE TESTS PASSED"
