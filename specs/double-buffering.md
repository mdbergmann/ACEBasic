# Double Buffering Support for ACE Basic

## Overview

Add double buffering via an include file (`include/ace/DoubleBuffer.h`) that uses ACE's existing PEEKL/POKEL and LIBRARY call capabilities to swap bitmaps at the RastPort and ViewPort level. No compiler or runtime changes needed.

Requires AmigaOS 3.0+ (V39 graphics.library) — same requirement as ACE's AGA modes.

## How It Works

1. `AllocBitMap()` allocates a second bitmap matching the screen's bitmap (proper AGA alignment via "friend" bitmap parameter)
2. POKEL swaps the `RastPort->BitMap` pointer (offset 4) to redirect all ACE drawing commands (LINE, CIRCLE, PSET, PAINT, AREA, etc.) to the back buffer
3. On swap: POKEL changes `ViewPort->RasInfo->BitMap` to display the drawn buffer, `ScrollVPort()` regenerates the copper list, `WaitTOF()` syncs to VBlank, then POKEL redirects drawing to the now-offscreen buffer
4. Cleanup restores original bitmap pointers and calls `FreeBitMap()`

## Files to Create

### 1. `include/ace/DoubleBuffer.h`

The include file providing 4 SUBs. Follows the style of `include/ace/fexists.h` (simple SUB definitions, no include guards — ACE's `#include` prevents double inclusion automatically).

#### API

| SUB | Purpose |
|-----|---------|
| `DbufInit` | Allocate back buffer matching current screen, redirect drawing to it |
| `DbufSwap` | Display the back buffer, redirect drawing to the old front buffer |
| `DbufCleanup` | Restore originals, free allocated bitmap. **Must** be called before SCREEN CLOSE |
| `DbufReady` | Returns non-zero (-1) if init succeeded, 0 otherwise |

#### Verified Structure Offsets

These are confirmed from the ACE include headers (`include/graphics/RastPort.h`, `include/graphics/View.h`, `include/graphics/gfx.h`):

| Structure | Field | Offset |
|-----------|-------|--------|
| RastPort | BitMap (ADDRESS) | 4 |
| ViewPort | RasInfo (ADDRESS) | 36 |
| RasInfo | BitMap (ADDRESS) | 4 |
| BitMap | BytesPerRow (SHORTINT) | 0 |
| BitMap | Rows (SHORTINT) | 2 |
| BitMap | Depth (BYTE) | 5 |

#### Library Functions Used

All confirmed present in `bmaps/graphics.bmap`:

| Function | Purpose |
|----------|---------|
| `AllocBitMap&(sizex&, sizey&, depth&, flags&, friend_bm&)` | Allocate displayable bitmap with AGA-compatible alignment |
| `FreeBitMap(bm&)` | Free an allocated bitmap |
| `ScrollVPort(vp&)` | Regenerate copper list after bitmap change |
| `WaitTOF()` | Wait for vertical blank (prevents tearing) |

`graphics.library` is a standard ACE library (auto-opened), but `LIBRARY "graphics.library"` is included explicitly to ensure it opens at program start.

#### Implementation

```basic
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
```

### 2. `examples/gfx/dbuf_demo.b`

Bouncing filled circle demonstrating the init/draw/swap/cleanup pattern.

```basic
{* Double Buffer Demo - Bouncing Ball
   Demonstrates tear-free animation using DoubleBuffer.h *}

#include <ace/DoubleBuffer.h>

CONST scrW = 320
CONST scrH = 256
CONST ballR = 15

'..Open a lores screen
SCREEN 1,scrW,scrH,4,1
WINDOW 1,,(0,0)-(scrW,scrH),32,1

PALETTE 0,0,0,0
PALETTE 1,1,1,1
PALETTE 2,1,0,0
PALETTE 3,0,0,1

'..Initialize double buffering
DbufInit

IF NOT DbufReady THEN
  PRINT "Failed to allocate back buffer!"
  WINDOW CLOSE 1
  SCREEN CLOSE 1
  STOP
END IF

'..Ball state
SINGLE bx, by, dx, dy
bx = scrW / 2
by = scrH / 2
dx = 3
dy = 2

'..Animation loop
WHILE INKEY$ = ""
  '..Clear back buffer
  LINE (0,0)-(scrW-1,scrH-1),0,bf

  '..Update position
  bx = bx + dx
  by = by + dy

  '..Bounce
  IF bx - ballR < 0 OR bx + ballR >= scrW THEN
    dx = -dx
    bx = bx + dx
  END IF
  IF by - ballR < 0 OR by + ballR >= scrH THEN
    dy = -dy
    by = by + dy
  END IF

  '..Draw ball
  CIRCLE (CINT(bx), CINT(by)), ballR, 2,,,,F
  CIRCLE (CINT(bx), CINT(by)), ballR, 1

  '..Info text
  COLOR 3
  LOCATE 1,1
  PRINTS "Double Buffer Demo - Press any key"

  '..Swap buffers
  DbufSwap
WEND

'..Cleanup before closing screen
DbufCleanup

WINDOW CLOSE 1
SCREEN CLOSE 1
```

## Design Decisions

### AllocBitMap vs ALLOC
`AllocBitMap` with a "friend" bitmap parameter ensures proper alignment for AGA chipset display. ACE's `ALLOC` (which auto-frees on exit) doesn't guarantee this. Tradeoff: explicit `DbufCleanup` call is required.

### ScrollVPort + WaitTOF vs ChangeVPBitMap + AllocDBufInfo
`ChangeVPBitMap` is the "proper" V39 approach but requires managing message ports and DBufInfo structures, which is complex in ACE Basic. `ScrollVPort` + `WaitTOF` is simpler and adequate for most use cases. It regenerates the full copper list (slightly slower) but is reliable.

### POKEL-based bitmap switching
Direct manipulation of `RastPort->BitMap` (offset 4) transparently redirects ALL ACE built-in drawing commands. No compiler changes needed — the global `_RPort` points to the same RastPort struct, so POKEL modifies what all drawing functions see.

### Dot-separated variable names (dbuf.xxx)
ACE allows dots in identifiers. This provides a pseudo-namespace to avoid collisions with user variables, following existing patterns (e.g., `m.a`, `m.b` in `examples/include/Petr.h`).

## Known Limitations

1. **Explicit cleanup required** — `AllocBitMap`/`FreeBitMap` are OS calls not tracked by ACE's auto-cleanup. If the program crashes before `DbufCleanup`, the bitmap leaks until reboot.
2. **PRINT vs PRINTS** — `PRINTS` draws through the RastPort (double-buffered correctly). `PRINT` to console device may bypass double buffering. Use `PRINTS` for screen text.
3. **Single screen only** — `SCREEN(n)` returns pointers for the current active screen. The include file operates on whichever screen is active when `DbufInit` is called.
4. **No Layer awareness** — Changing `RastPort->BitMap` directly bypasses the Layers library. This is fine for full-screen CUSTOMSCREEN rendering (ACE's default) but would not work correctly with layered/clipped windows.
