{* IFF - IFF Picture Submodule for ACE BASIC *}
{* Provides IFF ILBM/ACBM picture loading via ilbm.library *}
{* Replaces built-in IFF commands with a submodule API *}

{* ============== Constants ============== *}

CONST IFF_OK       = 0
CONST IFF_ERR_OPEN = -1
CONST IFF_ERR_READ = -2
CONST IFF_ERR_CHAN = -3
CONST IFF_ERR_LIB  = -4

CONST IFF_MAX_CHAN  = 15
CONST MODE_OLDFILE  = 1005
CONST ILBM_FRAME_SIZE = 172
CONST ILBM_OFF_IWINDOW = 156
CONST ILBM_OFF_ISCREEN = 160
CONST SCREEN_OFF_FIRSTWINDOW = 4

{* ============== Module State ============== *}

LONGINT _ilbmBase       ' ilbm.library base
LONGINT _intuBase       ' intuition.library base
LONGINT _dosBase        ' dos.library base
LONGINT _iffInited      ' 0=not init, -1=init

' ASSEM register transfer variables
LONGINT _asmD0
LONGINT _asmD1
LONGINT _asmD2
LONGINT _asmD3
LONGINT _asmA0
LONGINT _asmA1
LONGINT _asmA6

' Channel arrays (index 0 unused, 1..IFF_MAX_CHAN)
DIM chanOpen%(IFF_MAX_CHAN)
DIM chanName$(IFF_MAX_CHAN)
DIM chanType$(IFF_MAX_CHAN)
DIM chanWidth%(IFF_MAX_CHAN)
DIM chanHeight%(IFF_MAX_CHAN)
DIM chanDepth%(IFF_MAX_CHAN)
DIM chanWinAddr&(IFF_MAX_CHAN)
DIM chanScrAddr&(IFF_MAX_CHAN)

{* ============== Internal: exec library calls ============== *}

SUB LONGINT _ExecOpenLib(ADDRESS libName, LONGINT ver)
  SHARED _asmA1, _asmD0

  _asmA1 = libName
  _asmD0 = ver

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  _modv__ASMD0,d0
    move.l  4,a6
    jsr     -552(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM

  _ExecOpenLib = _asmD0
END SUB

SUB _ExecCloseLib(ADDRESS libBase)
  SHARED _asmA1

  _asmA1 = libBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA1,a1
    move.l  4,a6
    jsr     -414(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

{* ============== Internal: dos library calls ============== *}

' dos Open: d1=filename, d2=accessMode -> d0=filehandle
SUB LONGINT _DosOpen(ADDRESS fName, LONGINT accessMode)
  SHARED _asmD0, _asmD1, _asmD2, _asmA6, _dosBase

  _asmD1 = fName
  _asmD2 = accessMode
  _asmA6 = _dosBase

  ASSEM
    movem.l d0-d3/a0-a1/a6,-(sp)
    move.l  _modv__ASMD1,d1
    move.l  _modv__ASMD2,d2
    move.l  _modv__ASMA6,a6
    jsr     -30(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d3/a0-a1/a6
  END ASSEM

  _DosOpen = _asmD0
END SUB

' dos Read: d1=fh, d2=buffer, d3=length -> d0=actual
SUB LONGINT _DosRead(LONGINT fh, ADDRESS buf, LONGINT readLen)
  SHARED _asmD0, _asmD1, _asmD2, _asmD3, _asmA6, _dosBase

  _asmD1 = fh
  _asmD2 = buf
  _asmD3 = readLen
  _asmA6 = _dosBase

  ASSEM
    movem.l d0-d3/a0-a1/a6,-(sp)
    move.l  _modv__ASMD1,d1
    move.l  _modv__ASMD2,d2
    move.l  _modv__ASMD3,d3
    move.l  _modv__ASMA6,a6
    jsr     -42(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d3/a0-a1/a6
  END ASSEM

  _DosRead = _asmD0
END SUB

' dos Close: d1=fh
SUB _DosClose(LONGINT fh)
  SHARED _asmD1, _asmA6, _dosBase

  _asmD1 = fh
  _asmA6 = _dosBase

  ASSEM
    movem.l d0-d3/a0-a1/a6,-(sp)
    move.l  _modv__ASMD1,d1
    move.l  _modv__ASMA6,a6
    jsr     -36(a6)
    movem.l (sp)+,d0-d3/a0-a1/a6
  END ASSEM
END SUB

{* ============== Internal: ilbm library call ============== *}

' ilbm LoadIFFToWindow: d1=filename, a1=frame -> d0=result
SUB LONGINT _IlbmLoadIFF(ADDRESS fName, ADDRESS frame)
  SHARED _asmD0, _asmD1, _asmA1, _asmA6, _ilbmBase

  _asmD1 = fName
  _asmA1 = frame
  _asmA6 = _ilbmBase

  ASSEM
    movem.l d0-d3/a0-a2/a6,-(sp)
    move.l  _modv__ASMD1,d1
    move.l  _modv__ASMA1,a1
    move.l  _modv__ASMA6,a6
    jsr     -30(a6)
    move.l  d0,_modv__ASMD0
    movem.l (sp)+,d0-d3/a0-a2/a6
  END ASSEM

  _IlbmLoadIFF = _asmD0
END SUB

{* ============== Internal: intuition library calls ============== *}

' intuition CloseWindow: a0=window
SUB _IntuCloseWindow(ADDRESS win)
  SHARED _asmA0, _asmA6, _intuBase

  _asmA0 = win
  _asmA6 = _intuBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -72(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

' intuition CloseScreen: a0=screen
SUB _IntuCloseScreen(ADDRESS scr)
  SHARED _asmA0, _asmA6, _intuBase

  _asmA0 = scr
  _asmA6 = _intuBase

  ASSEM
    movem.l d0-d1/a0-a1/a6,-(sp)
    move.l  _modv__ASMA0,a0
    move.l  _modv__ASMA6,a6
    jsr     -66(a6)
    movem.l (sp)+,d0-d1/a0-a1/a6
  END ASSEM
END SUB

{* ============== Internal: channel validation ============== *}

SUB LONGINT _ValidChan(SHORTINT ch)
  IF ch >= 1 AND ch <= IFF_MAX_CHAN THEN
    _ValidChan = -1
  ELSE
    _ValidChan = 0
  END IF
END SUB

{* ============== Public: Lifecycle ============== *}

SUB LONGINT IffInit EXTERNAL
  SHARED _ilbmBase, _intuBase, _dosBase, _iffInited

  IF _iffInited = -1 THEN
    IffInit = IFF_OK
    EXIT SUB
  END IF

  ' Open dos.library
  _dosBase = _ExecOpenLib(SADD("dos.library" + CHR$(0)), 0&)
  IF _dosBase = 0 THEN
    IffInit = IFF_ERR_LIB
    EXIT SUB
  END IF

  ' Open intuition.library
  _intuBase = _ExecOpenLib(SADD("intuition.library" + CHR$(0)), 0&)
  IF _intuBase = 0 THEN
    _ExecCloseLib(_dosBase)
    _dosBase = 0
    IffInit = IFF_ERR_LIB
    EXIT SUB
  END IF

  ' Open ilbm.library (must be installed in LIBS:)
  _ilbmBase = _ExecOpenLib(SADD("ilbm.library" + CHR$(0)), 0&)
  IF _ilbmBase = 0 THEN
    _ExecCloseLib(_intuBase)
    _ExecCloseLib(_dosBase)
    _intuBase = 0
    _dosBase = 0
    IffInit = IFF_ERR_LIB
    EXIT SUB
  END IF

  _iffInited = -1
  IffInit = IFF_OK
END SUB

{* ============== Public: Close (must be before IffShutdown) ============== *}

SUB IffClose(SHORTINT ch) EXTERNAL
  SHARED _iffInited
  SHARED chanOpen%, chanName$, chanType$
  SHARED chanWidth%, chanHeight%, chanDepth%
  SHARED chanWinAddr&, chanScrAddr&

  IF _iffInited = 0 THEN EXIT SUB
  IF _ValidChan(ch) = 0 THEN EXIT SUB
  IF chanOpen%(ch) = 0 THEN EXIT SUB

  ' Close window and screen opened by ilbm.library
  IF chanWinAddr&(ch) <> 0 THEN
    _IntuCloseWindow(chanWinAddr&(ch))
  END IF

  IF chanScrAddr&(ch) <> 0 THEN
    _IntuCloseScreen(chanScrAddr&(ch))
  END IF

  ' Reset channel
  chanOpen%(ch) = 0
  chanName$(ch) = ""
  chanType$(ch) = ""
  chanWidth%(ch) = 0
  chanHeight%(ch) = 0
  chanDepth%(ch) = 0
  chanWinAddr&(ch) = 0
  chanScrAddr&(ch) = 0
END SUB

SUB IffShutdown EXTERNAL
  SHARED _ilbmBase, _intuBase, _dosBase, _iffInited
  SHARED chanOpen%

  IF _iffInited = 0 THEN EXIT SUB

  ' Close any open channels
  SHORTINT idx
  FOR idx = 1 TO IFF_MAX_CHAN
    IF chanOpen%(idx) THEN
      IffClose(idx)
    END IF
  NEXT idx

  ' Close libraries
  IF _ilbmBase THEN _ExecCloseLib(_ilbmBase)
  IF _intuBase THEN _ExecCloseLib(_intuBase)
  IF _dosBase THEN _ExecCloseLib(_dosBase)

  _ilbmBase = 0
  _intuBase = 0
  _dosBase = 0
  _iffInited = 0
END SUB

{* ============== Public: File Operations ============== *}

SUB LONGINT IffOpen(SHORTINT ch, STRING fileName$) EXTERNAL
  SHARED _iffInited, _dosBase
  SHARED chanOpen%, chanName$, chanType$
  SHARED chanWidth%, chanHeight%, chanDepth%
  SHARED chanWinAddr&, chanScrAddr&

  ' Validate
  IF _iffInited = 0 THEN
    IffOpen = IFF_ERR_LIB
    EXIT SUB
  END IF

  IF _ValidChan(ch) = 0 THEN
    IffOpen = IFF_ERR_CHAN
    EXIT SUB
  END IF

  IF chanOpen%(ch) THEN
    IffOpen = IFF_ERR_OPEN
    EXIT SUB
  END IF

  ' Allocate read buffer (300 bytes, like the C runtime)
  LONGINT buf
  buf = ALLOC(300&)
  IF buf = 0 THEN
    IffOpen = IFF_ERR_OPEN
    EXIT SUB
  END IF

  ' Open file
  LONGINT fh
  fh = _DosOpen(SADD(fileName$), MODE_OLDFILE)
  IF fh = 0 THEN
    IffOpen = IFF_ERR_OPEN
    EXIT SUB
  END IF

  ' Read FORM header (12 bytes): "FORM" + 4-byte size + 4-byte type
  LONGINT rLen
  rLen = _DosRead(fh, buf, 12&)
  IF rLen <> 12 THEN
    _DosClose(fh)
    IffOpen = IFF_ERR_READ
    EXIT SUB
  END IF

  ' Check type at offset 8: must be "ILBM" or "ACBM"
  STRING typeStr$ SIZE 8
  typeStr$ = CHR$(PEEK(buf+8)) + CHR$(PEEK(buf+9)) + CHR$(PEEK(buf+10)) + CHR$(PEEK(buf+11))

  IF typeStr$ <> "ILBM" AND typeStr$ <> "ACBM" THEN
    _DosClose(fh)
    IffOpen = IFF_ERR_READ
    EXIT SUB
  END IF

  ' Read chunk header (8 bytes): chunk-ID + 4-byte length
  rLen = _DosRead(fh, buf, 8&)
  IF rLen <> 8 THEN
    _DosClose(fh)
    IffOpen = IFF_ERR_READ
    EXIT SUB
  END IF

  ' Get chunk data length (low 16 bits, big-endian at offset 6-7)
  LONGINT icLen
  icLen = PEEK(buf+6) * 256& + PEEK(buf+7)

  ' Read chunk data (BMHD BitMapHeader)
  IF icLen > 290 THEN icLen = 290
  rLen = _DosRead(fh, buf, icLen)

  ' Close file
  _DosClose(fh)

  IF rLen < 9 THEN
    IffOpen = IFF_ERR_READ
    EXIT SUB
  END IF

  ' Extract dimensions from BitMapHeader:
  '   offset 0-1: UWORD w (width)
  '   offset 2-3: UWORD h (height)
  '   offset 8:   UBYTE nPlanes (depth)
  chanWidth%(ch) = PEEKW(buf)
  chanHeight%(ch) = PEEKW(buf + 2)
  chanDepth%(ch) = PEEK(buf + 8)

  ' Store channel info
  chanType$(ch) = typeStr$
  chanName$(ch) = fileName$
  chanWinAddr&(ch) = 0
  chanScrAddr&(ch) = 0
  chanOpen%(ch) = -1

  IffOpen = IFF_OK
END SUB

SUB LONGINT IffDisplay(SHORTINT ch, LONGINT scrAddr) EXTERNAL
  SHARED _iffInited, _ilbmBase
  SHARED chanOpen%, chanName$, chanWinAddr&, chanScrAddr&

  ' Validate
  IF _iffInited = 0 THEN
    IffDisplay = IFF_ERR_LIB
    EXIT SUB
  END IF

  IF _ValidChan(ch) = 0 THEN
    IffDisplay = IFF_ERR_CHAN
    EXIT SUB
  END IF

  IF chanOpen%(ch) = 0 THEN
    IffDisplay = IFF_ERR_CHAN
    EXIT SUB
  END IF

  ' Allocate ILBMFrame (172 bytes, cleared)
  LONGINT frame
  frame = ALLOC(ILBM_FRAME_SIZE)
  IF frame = 0 THEN
    IffDisplay = IFF_ERR_READ
    EXIT SUB
  END IF

  ' Zero the frame (ALLOC may not clear)
  LONGINT idx
  FOR idx = 0 TO ILBM_FRAME_SIZE - 4 STEP 4
    POKEL frame + idx, 0
  NEXT idx

  ' If caller provides a screen, set iScreen and iWindow
  IF scrAddr <> 0 THEN
    POKEL frame + ILBM_OFF_ISCREEN, scrAddr
    POKEL frame + ILBM_OFF_IWINDOW, PEEKL(scrAddr + SCREEN_OFF_FIRSTWINDOW)
  END IF

  ' Call LoadIFFToWindow
  LONGINT rc
  rc = _IlbmLoadIFF(SADD(chanName$(ch)), frame)

  IF rc <> 0 THEN
    IffDisplay = IFF_ERR_READ
    EXIT SUB
  END IF

  ' Store screen/window if ilbm.library created them
  IF scrAddr = 0 THEN
    chanScrAddr&(ch) = PEEKL(frame + ILBM_OFF_ISCREEN)
    chanWinAddr&(ch) = PEEKL(frame + ILBM_OFF_IWINDOW)
  ELSE
    ' Caller is responsible for their own screen/window
    chanScrAddr&(ch) = 0
    chanWinAddr&(ch) = 0
  END IF

  IffDisplay = IFF_OK
END SUB

{* ============== Public: Query Functions ============== *}

SUB LONGINT IffWidth(SHORTINT ch) EXTERNAL
  SHARED chanOpen%, chanWidth%

  IF _ValidChan(ch) = 0 THEN
    IffWidth = 0
    EXIT SUB
  END IF

  IF chanOpen%(ch) = 0 THEN
    IffWidth = 0
    EXIT SUB
  END IF

  IffWidth = chanWidth%(ch)
END SUB

SUB LONGINT IffHeight(SHORTINT ch) EXTERNAL
  SHARED chanOpen%, chanHeight%

  IF _ValidChan(ch) = 0 THEN
    IffHeight = 0
    EXIT SUB
  END IF

  IF chanOpen%(ch) = 0 THEN
    IffHeight = 0
    EXIT SUB
  END IF

  IffHeight = chanHeight%(ch)
END SUB

SUB LONGINT IffDepth(SHORTINT ch) EXTERNAL
  SHARED chanOpen%, chanDepth%

  IF _ValidChan(ch) = 0 THEN
    IffDepth = 0
    EXIT SUB
  END IF

  IF chanOpen%(ch) = 0 THEN
    IffDepth = 0
    EXIT SUB
  END IF

  IffDepth = chanDepth%(ch)
END SUB

SUB LONGINT IffScreenMode(SHORTINT ch) EXTERNAL
  SHARED chanOpen%, chanWidth%, chanHeight%, chanDepth%

  IF _ValidChan(ch) = 0 THEN
    IffScreenMode = 0
    EXIT SUB
  END IF

  IF chanOpen%(ch) = 0 THEN
    IffScreenMode = 0
    EXIT SUB
  END IF

  ' Screen mode heuristic (same logic as original runtime):
  '   6 bitplanes = HAM (5)
  '   width > 320 AND height > 200 = hi-res interlaced (4)
  '   width <= 320 AND height > 200 = lo-res interlaced (3)
  '   width > 320 AND height <= 200 = hi-res (2)
  '   else = lo-res (1)
  IF chanDepth%(ch) = 6 THEN
    IffScreenMode = 5
  ELSEIF chanWidth%(ch) > 320 AND chanHeight%(ch) > 200 THEN
    IffScreenMode = 4
  ELSEIF chanWidth%(ch) <= 320 AND chanHeight%(ch) > 200 THEN
    IffScreenMode = 3
  ELSEIF chanWidth%(ch) > 320 AND chanHeight%(ch) <= 200 THEN
    IffScreenMode = 2
  ELSE
    IffScreenMode = 1
  END IF
END SUB

SUB LONGINT IffFormType(SHORTINT ch) EXTERNAL
  SHARED chanOpen%, chanType$

  IF _ValidChan(ch) = 0 THEN
    IffFormType = 0
    EXIT SUB
  END IF

  IF chanOpen%(ch) = 0 THEN
    IffFormType = 0
    EXIT SUB
  END IF

  IffFormType = SADD(chanType$(ch))
END SUB
