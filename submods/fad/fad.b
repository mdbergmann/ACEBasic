{*
** fad - Files And Directories submodule for ACE BASIC
**
** Wraps common AmigaDOS file system operations into simple SUB calls.
** Inspired by CL-FAD (Common Lisp Files And Directories library).
**
** Dependencies: dos.library (auto-opened by ACE)
** No init/cleanup calls required.
*}

{* ============== Constants ============== *}

CONST _FAD_ACCESS_READ = -2&
CONST _FAD_MODE_OLDFILE = 1005&
CONST _FAD_MODE_NEWFILE = 1006&
CONST _FAD_COPY_BUFSZ = 4096&
CONST _FAD_PATHBUF_SZ = 256&

{* ============== Structure Definitions ============== *}

STRUCT _FadFIB
  LONGINT fib_DiskKey
  LONGINT fib_DirEntryType
  STRING  fib_FileName SIZE 108
  LONGINT fib_Protection
  LONGINT fib_EntryType
  LONGINT fib_Size
  LONGINT fib_NumBlocks
  STRING  fib_Date SIZE 12
  STRING  fib_Comment SIZE 80
  STRING  fib_Reserved SIZE 36
END STRUCT

STRUCT _FadDateStamp
  LONGINT ds_Days
  LONGINT ds_Mins
  LONGINT ds_Ticks
END STRUCT

{* ============== DOS Library Function Declarations ============== *}

DECLARE FUNCTION LONGINT Lock(STRING nm, LONGINT accessMode) LIBRARY dos
DECLARE FUNCTION UnLock(LONGINT lk) LIBRARY dos
DECLARE FUNCTION LONGINT Examine(LONGINT lk, ADDRESS fib) LIBRARY dos
DECLARE FUNCTION LONGINT ExNext(LONGINT lk, ADDRESS fib) LIBRARY dos
DECLARE FUNCTION LONGINT CreateDir(STRING nm) LIBRARY dos
DECLARE FUNCTION LONGINT DeleteFile(STRING nm) LIBRARY dos
DECLARE FUNCTION LONGINT Rename(STRING oldNm, STRING newNm) LIBRARY dos
DECLARE FUNCTION ADDRESS FilePart(STRING pth) LIBRARY dos
DECLARE FUNCTION ADDRESS PathPart(STRING pth) LIBRARY dos
DECLARE FUNCTION LONGINT AddPart(ADDRESS dirname, STRING filename, LONGINT sz) LIBRARY dos
DECLARE FUNCTION LONGINT NameFromLock(LONGINT lk, ADDRESS buf, LONGINT bufLen) LIBRARY dos
DECLARE FUNCTION LONGINT IoErr LIBRARY dos
DECLARE FUNCTION LONGINT _Open(STRING nm, LONGINT accessMode) LIBRARY dos
DECLARE FUNCTION _Close(LONGINT fh) LIBRARY dos
DECLARE FUNCTION LONGINT _Read(LONGINT fh, ADDRESS buf, LONGINT bufLen) LIBRARY dos
DECLARE FUNCTION LONGINT _Write(LONGINT fh, ADDRESS buf, LONGINT bufLen) LIBRARY dos

{* ============== Module-Level State ============== *}

LONGINT _fad_err
LONGINT _fad_dirlock
ADDRESS _fad_fib
STRING  _fad_ename
LONGINT _fad_esize
LONGINT _fad_etype
LONGINT _fad_eprot
LONGINT _fad_edays
LONGINT _fad_emins
LONGINT _fad_eticks
LONGINT _fad_datedays
LONGINT _fad_datemins
LONGINT _fad_dateticks

{* ============== Forward Declarations ============== *}

DECLARE SUB LONGINT FadDeleteTree&(path$)

{* ============== Internal Helpers ============== *}

SUB _FadCopyToBuf(ADDRESS buf, STRING s$, LONGINT maxLen)
  LONGINT i, L
  L = LEN(s$)
  IF L >= maxLen THEN L = maxLen - 1
  FOR i = 1 TO L
    POKE buf + i - 1, ASC(MID$(s$, i, 1))
  NEXT i
  POKE buf + L, 0
END SUB

{* ============== Error Query ============== *}

SUB LONGINT FadError& EXTERNAL
  SHARED _fad_err
  FadError& = _fad_err
END SUB

{* ============== Existence & Type Checks ============== *}

SUB SHORTINT FadExists%(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    UnLock(lk)
    FadExists% = -1
  ELSE
    _fad_err = IoErr
    FadExists% = 0
  END IF
END SUB

SUB SHORTINT FadIsFile%(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  DECLARE STRUCT _FadFIB info
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    Examine(lk, info)
    UnLock(lk)
    IF info->fib_DirEntryType < 0 THEN
      FadIsFile% = -1
    ELSE
      FadIsFile% = 0
    END IF
  ELSE
    _fad_err = IoErr
    FadIsFile% = 0
  END IF
END SUB

SUB SHORTINT FadIsDir%(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  DECLARE STRUCT _FadFIB info
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    Examine(lk, info)
    UnLock(lk)
    IF info->fib_DirEntryType > 0 THEN
      FadIsDir% = -1
    ELSE
      FadIsDir% = 0
    END IF
  ELSE
    _fad_err = IoErr
    FadIsDir% = 0
  END IF
END SUB

{* ============== File Info ============== *}

SUB LONGINT FadSize&(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  DECLARE STRUCT _FadFIB info
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    Examine(lk, info)
    UnLock(lk)
    FadSize& = info->fib_Size
  ELSE
    _fad_err = IoErr
    FadSize& = -1
  END IF
END SUB

SUB LONGINT FadProtect&(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  DECLARE STRUCT _FadFIB info
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    Examine(lk, info)
    UnLock(lk)
    FadProtect& = info->fib_Protection
  ELSE
    _fad_err = IoErr
    FadProtect& = -1
  END IF
END SUB

SUB STRING FadComment$(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  DECLARE STRUCT _FadFIB info
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    Examine(lk, info)
    UnLock(lk)
    FadComment$ = info->fib_Comment
  ELSE
    _fad_err = IoErr
    FadComment$ = ""
  END IF
END SUB

SUB SHORTINT FadDate%(path$) EXTERNAL
  SHARED _fad_err, _fad_datedays, _fad_datemins, _fad_dateticks
  LONGINT lk
  DECLARE STRUCT _FadFIB info
  DECLARE STRUCT _FadDateStamp *ds
  _fad_err = 0
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk <> 0 THEN
    Examine(lk, info)
    UnLock(lk)
    ds = @info->fib_Date
    _fad_datedays = ds->ds_Days
    _fad_datemins = ds->ds_Mins
    _fad_dateticks = ds->ds_Ticks
    FadDate% = -1
  ELSE
    _fad_err = IoErr
    FadDate% = 0
  END IF
END SUB

SUB LONGINT FadDateDays& EXTERNAL
  SHARED _fad_datedays
  FadDateDays& = _fad_datedays
END SUB

SUB LONGINT FadDateMins& EXTERNAL
  SHARED _fad_datemins
  FadDateMins& = _fad_datemins
END SUB

SUB LONGINT FadDateTicks& EXTERNAL
  SHARED _fad_dateticks
  FadDateTicks& = _fad_dateticks
END SUB

{* ============== Path Manipulation ============== *}

SUB STRING FadBaseName$(path$) EXTERNAL
  ADDRESS fp
  fp = FilePart(path$)
  IF fp <> 0 THEN
    FadBaseName$ = CSTR(fp)
  ELSE
    FadBaseName$ = ""
  END IF
END SUB

SUB STRING FadDirName$(path$) EXTERNAL
  LONGINT i, lastSep, L
  STRING p$

  ' Strip trailing /
  p$ = path$
  L = LEN(p$)
  IF L > 1 AND RIGHT$(p$, 1) = "/" THEN
    p$ = LEFT$(p$, L - 1)
    L = L - 1
  END IF

  ' Find last : or /
  lastSep = 0
  FOR i = 1 TO L
    IF MID$(p$, i, 1) = ":" OR MID$(p$, i, 1) = "/" THEN lastSep = i
  NEXT i

  IF lastSep = 0 THEN
    FadDirName$ = ""
  ELSEIF MID$(p$, lastSep, 1) = ":" THEN
    ' Include the colon (device/volume root)
    FadDirName$ = LEFT$(p$, lastSep)
  ELSE
    ' Don't include the slash
    FadDirName$ = LEFT$(p$, lastSep - 1)
  END IF
END SUB

SUB STRING FadExt$(path$) EXTERNAL
  STRING base$
  LONGINT i, dotPos
  ADDRESS fp

  ' Get the filename part only (don't match dots in directory components)
  fp = FilePart(path$)
  IF fp = 0 THEN
    FadExt$ = ""
    EXIT SUB
  END IF
  base$ = CSTR(fp)

  ' Find last dot in filename
  dotPos = 0
  FOR i = 1 TO LEN(base$)
    IF MID$(base$, i, 1) = "." THEN dotPos = i
  NEXT i

  IF dotPos = 0 OR dotPos = LEN(base$) THEN
    FadExt$ = ""
  ELSE
    FadExt$ = MID$(base$, dotPos + 1)
  END IF
END SUB

SUB STRING FadReplaceExt$(path$, ext$) EXTERNAL
  STRING base$
  LONGINT i, dotPos, L
  ADDRESS fp

  ' Find the filename portion
  fp = FilePart(path$)
  IF fp = 0 THEN
    FadReplaceExt$ = path$
    EXIT SUB
  END IF
  base$ = CSTR(fp)

  ' Find last dot in filename
  dotPos = 0
  FOR i = 1 TO LEN(base$)
    IF MID$(base$, i, 1) = "." THEN dotPos = i
  NEXT i

  ' Calculate position of dot in full path
  ' Length of directory part = LEN(path$) - LEN(base$)
  L = LEN(path$) - LEN(base$)

  IF dotPos = 0 THEN
    ' No extension: append .ext
    FadReplaceExt$ = path$ + "." + ext$
  ELSE
    ' Replace from dot position in full path
    FadReplaceExt$ = LEFT$(path$, L + dotPos - 1) + "." + ext$
  END IF
END SUB

SUB STRING FadJoin$(base$, part$) EXTERNAL
  STRING lastCh$

  IF LEN(base$) = 0 THEN
    FadJoin$ = part$
    EXIT SUB
  END IF

  IF LEN(part$) = 0 THEN
    FadJoin$ = base$
    EXIT SUB
  END IF

  ' Amiga path joining: if base ends with : or /, just concatenate
  ' Otherwise insert a /
  lastCh$ = RIGHT$(base$, 1)
  IF lastCh$ = ":" OR lastCh$ = "/" THEN
    FadJoin$ = base$ + part$
  ELSE
    FadJoin$ = base$ + "/" + part$
  END IF
END SUB

SUB STRING FadParent$(path$) EXTERNAL
  LONGINT i, lastSep, L
  STRING p$

  ' Strip trailing /
  p$ = path$
  L = LEN(p$)
  IF L > 1 AND RIGHT$(p$, 1) = "/" THEN
    p$ = LEFT$(p$, L - 1)
    L = L - 1
  END IF

  ' Find last : or /
  lastSep = 0
  FOR i = 1 TO L
    IF MID$(p$, i, 1) = ":" OR MID$(p$, i, 1) = "/" THEN lastSep = i
  NEXT i

  IF lastSep = 0 THEN
    ' No separator: relative name, parent is ""
    FadParent$ = ""
  ELSEIF MID$(p$, lastSep, 1) = ":" THEN
    ' Volume root: cannot go higher
    FadParent$ = LEFT$(p$, lastSep)
  ELSE
    ' Remove last component (the / and everything after it)
    FadParent$ = LEFT$(p$, lastSep - 1)
  END IF
END SUB

{* ============== Directory Iteration ============== *}

SUB SHORTINT FadOpenDir%(path$) EXTERNAL
  SHARED _fad_err, _fad_dirlock, _fad_fib
  DECLARE STRUCT _FadFIB *fib
  _fad_err = 0

  ' Clean up any previous iteration
  IF _fad_dirlock <> 0 THEN
    UnLock(_fad_dirlock)
    _fad_dirlock = 0
  END IF
  IF _fad_fib <> 0 THEN
    FREE _fad_fib
    _fad_fib = 0
  END IF

  _fad_dirlock = Lock(path$, _FAD_ACCESS_READ)
  IF _fad_dirlock = 0 THEN
    _fad_err = IoErr
    FadOpenDir% = 0
    EXIT SUB
  END IF

  _fad_fib = ALLOC(SIZEOF(_FadFIB))
  IF _fad_fib = 0 THEN
    UnLock(_fad_dirlock)
    _fad_dirlock = 0
    _fad_err = 103
    FadOpenDir% = 0
    EXIT SUB
  END IF

  fib = _fad_fib
  IF Examine(_fad_dirlock, fib) = 0 THEN
    _fad_err = IoErr
    FREE _fad_fib
    _fad_fib = 0
    UnLock(_fad_dirlock)
    _fad_dirlock = 0
    FadOpenDir% = 0
    EXIT SUB
  END IF

  FadOpenDir% = -1
END SUB

SUB SHORTINT FadNext% EXTERNAL
  SHARED _fad_err, _fad_dirlock, _fad_fib
  SHARED _fad_ename, _fad_esize, _fad_etype
  SHARED _fad_eprot, _fad_edays, _fad_emins, _fad_eticks
  DECLARE STRUCT _FadFIB *fib
  DECLARE STRUCT _FadDateStamp *ds

  _fad_err = 0
  IF _fad_dirlock = 0 OR _fad_fib = 0 THEN
    FadNext% = 0
    EXIT SUB
  END IF

  fib = _fad_fib
  IF ExNext(_fad_dirlock, fib) = 0 THEN
    _fad_err = IoErr
    FadNext% = 0
    EXIT SUB
  END IF

  ' Cache entry data from FIB
  _fad_ename = fib->fib_FileName
  _fad_esize = fib->fib_Size
  _fad_etype = fib->fib_DirEntryType
  _fad_eprot = fib->fib_Protection
  ds = @fib->fib_Date
  _fad_edays = ds->ds_Days
  _fad_emins = ds->ds_Mins
  _fad_eticks = ds->ds_Ticks

  FadNext% = -1
END SUB

SUB STRING FadEntryName$ EXTERNAL
  SHARED _fad_ename
  FadEntryName$ = _fad_ename
END SUB

SUB LONGINT FadEntrySize& EXTERNAL
  SHARED _fad_esize
  FadEntrySize& = _fad_esize
END SUB

SUB SHORTINT FadEntryIsDir% EXTERNAL
  SHARED _fad_etype
  IF _fad_etype > 0 THEN
    FadEntryIsDir% = -1
  ELSE
    FadEntryIsDir% = 0
  END IF
END SUB

SUB LONGINT FadEntryProtect& EXTERNAL
  SHARED _fad_eprot
  FadEntryProtect& = _fad_eprot
END SUB

SUB LONGINT FadEntryDays& EXTERNAL
  SHARED _fad_edays
  FadEntryDays& = _fad_edays
END SUB

SUB LONGINT FadEntryMins& EXTERNAL
  SHARED _fad_emins
  FadEntryMins& = _fad_emins
END SUB

SUB LONGINT FadEntryTicks& EXTERNAL
  SHARED _fad_eticks
  FadEntryTicks& = _fad_eticks
END SUB

SUB FadCloseDir EXTERNAL
  SHARED _fad_dirlock, _fad_fib
  IF _fad_dirlock <> 0 THEN
    UnLock(_fad_dirlock)
    _fad_dirlock = 0
  END IF
  IF _fad_fib <> 0 THEN
    FREE _fad_fib
    _fad_fib = 0
  END IF
END SUB

{* ============== File Operations ============== *}

SUB LONGINT FadCopy&(src$, dst$) EXTERNAL
  SHARED _fad_err
  LONGINT fhSrc, fhDst, bytesRead
  ADDRESS buf

  _fad_err = 0
  buf = ALLOC(_FAD_COPY_BUFSZ)
  IF buf = 0 THEN
    _fad_err = 103
    FadCopy& = 103
    EXIT SUB
  END IF

  fhSrc = _Open(src$, _FAD_MODE_OLDFILE)
  IF fhSrc = 0 THEN
    _fad_err = IoErr
    FadCopy& = _fad_err
    FREE buf
    EXIT SUB
  END IF

  fhDst = _Open(dst$, _FAD_MODE_NEWFILE)
  IF fhDst = 0 THEN
    _fad_err = IoErr
    FadCopy& = _fad_err
    _Close(fhSrc)
    FREE buf
    EXIT SUB
  END IF

  bytesRead = _Read(fhSrc, buf, _FAD_COPY_BUFSZ)
  WHILE bytesRead > 0
    IF _Write(fhDst, buf, bytesRead) <> bytesRead THEN
      _fad_err = IoErr
      FadCopy& = _fad_err
      _Close(fhDst)
      _Close(fhSrc)
      FREE buf
      EXIT SUB
    END IF
    bytesRead = _Read(fhSrc, buf, _FAD_COPY_BUFSZ)
  WEND

  _Close(fhDst)
  _Close(fhSrc)
  FREE buf
  FadCopy& = 0
END SUB

SUB LONGINT FadMkDir&(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk
  _fad_err = 0
  lk = CreateDir(path$)
  IF lk <> 0 THEN
    UnLock(lk)
    FadMkDir& = 0
  ELSE
    _fad_err = IoErr
    FadMkDir& = _fad_err
  END IF
END SUB

SUB LONGINT FadMkDirP&(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk, i, L
  STRING p$, component$

  _fad_err = 0
  p$ = path$
  L = LEN(p$)

  IF L = 0 THEN
    FadMkDirP& = 0
    EXIT SUB
  END IF

  ' Skip past device/volume part (up to and including :)
  i = 1
  WHILE i <= L AND MID$(p$, i, 1) <> ":"
    i = i + 1
  WEND
  IF i <= L THEN
    ' Found colon, skip past it
    i = i + 1
  ELSE
    ' No device part (relative path), start from beginning
    i = 1
  END IF

  ' Process each path component after the device part
  WHILE i <= L
    ' Find next / or end of string
    WHILE i <= L AND MID$(p$, i, 1) <> "/"
      i = i + 1
    WEND

    ' Try to access the path up to this point
    component$ = LEFT$(p$, i - 1)
    lk = Lock(component$, _FAD_ACCESS_READ)
    IF lk <> 0 THEN
      UnLock(lk)
    ELSE
      ' Directory doesn't exist, try to create it
      lk = CreateDir(component$)
      IF lk <> 0 THEN
        UnLock(lk)
      ELSE
        _fad_err = IoErr
        ' 203 = ERROR_OBJECT_EXISTS, not a real error
        IF _fad_err <> 203 THEN
          FadMkDirP& = _fad_err
          EXIT SUB
        END IF
      END IF
    END IF

    ' Skip past the /
    IF i <= L THEN i = i + 1
  WEND

  FadMkDirP& = 0
END SUB

SUB LONGINT FadDeleteTree&(path$) EXTERNAL
  SHARED _fad_err
  LONGINT lk

  _fad_err = 0

  ' Check if path exists
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk = 0 THEN
    _fad_err = IoErr
    FadDeleteTree& = _fad_err
    EXIT SUB
  END IF
  UnLock(lk)

  ' Use AmigaDOS delete ALL for reliable recursive deletion
  SYSTEM "delete " + path$ + " ALL QUIET"

  ' Check if deletion succeeded
  lk = Lock(path$, _FAD_ACCESS_READ)
  IF lk = 0 THEN
    ' Path gone = success
    FadDeleteTree& = 0
  ELSE
    UnLock(lk)
    _fad_err = IoErr
    IF _fad_err = 0 THEN _fad_err = 216
    FadDeleteTree& = _fad_err
  END IF
END SUB
