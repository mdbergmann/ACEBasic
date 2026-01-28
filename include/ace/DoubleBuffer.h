{* DoubleBuffer.h - Double buffering support for ACE Basic.
   Provides tear-free animation via double buffering.

   Requires AmigaOS 3.0+ (V39 graphics.library).

   Usage:
     #include <ace/DoubleBuffer.h>
     SCREEN 1,320,200,5,1
     WINDOW 1,,(0,0)-(320,200),32,1
     DbufInit
     IF DbufReady THEN
       ' main loop:
       '   clear back buffer with LINE (0,0)-(w,h),0,bf
       '   draw frame using LINE, CIRCLE, PSET, PRINTS etc.
       '   DbufSwap
       DbufCleanup
     END IF
     WINDOW CLOSE 1
     SCREEN CLOSE 1

   Notes:
   - DbufCleanup MUST be called before SCREEN CLOSE.
     AllocBitMap/FreeBitMap are OS calls not tracked by ACE's
     auto-cleanup. Skipping cleanup leaks memory until reboot.
   - Use PRINTS for text in double-buffered programs (it draws
     through RastPort). PRINT may bypass double buffering.
   - Only works for the currently active screen.

   Author: AI-assisted
   Date: January 2026
*}

LIBRARY "graphics.library"

DECLARE FUNCTION AllocBitMap&(LONGINT sx, LONGINT sy, LONGINT dp, LONGINT fl, ADDRESS fr) LIBRARY graphics
DECLARE FUNCTION FreeBitMap(ADDRESS bm) LIBRARY graphics
DECLARE FUNCTION ScrollVPort(ADDRESS vp) LIBRARY graphics
DECLARE FUNCTION WaitTOF() LIBRARY graphics

LONGINT dbuf.backBM, dbuf.origBM
LONGINT dbuf.rp, dbuf.vp, dbuf.ri

SUB DbufInit
  SHARED dbuf.backBM, dbuf.origBM
  SHARED dbuf.rp, dbuf.vp, dbuf.ri

  LONGINT bm, w, h, d

  dbuf.rp = SCREEN(2)          '..RastPort pointer
  dbuf.vp = SCREEN(3)          '..ViewPort pointer
  bm = SCREEN(4)               '..BitMap pointer (inline in Screen struct)
  dbuf.origBM = bm

  '..Read bitmap dimensions
  w = PEEKW(bm) * 8            '..BytesPerRow * 8 = width in pixels
  h = PEEKW(bm + 2)            '..Rows
  d = PEEK(bm + 5)             '..Depth

  '..Allocate second bitmap (BMF_CLEAR | BMF_DISPLAYABLE = 3)
  '..Last param is "friend" bitmap for alignment compatibility
  dbuf.backBM = AllocBitMap(w, h, d, 3&, bm)

  IF dbuf.backBM = 0& THEN
    EXIT SUB
  END IF

  '..Cache RasInfo pointer (ViewPort->RasInfo at offset 36)
  dbuf.ri = PEEKL(dbuf.vp + 36)

  '..Redirect drawing to back buffer (RastPort->BitMap at offset 4)
  POKEL dbuf.rp + 4, dbuf.backBM
END SUB

SUB DbufSwap
  SHARED dbuf.backBM
  SHARED dbuf.rp, dbuf.vp, dbuf.ri

  LONGINT drawBM, dispBM

  IF dbuf.backBM = 0& THEN EXIT SUB

  '..Get current bitmaps
  drawBM = PEEKL(dbuf.rp + 4)      '..what we were drawing to
  dispBM = PEEKL(dbuf.ri + 4)      '..what was being displayed

  '..Make the drawn-to buffer visible
  POKEL dbuf.ri + 4, drawBM        '..RasInfo->BitMap = drawn buffer
  ScrollVPort(dbuf.vp)              '..regenerate copper list
  WaitTOF                           '..sync to vertical blank

  '..Draw to the previously-displayed buffer
  POKEL dbuf.rp + 4, dispBM        '..RastPort->BitMap = old display
END SUB

SUB DbufCleanup
  SHARED dbuf.backBM, dbuf.origBM
  SHARED dbuf.rp, dbuf.vp, dbuf.ri

  IF dbuf.backBM = 0& THEN EXIT SUB

  '..Restore original bitmap to display
  POKEL dbuf.ri + 4, dbuf.origBM
  ScrollVPort(dbuf.vp)
  WaitTOF

  '..Restore RastPort
  POKEL dbuf.rp + 4, dbuf.origBM

  '..Free the allocated bitmap
  FreeBitMap(dbuf.backBM)
  dbuf.backBM = 0&
END SUB

SUB DbufReady
  SHARED dbuf.backBM
  IF dbuf.backBM <> 0& THEN
    DbufReady = -1
  ELSE
    DbufReady = 0
  END IF
END SUB
