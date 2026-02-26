REM #using ace:submods/testkit/testkit.o

REM Test parseusing utility
REM Creates temp input files, runs parseusing, checks output.
REM
REM Note: SYSTEM (Execute) redirect captures shell startup bytes.
REM We strip leading non-printable chars via StripLeading$ SUB.

#include <submods/testkit.h>

DEFINT a-z

STRING cmd$ SIZE 256
STRING got$ SIZE 256
STRING pu$ SIZE 64
pu$ = "ace:bin/parseusing"

SUB STRING StripLeading$(txt$)
  STRING retVal$ SIZE 256
  SHORTINT i, ch, found
  retVal$ = ""
  i = 1
  found = 0
  WHILE i <= LEN(txt$) AND found = 0
    ch = ASC(MID$(txt$, i, 1))
    IF ch >= 32 AND ch <= 126 THEN
      found = 1
    ELSE
      i = i + 1
    END IF
  WEND
  IF found THEN
    retVal$ = MID$(txt$, i)
  END IF
  StripLeading$ = retVal$
END SUB

SUB STRING ReadOutput$(fpath$)
  STRING raw$ SIZE 256
  raw$ = ""
  OPEN "I",#2,fpath$
  IF HANDLE(2) <> 0 THEN
    IF NOT EOF(2) THEN
      LINE INPUT #2, raw$
    END IF
    CLOSE #2
  END IF
  ReadOutput$ = StripLeading$(raw$)
END SUB

PRINT "=== parseusing tests ==="
PRINT

TkInit

REM --- Test 1: Single #using directive ---
PRINT "--- single #using ---"
OPEN "O",#1,"T:pu_input1.b"
PRINT #1, "REM This is a test program"
PRINT #1, "REM #using ace:submods/list/list.o"
PRINT #1, "PRINT ";CHR$(34);"hello";CHR$(34)
CLOSE #1

cmd$ = pu$ + " T:pu_input1.b >T:pu_out1.txt"
SYSTEM cmd$
got$ = ReadOutput$("T:pu_out1.txt")
TkAssertEqStr(got$, "ace:submods/list/list.o", "single #using")

REM --- Test 2: Multiple #using directives ---
PRINT "--- multiple #using ---"
OPEN "O",#1,"T:pu_input2.b"
PRINT #1, "REM #using ace:submods/list/list.o"
PRINT #1, "REM some comment"
PRINT #1, "REM #using ace:submods/testkit/testkit.o"
PRINT #1, "PRINT ";CHR$(34);"test";CHR$(34)
CLOSE #1

cmd$ = pu$ + " T:pu_input2.b >T:pu_out2.txt"
SYSTEM cmd$
got$ = ReadOutput$("T:pu_out2.txt")
TkAssertEqStr(got$, "ace:submods/list/list.o ace:submods/testkit/testkit.o", "multiple #using")

REM --- Test 3: No #using directives ---
PRINT "--- no #using ---"
OPEN "O",#1,"T:pu_input3.b"
PRINT #1, "REM Just a regular program"
PRINT #1, "PRINT ";CHR$(34);"hello";CHR$(34)
CLOSE #1

cmd$ = pu$ + " T:pu_input3.b >T:pu_out3.txt"
SYSTEM cmd$
got$ = ReadOutput$("T:pu_out3.txt")
TkAssertEqStr(got$, "", "no #using gives empty output")

REM --- Test 4: Case-insensitive matching ---
PRINT "--- case insensitive ---"
OPEN "O",#1,"T:pu_input4.b"
PRINT #1, "rem #USING ace:submods/foo/foo.o"
PRINT #1, "REM #Using ace:submods/bar/bar.o"
CLOSE #1

cmd$ = pu$ + " T:pu_input4.b >T:pu_out4.txt"
SYSTEM cmd$
got$ = ReadOutput$("T:pu_out4.txt")
TkAssertEqStr(got$, "ace:submods/foo/foo.o ace:submods/bar/bar.o", "case insensitive")

REM --- Test 5: Non-existent input file ---
PRINT "--- non-existent file ---"
cmd$ = pu$ + " T:pu_nonexistent.b >T:pu_out5.txt"
SYSTEM cmd$
got$ = ReadOutput$("T:pu_out5.txt")
TkAssertEqStr(got$, "", "non-existent file gives empty output")

REM --- Test 6: #using beyond line 20 ---
PRINT "--- beyond line 20 ---"
OPEN "O",#1,"T:pu_input6.b"
FOR i = 1 TO 21
  PRINT #1, "REM line ";LTRIM$(STR$(i))
NEXT i
PRINT #1, "REM #using ace:submods/late/late.o"
CLOSE #1

cmd$ = pu$ + " T:pu_input6.b >T:pu_out6.txt"
SYSTEM cmd$
got$ = ReadOutput$("T:pu_out6.txt")
TkAssertEqStr(got$, "", "#using beyond line 20 not found")

REM --- Cleanup temp files ---
SYSTEM "delete >NIL: T:pu_input#?"
SYSTEM "delete >NIL: T:pu_out#?"

PRINT
PRINT "Expected: 6 passed, 0 failed"
TkSummary
