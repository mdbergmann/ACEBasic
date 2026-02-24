fad - Files And Directories
===========================

A submodule for ACE BASIC that wraps common AmigaDOS file system
operations into simple SUB calls. Inspired by CL-FAD (Common Lisp
Files And Directories library) but adapted to ACE BASIC idioms.


Quick Start
-----------

  #include <submods/fad.h>

  ' Check if a file exists
  IF FadExists%("SYS:Utilities/More") THEN
    PRINT "More exists, size:"; FadSize&("SYS:Utilities/More")
  END IF

  ' List a directory
  IF FadOpenDir%("SYS:Utilities") THEN
    WHILE FadNext%
      IF FadEntryIsDir% THEN
        PRINT "[DIR] ";
      ELSE
        PRINT FadEntrySize&; " ";
      END IF
      PRINT FadEntryName$
    WEND
    FadCloseDir
  END IF


Setup
-----

No initialization needed. All functions use dos.library which ACE
opens automatically. Just include the header and link the module:

  REM #using ace:submods/fad/fad.o
  #include <submods/fad.h>

Build the module from the submods/fad/ directory:

  execute make


API Reference
-------------

ERROR QUERY:

  FadError&            Last dos.library error (0 = success)

EXISTENCE & TYPE CHECKS (return -1 true, 0 false):

  FadExists%(path$)    Anything exists at path?
  FadIsFile%(path$)    Exists and is a file?
  FadIsDir%(path$)     Exists and is a directory?

FILE INFO (without opening):

  FadSize&(path$)      Size in bytes (-1 if not found)
  FadProtect&(path$)   Protection bits (-1 if not found)
  FadComment$(path$)   File comment ("" if none)
  FadDate%(path$)      Get date (-1 success, 0 failure)
  FadDateDays&         Days since Jan 1, 1978
  FadDateMins&         Minutes past midnight
  FadDateTicks&        Ticks past minute (50 per second)

PATH MANIPULATION:

  FadBaseName$(path$)           Filename: "SYS:Utils/More" -> "More"
  FadDirName$(path$)            Directory: "SYS:Utils/More" -> "SYS:Utils"
  FadExt$(path$)                Extension: "photo.jpg" -> "jpg"
  FadReplaceExt$(path$, ext$)   "photo.jpg","png" -> "photo.png"
  FadJoin$(base$, part$)        "SYS:Utils","More" -> "SYS:Utils/More"
  FadParent$(path$)             "SYS:Utils/More" -> "SYS:Utils"

DIRECTORY ITERATION:

  FadOpenDir%(path$)   Open for iteration (-1 success)
  FadNext%             Next entry (-1 available, 0 done)
  FadEntryName$        Current entry name
  FadEntrySize&        Current entry size
  FadEntryIsDir%       Current entry is directory?
  FadEntryProtect&     Current entry protection bits
  FadEntryDays&        Current entry date (days)
  FadEntryMins&        Current entry date (mins)
  FadEntryTicks&       Current entry date (ticks)
  FadCloseDir          Close (safe to call anytime)

  Note: Only one directory can be iterated at a time.

FILE OPERATIONS (return 0 on success, dos error on failure):

  FadCopy&(src$, dst$)       Copy file
  FadMkDir&(path$)           Create single directory
  FadMkDirP&(path$)          Create directory and parents
  FadDeleteTree&(path$)      Delete directory tree (DANGER!)


Error Handling
--------------

All functions set an internal error code accessible via FadError&.
After any call, check FadError& for the dos.library error code.
0 means success. Common codes:

  103  No free store (out of memory)
  205  Object not found
  210  Object is in use
  212  Object is not of required type
  216  Directory not empty
  225  Object is not a directory


Dependencies
------------

- dos.library (auto-opened by ACE, no explicit LIBRARY call needed)
- No other submodule dependencies


License
-------

Same as ACE BASIC.
