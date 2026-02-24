{*
** Header for fad - Files And Directories submodule
** Include this when using the fad submodule
**
** Wraps common AmigaDOS file system operations:
** - Existence and type checks (FadExists%, FadIsFile%, FadIsDir%)
** - File info without opening (FadSize&, FadProtect&, FadComment$, FadDate%)
** - Path manipulation (FadBaseName$, FadDirName$, FadExt$, FadJoin$, etc.)
** - Directory iteration (FadOpenDir%, FadNext%, FadEntryName$, etc.)
** - File operations (FadCopy&, FadMkDir&, FadMkDirP&, FadDeleteTree&)
**
** No init/cleanup calls required (dos.library is auto-opened by ACE).
**
** Usage:
**   #include <submods/fad.h>
**   ...
**   IF FadExists%("SYS:Utilities/More") THEN PRINT "found"
*}

{* ============== Error Query ============== *}

' FadError& - Returns the dos.library error code from the last fad call.
' 0 means success. Codes match dos.library (205 = object not found, etc.)
DECLARE SUB LONGINT FadError& EXTERNAL

{* ============== Existence & Type Checks ============== *}

' FadExists% - Returns -1 if anything (file or directory) exists at path.
DECLARE SUB SHORTINT FadExists%(path$) EXTERNAL

' FadIsFile% - Returns -1 only if path exists AND is a regular file.
DECLARE SUB SHORTINT FadIsFile%(path$) EXTERNAL

' FadIsDir% - Returns -1 only if path exists AND is a directory.
DECLARE SUB SHORTINT FadIsDir%(path$) EXTERNAL

{* ============== File Info ============== *}

' FadSize& - File size in bytes. Returns -1 if not found.
DECLARE SUB LONGINT FadSize&(path$) EXTERNAL

' FadProtect& - Protection bits (RWED). Returns -1 if not found.
DECLARE SUB LONGINT FadProtect&(path$) EXTERNAL

' FadComment$ - File comment string. Returns "" if none or not found.
DECLARE SUB STRING FadComment$(path$) EXTERNAL

' FadDate% - File date. After call, read FadDateDays&, FadDateMins&,
' FadDateTicks&. Returns -1 on success, 0 on failure.
DECLARE SUB SHORTINT FadDate%(path$) EXTERNAL

' Date component accessors (valid after successful FadDate% call)
DECLARE SUB LONGINT FadDateDays& EXTERNAL
DECLARE SUB LONGINT FadDateMins& EXTERNAL
DECLARE SUB LONGINT FadDateTicks& EXTERNAL

{* ============== Path Manipulation ============== *}

' FadBaseName$ - Extract filename: "SYS:Utilities/More" -> "More"
DECLARE SUB STRING FadBaseName$(path$) EXTERNAL

' FadDirName$ - Extract directory: "SYS:Utilities/More" -> "SYS:Utilities"
DECLARE SUB STRING FadDirName$(path$) EXTERNAL

' FadExt$ - Extract extension: "image.iff" -> "iff", "README" -> ""
DECLARE SUB STRING FadExt$(path$) EXTERNAL

' FadReplaceExt$ - Replace extension: "image.iff","jpg" -> "image.jpg"
DECLARE SUB STRING FadReplaceExt$(path$, ext$) EXTERNAL

' FadJoin$ - Join path components: "SYS:Utilities","More" -> "SYS:Utilities/More"
' Uses AmigaDOS AddPart for correct path handling.
DECLARE SUB STRING FadJoin$(base$, part$) EXTERNAL

' FadParent$ - Parent directory: "SYS:Utilities/More" -> "SYS:Utilities"
' Device root returns itself: "SYS:" -> "SYS:"
DECLARE SUB STRING FadParent$(path$) EXTERNAL

{* ============== Directory Iteration ============== *}

' FadOpenDir% - Open directory for iteration. Returns -1 on success.
' Only one directory can be iterated at a time.
DECLARE SUB SHORTINT FadOpenDir%(path$) EXTERNAL

' FadNext% - Advance to next entry. Returns -1 if entry available, 0 when done.
DECLARE SUB SHORTINT FadNext% EXTERNAL

' Entry accessors (valid after FadNext% returns -1)
DECLARE SUB STRING FadEntryName$ EXTERNAL
DECLARE SUB LONGINT FadEntrySize& EXTERNAL
DECLARE SUB SHORTINT FadEntryIsDir% EXTERNAL
DECLARE SUB LONGINT FadEntryProtect& EXTERNAL
DECLARE SUB LONGINT FadEntryDays& EXTERNAL
DECLARE SUB LONGINT FadEntryMins& EXTERNAL
DECLARE SUB LONGINT FadEntryTicks& EXTERNAL

' FadCloseDir - Close directory. Frees lock and internal buffer.
' Safe to call even if iteration ended naturally.
DECLARE SUB FadCloseDir EXTERNAL

{* ============== File Operations ============== *}

' FadCopy& - Copy file. Returns 0 on success, dos error code on failure.
DECLARE SUB LONGINT FadCopy&(src$, dst$) EXTERNAL

' FadMkDir& - Create single directory. Returns 0 on success, dos error on failure.
DECLARE SUB LONGINT FadMkDir&(path$) EXTERNAL

' FadMkDirP& - Create directory and all missing parents.
' Returns 0 on success, dos error code on failure.
DECLARE SUB LONGINT FadMkDirP&(path$) EXTERNAL

' FadDeleteTree& - Recursively delete directory and all contents.
' Returns 0 on success, dos error code on failure.
' WARNING: Dangerous! No confirmation prompt.
DECLARE SUB LONGINT FadDeleteTree&(path$) EXTERNAL
