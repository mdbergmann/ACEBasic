IFF Picture Submodule
=====================

Load and display IFF ILBM/ACBM pictures from ACE BASIC programs.

This was formerly a built-in compiler feature (IFF OPEN/READ/CLOSE
statements and IFF() function). It has been extracted into a
standalone submodule so that programs which don't use IFF pictures
don't pay the cost of the embedded ilbm.library.


Requirements
------------
- ilbm.library must be installed in LIBS: on the target system.
  A copy is provided in this directory for convenience.
- When distributing your program, include ilbm.library and instruct
  users to copy it to LIBS: (or bundle an installer that does so).


Files
-----
  iff.b              Submodule source
  iff.o              Compiled module (compile with: bas -m iff)
  ilbm.library       Jeff Glatt's freeware ILBM library (6924 bytes)
  include/submods/iff.h   Header with DECLARE SUBs and error constants
  test_iff_info.b    Test: open IFF file and query dimensions
  test_iff_display.b Test: display an IFF picture (visual)


Usage
-----
Add to the top of your program:

  REM #using ACE:submods/iff/iff.o
  #include <submods/iff.h>

Or compile with the .o on the command line:

  bas myprogram ACE:submods/iff/iff.o


API
---

Lifecycle:

  IffInit            Open ilbm.library. Returns 0 on success,
                     IFF_ERR_LIB (-4) if library not found.
                     Must be called before any other Iff function.

  IffShutdown        Close all channels and libraries.

File operations:

  IffOpen(ch%, f$)   Open IFF file f$ on channel ch% (1-15).
                     Reads header info (form type, dimensions).
                     Returns 0 on success, negative on error.

  IffDisplay(ch%, s&)  Load and display the picture.
                     s& = 0: ilbm.library opens its own screen/window.
                     s& <> 0: use the given Screen pointer
                     (e.g. WINDOW(7) for the current ACE screen).
                     Returns 0 on success, negative on error.

  IffClose(ch%)      Close channel. If IffDisplay opened a screen/window
                     (when s& was 0), closes them too.

Query functions (call after IffOpen):

  IffWidth(ch%)      Picture width in pixels.
  IffHeight(ch%)     Picture height in pixels.
  IffDepth(ch%)      Number of bitplanes.
  IffScreenMode(ch%) Screen mode: 1=lores, 2=hires, 3=lores-lace,
                     4=hires-lace, 5=HAM.
  IffFormType(ch%)   Address of form name string ("ILBM" or "ACBM").

Error constants (defined in iff.h):

  IFF_OK        =  0   Success
  IFF_ERR_OPEN  = -1   Error opening file
  IFF_ERR_READ  = -2   Error reading file
  IFF_ERR_CHAN  = -3   Bad channel number
  IFF_ERR_LIB   = -4   Cannot open ilbm.library


Example
-------
See examples/gfx/IFF.b for a complete example that opens a file
requester, displays an IFF picture on a matching screen, and waits
for a keypress.

  REM #using ACE:submods/iff/iff.o
  #include <submods/iff.h>

  rc% = IffInit
  IF rc% < 0 THEN PRINT "No ilbm.library" : STOP

  rc% = IffOpen(1, "mypicture.iff")
  IF rc% = 0 THEN
    SCREEN 1, IffWidth(1), IffHeight(1), IffDepth(1), IffScreenMode(1)
    IffDisplay(1, WINDOW(7))
    WHILE INKEY$ = "" : SLEEP : WEND
    IffClose(1)
    SCREEN CLOSE 1
  END IF

  IffShutdown


Migration from built-in IFF
----------------------------
Old:                              New:
  (nothing)                         REM #using ACE:submods/iff/iff.o
                                    #include <submods/iff.h>
                                    IffInit
  IFF OPEN #1, f$                   rc% = IffOpen(1, f$)
  IF ERR THEN ...                   IF rc% < 0 THEN ...
  w = IFF(1, 1)                     w = IffWidth(1)
  h = IFF(1, 2)                     h = IffHeight(1)
  d = IFF(1, 3)                     d = IffDepth(1)
  m = IFF(1, 4)                     m = IffScreenMode(1)
  IFF READ #1, 1                    IffDisplay(1, WINDOW(7))
  IFF READ #1                       IffDisplay(1, 0)
  IFF CLOSE #1                      IffClose(1)
  (nothing)                         IffShutdown
