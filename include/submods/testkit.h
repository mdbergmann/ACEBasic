#ifndef TESTKIT_H
#define TESTKIT_H

REM testkit.h - shared test assertion library
REM
REM Usage:
REM   REM #using ace:submods/testkit/testkit.o
REM   #include <submods/testkit.h>

DECLARE SUB TkInit EXTERNAL
DECLARE SUB TkSummary EXTERNAL
DECLARE SUB TkAssertTrue(SHORTINT condition, msg$) EXTERNAL
DECLARE SUB TkAssertFalse(SHORTINT condition, msg$) EXTERNAL
DECLARE SUB TkAssertEq%(SHORTINT actual, SHORTINT expected, msg$) EXTERNAL
DECLARE SUB TkAssertEq&(LONGINT actual, LONGINT expected, msg$) EXTERNAL
DECLARE SUB TkAssertEqAddr(ADDRESS actual, ADDRESS expected, msg$) EXTERNAL
DECLARE SUB TkAssertEqStr(actual$, expected$, msg$) EXTERNAL
DECLARE SUB TkAssertEqFloat(SINGLE actual, SINGLE expected, msg$) EXTERNAL
DECLARE SUB TkAssertNeq&(LONGINT actual, LONGINT notExpected, msg$) EXTERNAL
DECLARE SUB TkAssertNeqAddr(ADDRESS actual, ADDRESS notExpected, msg$) EXTERNAL

#endif
