REM test_ops.b - Test file operation functions
REM
REM Tests FadCopy&, FadMkDir&, FadMkDirP&, FadDeleteTree&.
REM Uses RAM: for temp files (fast, no disk I/O).

REM #using ace:submods/fad/fad.o
REM #using ace:submods/testkit/testkit.o
#include <submods/fad.h>
#include <submods/testkit.h>

LONGINT rc

PRINT "=== fad File Operations Tests ==="

TkInit

{* --- Setup: create a source file --- *}

OPEN "O", #1, "RAM:fadtest_src.tmp"
PRINT #1, "copy test data line 1"
PRINT #1, "copy test data line 2"
CLOSE #1

{* --- FadCopy& test --- *}

rc = FadCopy&("RAM:fadtest_src.tmp", "RAM:fadtest_dst.tmp")
TkAssertEq&(rc, 0, "FadCopy& returned 0")

' Verify copied file exists and has same size
TkAssertTrue(FadExists%("RAM:fadtest_dst.tmp"), "copied file exists")

LONGINT srcSz, dstSz
srcSz = FadSize&("RAM:fadtest_src.tmp")
dstSz = FadSize&("RAM:fadtest_dst.tmp")
TkAssertEq&(srcSz, dstSz, "sizes match")

' Test copy of nonexistent source
rc = FadCopy&("RAM:nonexistent_xyz", "RAM:fadtest_bad.tmp")
TkAssertTrue(rc <> 0, "FadCopy& fails for missing source")

{* --- FadMkDir& test --- *}

rc = FadMkDir&("RAM:fadtest_mkdir")
TkAssertEq&(rc, 0, "FadMkDir& created directory")
TkAssertTrue(FadIsDir%("RAM:fadtest_mkdir"), "created dir is a directory")

{* --- FadMkDirP& test --- *}

rc = FadMkDirP&("RAM:fadtest_nested/level1/level2")
TkAssertEq&(rc, 0, "FadMkDirP& created nested dirs")
TkAssertTrue(FadIsDir%("RAM:fadtest_nested/level1/level2"), "nested dir exists")
TkAssertTrue(FadIsDir%("RAM:fadtest_nested/level1"), "intermediate dir exists")

{* --- FadDeleteTree& test --- *}

' Create some files inside the nested structure
OPEN "O", #1, "RAM:fadtest_nested/level1/level2/testfile.txt"
PRINT #1, "deep file"
CLOSE #1

OPEN "O", #1, "RAM:fadtest_nested/level1/another.txt"
PRINT #1, "another file"
CLOSE #1

rc = FadDeleteTree&("RAM:fadtest_nested")
TkAssertEq&(rc, 0, "FadDeleteTree& succeeded")
TkAssertTrue(NOT FadExists%("RAM:fadtest_nested"), "tree fully deleted")

{* --- Cleanup --- *}

KILL "RAM:fadtest_src.tmp"
KILL "RAM:fadtest_dst.tmp"
SYSTEM "delete RAM:fadtest_mkdir ALL QUIET"

{* --- Summary --- *}
TkSummary
