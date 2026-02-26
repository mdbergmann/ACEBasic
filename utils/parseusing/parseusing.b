REM parseusing - Scan source file for link directives
REM
REM Usage: parseusing <sourcefile> <outputfile>
REM
REM Scans the first 20 lines of a BASIC source file for
REM "REM [hash]using path" directives and writes the paths
REM space-separated to outputfile.
REM Replaces the ARexx script bin/parseUsing.rexx.

DEFINT a-z

STRING fname$ SIZE 256
STRING outName$ SIZE 256
STRING ln$ SIZE 256
STRING uln$ SIZE 256
STRING pathStr$ SIZE 256

IF ARGCOUNT < 2 THEN
  PRINT "Usage: parseusing <sourcefile> <outputfile>"
  SYSTEM 10
END IF

fname$ = ARG$(1)
outName$ = ARG$(2)

OPEN "I",#1,fname$
IF HANDLE(1) = 0 THEN
  REM File can't be opened - write empty output file
  OPEN "O",#2,outName$
  CLOSE #2
  SYSTEM 0
END IF

REM Open output file
OPEN "O",#2,outName$

count = 0
lineNum = 0

WHILE lineNum < 20 AND NOT EOF(1)
  LINE INPUT #1, ln$
  lineNum = lineNum + 1

  uln$ = UCASE$(ln$)

  REM Look for #USING directive (case-insensitive)
  p = INSTR(uln$, "#USING")
  IF p > 0 THEN
    REM Extract path after #using (6 chars)
    pathStr$ = LTRIM$(MID$(ln$, p + 6))
    IF LEN(pathStr$) > 0 THEN
      IF count > 0 THEN PRINT #2, " ";
      PRINT #2, pathStr$;
      count = count + 1
    END IF
  END IF
WEND

REM No trailing newline needed - type/SET handles it

CLOSE #1
CLOSE #2

SYSTEM 0
