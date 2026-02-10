REM Test: Buffered file I/O correctness
REM Verifies LINE INPUT, INPUT#, INPUT$, EOF, close/reopen

REM -- LINE INPUT with EOF loop --
OPEN "O",#1,"T:buf1.dat"
PRINT #1,"Alpha"
PRINT #1,"Bravo"
PRINT #1,"Charlie"
CLOSE #1

OPEN "I",#1,"T:buf1.dat"
count% = 0
WHILE NOT EOF(1)
  LINE INPUT #1,s$
  count% = count% + 1
  IF count% = 1 THEN ASSERT s$ = "Alpha", "Line 1"
  IF count% = 2 THEN ASSERT s$ = "Bravo", "Line 2"
  IF count% = 3 THEN ASSERT s$ = "Charlie", "Line 3"
WEND
ASSERT count% = 3, "Should read 3 lines"
CLOSE #1
KILL "T:buf1.dat"

REM -- INPUT # with delimited fields --
OPEN "O",#1,"T:buf2.dat"
WRITE #1,10,20,30
CLOSE #1

OPEN "I",#1,"T:buf2.dat"
INPUT #1,a%,b%,c%
ASSERT a% = 10, "Field 1"
ASSERT b% = 20, "Field 2"
ASSERT c% = 30, "Field 3"
CLOSE #1
KILL "T:buf2.dat"

REM -- INPUT$ character reads --
OPEN "O",#1,"T:buf3.dat"
PRINT #1,"ABCDEFGHIJ"
CLOSE #1

OPEN "I",#1,"T:buf3.dat"
chunk$ = INPUT$(5,#1)
ASSERT chunk$ = "ABCDE", "INPUT$ first 5"
chunk$ = INPUT$(5,#1)
ASSERT chunk$ = "FGHIJ", "INPUT$ next 5"
CLOSE #1
KILL "T:buf3.dat"

REM -- Close and reopen same file number (buffer invalidation) --
OPEN "O",#1,"T:buf_a.dat"
PRINT #1,"File A"
CLOSE #1
OPEN "O",#2,"T:buf_b.dat"
PRINT #2,"File B"
CLOSE #2

OPEN "I",#1,"T:buf_a.dat"
LINE INPUT #1,s$
ASSERT s$ = "File A", "Should read file A"
CLOSE #1

OPEN "I",#1,"T:buf_b.dat"
LINE INPUT #1,s$
ASSERT s$ = "File B", "Should read file B not stale A"
CLOSE #1
KILL "T:buf_a.dat"
KILL "T:buf_b.dat"

PRINT "All buffered I/O tests passed."
