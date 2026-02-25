REM test_dir.b - Test directory iteration functions
REM
REM Tests FadOpenDir%, FadNext%, FadEntryName$, FadEntrySize&,
REM FadEntryIsDir%, FadCloseDir.
REM Creates a temp directory in RAM: with known contents.

REM #using ace:submods/fad/fad.o
REM #using ace:submods/testkit/testkit.o
#include <submods/fad.h>
#include <submods/testkit.h>

LONGINT entryCount, fileCount, dirCount

PRINT "=== fad Directory Iteration Tests ==="

TkInit

{* --- Setup: create test directory structure in RAM: --- *}

' Create directory (using MKDIR via shell)
SYSTEM "makedir RAM:fadtest_dir"

' Create two files
OPEN "O", #1, "RAM:fadtest_dir/file1.txt"
PRINT #1, "first"
CLOSE #1

OPEN "O", #1, "RAM:fadtest_dir/file2.txt"
PRINT #1, "second file content"
CLOSE #1

' Create a subdirectory
SYSTEM "makedir RAM:fadtest_dir/subdir"

{* --- FadOpenDir% test --- *}

TkAssertTrue(FadOpenDir%("RAM:fadtest_dir"), "FadOpenDir% success")

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
TkAssertEq&(entryCount, 3, "found 3 entries")
TkAssertEq&(fileCount, 2, "found 2 files")
TkAssertEq&(dirCount, 1, "found 1 directory")

{* --- FadOpenDir% on nonexistent path --- *}

TkAssertTrue(NOT FadOpenDir%("RAM:nonexistent_dir_xyz"), "FadOpenDir% fails for nonexistent")

{* --- Double close is safe --- *}

FadCloseDir
TkAssertTrue(-1, "double FadCloseDir is safe")

{* --- Cleanup --- *}

KILL "RAM:fadtest_dir/file1.txt"
KILL "RAM:fadtest_dir/file2.txt"
SYSTEM "delete RAM:fadtest_dir/subdir ALL QUIET"
SYSTEM "delete RAM:fadtest_dir ALL QUIET"

{* --- Summary --- *}
TkSummary
