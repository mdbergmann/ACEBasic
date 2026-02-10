REM File I/O benchmark -- measures LINE INPUT and INPUT # read speed
REM Run before and after buffered I/O changes to compare

CONST NUM_LINES = 1000
CONST NUM_RECORDS = 500

SINGLE t0,t1

REM === Write test file: 1000 lines ===
OPEN "O",#1,"T:bench_lines.dat"
FOR i% = 1 TO NUM_LINES
  PRINT #1,"This is benchmark line number";i%
NEXT i%
CLOSE #1

REM === Benchmark: LINE INPUT ===
PRINT "LINE INPUT:";NUM_LINES;"lines..."
t0=TIMER
OPEN "I",#1,"T:bench_lines.dat"
count% = 0
WHILE NOT EOF(1)
  LINE INPUT #1,s$
  count% = count% + 1
WEND
CLOSE #1
t1=TIMER
PRINT "  Read";count%;"lines in";t1-t0;"seconds."
IF t1-t0 > 0 THEN PRINT "  Lines/sec:";count%/(t1-t0)
KILL "T:bench_lines.dat"

REM === Write test file: 500 records of 3 fields ===
OPEN "O",#1,"T:bench_fields.dat"
FOR i% = 1 TO NUM_RECORDS
  WRITE #1,i%,i%*2,i%*3
NEXT i%
CLOSE #1

REM === Benchmark: INPUT # ===
PRINT "INPUT #:";NUM_RECORDS;"records of 3 fields..."
t0=TIMER
OPEN "I",#1,"T:bench_fields.dat"
count% = 0
WHILE NOT EOF(1)
  INPUT #1,a%,b%,c%
  count% = count% + 1
WEND
CLOSE #1
t1=TIMER
PRINT "  Read";count%;"records in";t1-t0;"seconds."
IF t1-t0 > 0 THEN PRINT "  Records/sec:";count%/(t1-t0)
KILL "T:bench_fields.dat"

PRINT "Done."
