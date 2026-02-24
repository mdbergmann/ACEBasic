REM test_path.b - Test path string manipulation functions
REM
REM Tests FadBaseName$, FadDirName$, FadExt$, FadReplaceExt$,
REM FadJoin$, and FadParent$.
REM These are pure string operations (no file I/O needed).

REM #using ace:submods/fad/fad.o
#include <submods/fad.h>

LONGINT passed, failed
passed = 0
failed = 0

PRINT "=== fad Path Manipulation Tests ==="

{* --- FadBaseName$ tests --- *}

IF FadBaseName$("SYS:Utilities/More") = "More" THEN
  PRINT "PASS: basename SYS:Utilities/More"
  passed = passed + 1
ELSE
  PRINT "FAIL: basename SYS:Utilities/More, got: "; FadBaseName$("SYS:Utilities/More")
  failed = failed + 1
END IF

IF FadBaseName$("SYS:foo") = "foo" THEN
  PRINT "PASS: basename SYS:foo"
  passed = passed + 1
ELSE
  PRINT "FAIL: basename SYS:foo, got: "; FadBaseName$("SYS:foo")
  failed = failed + 1
END IF

IF FadBaseName$("foo/bar") = "bar" THEN
  PRINT "PASS: basename foo/bar"
  passed = passed + 1
ELSE
  PRINT "FAIL: basename foo/bar, got: "; FadBaseName$("foo/bar")
  failed = failed + 1
END IF

IF FadBaseName$("readme") = "readme" THEN
  PRINT "PASS: basename readme"
  passed = passed + 1
ELSE
  PRINT "FAIL: basename readme, got: "; FadBaseName$("readme")
  failed = failed + 1
END IF

IF FadBaseName$("SYS:") = "" THEN
  PRINT "PASS: basename SYS: (empty)"
  passed = passed + 1
ELSE
  PRINT "FAIL: basename SYS:, got: "; FadBaseName$("SYS:")
  failed = failed + 1
END IF

{* --- FadDirName$ tests --- *}

IF FadDirName$("SYS:Utilities/More") = "SYS:Utilities" THEN
  PRINT "PASS: dirname SYS:Utilities/More"
  passed = passed + 1
ELSE
  PRINT "FAIL: dirname SYS:Utilities/More, got: "; FadDirName$("SYS:Utilities/More")
  failed = failed + 1
END IF

IF FadDirName$("SYS:foo") = "SYS:" THEN
  PRINT "PASS: dirname SYS:foo"
  passed = passed + 1
ELSE
  PRINT "FAIL: dirname SYS:foo, got: "; FadDirName$("SYS:foo")
  failed = failed + 1
END IF

IF FadDirName$("SYS:") = "SYS:" THEN
  PRINT "PASS: dirname SYS:"
  passed = passed + 1
ELSE
  PRINT "FAIL: dirname SYS:, got: "; FadDirName$("SYS:")
  failed = failed + 1
END IF

IF FadDirName$("foo/bar") = "foo" THEN
  PRINT "PASS: dirname foo/bar"
  passed = passed + 1
ELSE
  PRINT "FAIL: dirname foo/bar, got: "; FadDirName$("foo/bar")
  failed = failed + 1
END IF

IF FadDirName$("readme") = "" THEN
  PRINT "PASS: dirname readme (empty)"
  passed = passed + 1
ELSE
  PRINT "FAIL: dirname readme, got: "; FadDirName$("readme")
  failed = failed + 1
END IF

{* --- FadExt$ tests --- *}

IF FadExt$("image.iff") = "iff" THEN
  PRINT "PASS: ext image.iff"
  passed = passed + 1
ELSE
  PRINT "FAIL: ext image.iff, got: "; FadExt$("image.iff")
  failed = failed + 1
END IF

IF FadExt$("README") = "" THEN
  PRINT "PASS: ext README (no ext)"
  passed = passed + 1
ELSE
  PRINT "FAIL: ext README, got: "; FadExt$("README")
  failed = failed + 1
END IF

IF FadExt$("archive.tar.gz") = "gz" THEN
  PRINT "PASS: ext archive.tar.gz"
  passed = passed + 1
ELSE
  PRINT "FAIL: ext archive.tar.gz, got: "; FadExt$("archive.tar.gz")
  failed = failed + 1
END IF

IF FadExt$("SYS:pics/photo.jpg") = "jpg" THEN
  PRINT "PASS: ext SYS:pics/photo.jpg"
  passed = passed + 1
ELSE
  PRINT "FAIL: ext SYS:pics/photo.jpg, got: "; FadExt$("SYS:pics/photo.jpg")
  failed = failed + 1
END IF

{* --- FadReplaceExt$ tests --- *}

IF FadReplaceExt$("image.iff", "jpg") = "image.jpg" THEN
  PRINT "PASS: replaceext image.iff -> jpg"
  passed = passed + 1
ELSE
  PRINT "FAIL: replaceext image.iff, got: "; FadReplaceExt$("image.iff", "jpg")
  failed = failed + 1
END IF

IF FadReplaceExt$("README", "txt") = "README.txt" THEN
  PRINT "PASS: replaceext README -> txt"
  passed = passed + 1
ELSE
  PRINT "FAIL: replaceext README, got: "; FadReplaceExt$("README", "txt")
  failed = failed + 1
END IF

{* --- FadJoin$ tests --- *}

IF FadJoin$("SYS:Utilities", "More") = "SYS:Utilities/More" THEN
  PRINT "PASS: join SYS:Utilities + More"
  passed = passed + 1
ELSE
  PRINT "FAIL: join SYS:Utilities + More, got: "; FadJoin$("SYS:Utilities", "More")
  failed = failed + 1
END IF

IF FadJoin$("SYS:", "Utilities") = "SYS:Utilities" THEN
  PRINT "PASS: join SYS: + Utilities"
  passed = passed + 1
ELSE
  PRINT "FAIL: join SYS: + Utilities, got: "; FadJoin$("SYS:", "Utilities")
  failed = failed + 1
END IF

{* --- FadParent$ tests --- *}

IF FadParent$("SYS:Utilities/More") = "SYS:Utilities" THEN
  PRINT "PASS: parent SYS:Utilities/More"
  passed = passed + 1
ELSE
  PRINT "FAIL: parent SYS:Utilities/More, got: "; FadParent$("SYS:Utilities/More")
  failed = failed + 1
END IF

IF FadParent$("SYS:foo") = "SYS:" THEN
  PRINT "PASS: parent SYS:foo"
  passed = passed + 1
ELSE
  PRINT "FAIL: parent SYS:foo, got: "; FadParent$("SYS:foo")
  failed = failed + 1
END IF

IF FadParent$("SYS:") = "SYS:" THEN
  PRINT "PASS: parent SYS: (root)"
  passed = passed + 1
ELSE
  PRINT "FAIL: parent SYS:, got: "; FadParent$("SYS:")
  failed = failed + 1
END IF

IF FadParent$("foo/bar") = "foo" THEN
  PRINT "PASS: parent foo/bar"
  passed = passed + 1
ELSE
  PRINT "FAIL: parent foo/bar, got: "; FadParent$("foo/bar")
  failed = failed + 1
END IF

IF FadParent$("readme") = "" THEN
  PRINT "PASS: parent readme (empty)"
  passed = passed + 1
ELSE
  PRINT "FAIL: parent readme, got: "; FadParent$("readme")
  failed = failed + 1
END IF

{* --- Summary --- *}
PRINT ""
PRINT "Results:"; passed; "passed,"; failed; "failed"

ASSERT failed = 0, "Some path tests failed"
