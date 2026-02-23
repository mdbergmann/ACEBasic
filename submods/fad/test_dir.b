REM test_dir.b - Test directory iteration functions
REM
REM Tests FadOpenDir%, FadNext%, FadEntryName$, FadEntrySize&,
REM FadEntryIsDir%, FadCloseDir.
REM Creates a temp directory in RAM: with known contents.

REM #using ace:submods/fad/fad.o
#include <submods/fad.h>
EXTERNAL fad

LONGINT passed, failed
LONGINT entryCount, fileCount, dirCount
passed = 0
failed = 0

PRINT "=== fad Directory Iteration Tests ==="

{* --- Setup: create test directory structure in RAM: --- *}

' Create directory (using MKDIR via shell)
SHELL "makedir RAM:fadtest_dir"

' Create two files
OPEN "O", #1, "RAM:fadtest_dir/file1.txt"
PRINT #1, "first"
CLOSE #1

OPEN "O", #1, "RAM:fadtest_dir/file2.txt"
PRINT #1, "second file content"
CLOSE #1

' Create a subdirectory
SHELL "makedir RAM:fadtest_dir/subdir"

{* --- FadOpenDir% test --- *}

IF FadOpenDir%("RAM:fadtest_dir") THEN
  PRINT "PASS: FadOpenDir% success"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadOpenDir% failed, error:"; FadError&
  failed = failed + 1
END IF

{* --- FadNext% iteration test --- *}

entryCount = 0
fileCount = 0
dirCount = 0

WHILE FadNext%
  entryCount = entryCount + 1
  PRINT "  Entry: "; FadEntryName$;
  IF FadEntryIsDir% THEN
    PRINT " [DIR]"
    dirCount = dirCount + 1
  ELSE
    PRINT " size="; FadEntrySize&
    fileCount = fileCount + 1
  END IF
WEND

FadCloseDir

' We created 2 files + 1 subdirectory = 3 entries
IF entryCount = 3 THEN
  PRINT "PASS: found 3 entries"
  passed = passed + 1
ELSE
  PRINT "FAIL: expected 3 entries, found"; entryCount
  failed = failed + 1
END IF

IF fileCount = 2 THEN
  PRINT "PASS: found 2 files"
  passed = passed + 1
ELSE
  PRINT "FAIL: expected 2 files, found"; fileCount
  failed = failed + 1
END IF

IF dirCount = 1 THEN
  PRINT "PASS: found 1 directory"
  passed = passed + 1
ELSE
  PRINT "FAIL: expected 1 directory, found"; dirCount
  failed = failed + 1
END IF

{* --- FadOpenDir% on nonexistent path --- *}

IF NOT FadOpenDir%("RAM:nonexistent_dir_xyz") THEN
  PRINT "PASS: FadOpenDir% fails for nonexistent"
  passed = passed + 1
ELSE
  PRINT "FAIL: FadOpenDir% succeeded for nonexistent"
  FadCloseDir
  failed = failed + 1
END IF

{* --- Double close is safe --- *}

FadCloseDir
PRINT "PASS: double FadCloseDir is safe"
passed = passed + 1

{* --- Cleanup --- *}

KILL "RAM:fadtest_dir/file1.txt"
KILL "RAM:fadtest_dir/file2.txt"
SHELL "delete RAM:fadtest_dir/subdir ALL QUIET"
SHELL "delete RAM:fadtest_dir ALL QUIET"

{* --- Summary --- *}
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

ASSERT failed = 0, "Some dir tests failed"
