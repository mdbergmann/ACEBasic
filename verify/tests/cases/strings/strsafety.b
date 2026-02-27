REM --- String buffer safety tests ---
REM Tests that bounded copy/concat truncate without overflow

REM --- Test 1: Assignment truncation ---
STRING sm$ SIZE 8
sm$ = "ABCDEFGHIJKLMNOP"
PRINT "T1:";sm$;"|"
REM Expected: "T1:ABCDEFG|" (7 chars + null = 8)

REM --- Test 2: Concatenation fits ---
STRING aa$ SIZE 16
STRING bb$ SIZE 16
aa$ = "Hello"
bb$ = ", World!"
aa$ = aa$ + bb$
PRINT "T2:";aa$;"|"
REM Expected: "T2:Hello, World!|" (13 chars fits in 16)

REM --- Test 3: Concatenation result truncated on assignment ---
STRING tr$ SIZE 10
x$ = "ABCDEFGHIJ"
y$ = "KLMNOPQRST"
tr$ = x$ + y$
PRINT "T3:";tr$;"|"
REM Expected: "T3:ABCDEFGHI|" (9 chars + null = 10)

REM --- Test 4: Sentinel check (no overflow) ---
LONGINT snt&
STRING bf$ SIZE 8
snt& = 12345678
bf$ = "1234567890ABCDEF"
IF snt& = 12345678 THEN
  PRINT "T4:OK"
ELSE
  PRINT "T4:FAIL sentinel=";snt&
END IF

REM --- Test 5: String array element truncation ---
DIM arr$(3) SIZE 8
arr$(0) = "ABCDE"
arr$(1) = "This is a very long string"
arr$(2) = "OK"
PRINT "T5:";arr$(0);"|";arr$(1);"|";arr$(2);"|"
REM Expected: "T5:ABCDE|This is|OK|" (arr$(1) truncated to 7 chars)

REM --- Test 6: LINE INPUT# truncation ---
fn$ = "T:strsafety_test.tmp"
OPEN "O",#1,fn$
PRINT #1,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
CLOSE #1
STRING lb$ SIZE 12
OPEN "I",#1,fn$
LINE INPUT #1,lb$
CLOSE #1
PRINT "T6:";lb$;"|"
REM Expected: "T6:ABCDEFGHIJK|" (11 chars + null = 12)

PRINT "DONE"
