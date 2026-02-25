REM test_path.b - Test path string manipulation functions
REM
REM Tests FadBaseName$, FadDirName$, FadExt$, FadReplaceExt$,
REM FadJoin$, and FadParent$.
REM These are pure string operations (no file I/O needed).

REM #using ace:submods/fad/fad.o
REM #using ace:submods/testkit/testkit.o
#include <submods/fad.h>
#include <submods/testkit.h>

PRINT "=== fad Path Manipulation Tests ==="

TkInit

{* --- FadBaseName$ tests --- *}

TkAssertEqStr(FadBaseName$("SYS:Utilities/More"), "More", "basename SYS:Utilities/More")
TkAssertEqStr(FadBaseName$("SYS:foo"), "foo", "basename SYS:foo")
TkAssertEqStr(FadBaseName$("foo/bar"), "bar", "basename foo/bar")
TkAssertEqStr(FadBaseName$("readme"), "readme", "basename readme")
TkAssertEqStr(FadBaseName$("SYS:"), "", "basename SYS: (empty)")

{* --- FadDirName$ tests --- *}

TkAssertEqStr(FadDirName$("SYS:Utilities/More"), "SYS:Utilities", "dirname SYS:Utilities/More")
TkAssertEqStr(FadDirName$("SYS:foo"), "SYS:", "dirname SYS:foo")
TkAssertEqStr(FadDirName$("SYS:"), "SYS:", "dirname SYS:")
TkAssertEqStr(FadDirName$("foo/bar"), "foo", "dirname foo/bar")
TkAssertEqStr(FadDirName$("readme"), "", "dirname readme (empty)")

{* --- FadExt$ tests --- *}

TkAssertEqStr(FadExt$("image.iff"), "iff", "ext image.iff")
TkAssertEqStr(FadExt$("README"), "", "ext README (no ext)")
TkAssertEqStr(FadExt$("archive.tar.gz"), "gz", "ext archive.tar.gz")
TkAssertEqStr(FadExt$("SYS:pics/photo.jpg"), "jpg", "ext SYS:pics/photo.jpg")

{* --- FadReplaceExt$ tests --- *}

TkAssertEqStr(FadReplaceExt$("image.iff", "jpg"), "image.jpg", "replaceext image.iff -> jpg")
TkAssertEqStr(FadReplaceExt$("README", "txt"), "README.txt", "replaceext README -> txt")

{* --- FadJoin$ tests --- *}

TkAssertEqStr(FadJoin$("SYS:Utilities", "More"), "SYS:Utilities/More", "join SYS:Utilities + More")
TkAssertEqStr(FadJoin$("SYS:", "Utilities"), "SYS:Utilities", "join SYS: + Utilities")

{* --- FadParent$ tests --- *}

TkAssertEqStr(FadParent$("SYS:Utilities/More"), "SYS:Utilities", "parent SYS:Utilities/More")
TkAssertEqStr(FadParent$("SYS:foo"), "SYS:", "parent SYS:foo")
TkAssertEqStr(FadParent$("SYS:"), "SYS:", "parent SYS: (root)")
TkAssertEqStr(FadParent$("foo/bar"), "foo", "parent foo/bar")
TkAssertEqStr(FadParent$("readme"), "", "parent readme (empty)")

{* --- Summary --- *}
TkSummary
