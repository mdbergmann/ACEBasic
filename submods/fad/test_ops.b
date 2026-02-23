REM test_ops.b - Test file operation functions
REM
REM Tests FadCopy&, FadMkDir&, FadMkDirP&, FadDeleteTree&.
REM Uses RAM: for temp files (fast, no disk I/O).

REM #using ace:submods/fad/fad.o
#include <submods/fad.h>
EXTERNAL fad

LONGINT passed, failed, rc
passed = 0
failed = 0

PRINT "=== fad File Operations Tests ==="

{* --- Setup: create a source file --- *}

OPEN "O", #1, "RAM:fadtest_src.tmp"
PRINT #1, "copy test data line 1"
PRINT #1, "copy test data line 2"
CLOSE #1

{* --- FadCopy& test --- *}

rc = FadCopy&("RAM:fadtest_src.tmp", "RAM:fadtest_dst.tmp")
IF rc = 0 THEN
  PRINT "PASS: FadCopy& returned 0"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadCopy& returned"; rc
  failed = failed + 1
END IF

' Verify copied file exists and has same size
IF FadExists%("RAM:fadtest_dst.tmp") THEN
  PRINT "PASS: copied file exists"
  passed = passed + 1
ELSE
  PRINT "FAIL: copied file does not exist"
  failed = failed + 1
END IF

LONGINT srcSz, dstSz
srcSz = FadSize&("RAM:fadtest_src.tmp")
dstSz = FadSize&("RAM:fadtest_dst.tmp")
IF srcSz = dstSz THEN
  PRINT "PASS: sizes match ("; srcSz; ")"
  passed = passed + 1
ELSE
  PRINT "FAIL: sizes differ, src="; srcSz; " dst="; dstSz
  failed = failed + 1
END IF

' Test copy of nonexistent source
rc = FadCopy&("RAM:nonexistent_xyz", "RAM:fadtest_bad.tmp")
IF rc <> 0 THEN
  PRINT "PASS: FadCopy& fails for missing source"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadCopy& succeeded for missing source"
  failed = failed + 1
END IF

{* --- FadMkDir& test --- *}

rc = FadMkDir&("RAM:fadtest_mkdir")
IF rc = 0 THEN
  PRINT "PASS: FadMkDir& created directory"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadMkDir& returned"; rc
  failed = failed + 1
END IF

IF FadIsDir%("RAM:fadtest_mkdir") THEN
  PRINT "PASS: created dir is a directory"
  passed = passed + 1
ELSE
  PRINT "FAIL: created dir not recognized as directory"
  failed = failed + 1
END IF

{* --- FadMkDirP& test --- *}

rc = FadMkDirP&("RAM:fadtest_nested/level1/level2")
IF rc = 0 THEN
  PRINT "PASS: FadMkDirP& created nested dirs"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadMkDirP& returned"; rc
  failed = failed + 1
END IF

IF FadIsDir%("RAM:fadtest_nested/level1/level2") THEN
  PRINT "PASS: nested dir exists"
  passed = passed + 1
ELSE
  PRINT "FAIL: nested dir not found"
  failed = failed + 1
END IF

IF FadIsDir%("RAM:fadtest_nested/level1") THEN
  PRINT "PASS: intermediate dir exists"
  passed = passed + 1
ELSE
  PRINT "FAIL: intermediate dir not found"
  failed = failed + 1
END IF

{* --- FadDeleteTree& test --- *}

' Create some files inside the nested structure
OPEN "O", #1, "RAM:fadtest_nested/level1/level2/testfile.txt"
PRINT #1, "deep file"
CLOSE #1

OPEN "O", #1, "RAM:fadtest_nested/level1/another.txt"
PRINT #1, "another file"
CLOSE #1

rc = FadDeleteTree&("RAM:fadtest_nested")
IF rc = 0 THEN
  PRINT "PASS: FadDeleteTree& succeeded"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadDeleteTree& returned"; rc
  failed = failed + 1
END IF

IF NOT FadExists%("RAM:fadtest_nested") THEN
  PRINT "PASS: tree fully deleted"
  passed = passed + 1
ELSE
  PRINT "FAIL: tree still exists after delete"
  failed = failed + 1
END IF

{* --- Cleanup --- *}

KILL "RAM:fadtest_src.tmp"
KILL "RAM:fadtest_dst.tmp"
SHELL "delete RAM:fadtest_mkdir ALL QUIET"

{* --- Summary --- *}
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

ASSERT failed = 0, "Some ops tests failed"
