# Filled Circle/Ellipse Implementation Plan for ACE Basic

## Problem Summary

ACE Basic's CIRCLE statement draws outlines only. There is no way to draw a filled circle or ellipse. The Amiga graphics.library provides `AreaEllipse()` specifically for this purpose, and ACE already has the area fill infrastructure (used by AREA/AREAFILL). This plan adds a fill option to CIRCLE for whole circles/ellipses.

## State Tracking

Each phase must update the shared state file `specs/filled-circle-ellipse.state` upon completion. The file records what was done and which phase is next. This allows work to be resumed after interruptions and makes progress visible.

**File**: `specs/filled-circle-ellipse.state`

Format:
```
Phase <N>: <DONE|IN PROGRESS|PENDING>
  <summary of what was done, or blank if pending>

Next: Phase <N>
```

Example after Phase 1 is complete:
```
Phase 1: DONE
  Added _fillellipse to src/lib/asm/gfx.s. Rebuilt db.lib successfully.
  Syntax test circle_fill.b added and passing.

Phase 2: PENDING
Phase 2.5: PENDING
Phase 3: PENDING

Next: Phase 2
```

The state file must be updated at the end of each phase, before moving on.

## Current Architecture

### CIRCLE statement

**Syntax**: `CIRCLE [STEP] (x,y),radius[,color,start,end,aspect]`

**Compiler** (`src/ace/c/gfx.c:220-376`): The `circle()` function parses parameters, converts coordinates to FFP floats, and emits `jsr _ellipse` with parameters in d0-d5.

**Runtime** (`src/lib/asm/gfx.s:102-230`): The `_ellipse` function has two code paths:
- **Full ellipse** (start=0, end=359): Calls `_LVODrawEllipse()` — fast, hardware-accelerated outline.
- **Arc** (any other angles): Plots pixels individually via `_LVOWritePixel()` in a loop with 0.5-degree increments.

### Existing area fill infrastructure

ACE already has full area fill support in `src/lib/asm/gfx.s`:
- `_area` (line 362): Accumulates polygon vertices via `_LVOAreaMove`/`_LVOAreaDraw`
- `_areafill` (line 421): Sets up TmpRas, calls `_LVOAreaEnd`, cleans up — this is the template for our fill implementation
- Data structures: `_areainfo` (line 596), `_areabuffer` (line 647), `_tmpras` (line 469)

### Amiga graphics.library support

- `AreaEllipse(rp, xCenter, yCenter, a, b)` — defines a filled ellipse in the area buffer. Already declared in `include/funcs/graphics_funcs.h:54`.
- `AreaCircle(rp, cx, cy, r)` — macro for `AreaEllipse(rp, cx, cy, r, r)` in `include/graphics/gfxmacros.h:57`.
- After `AreaEllipse`, call `AreaEnd()` to render the filled shape.
- LVO offset: `_LVOAreaEllipse` is a standard graphics.library function (offset -186).

### LINE BF precedent

LINE already supports a fill option via trailing `,BF` (`gfx.c:493-506`). When `BF` is detected, it generates `_LVORectFill` instead of draw calls. This is the syntactic model for CIRCLE fill.

## Scope

**In scope**: Filling whole circles and ellipses (start=0, end=359) using `AreaEllipse`.

**Out of scope**: Filling arcs/sectors (pie slices). This would require combining `AreaMove`/`AreaDraw` for radial lines with the arc outline — significantly more complex, and can be added later.

---

## Phase 1: Runtime Library — `_fillellipse` Function

**Goal**: Add a new assembly routine `_fillellipse` to the runtime library that draws a filled ellipse using the Amiga area system.

### Implementation

**File: `src/lib/asm/gfx.s`**

Add `xdef _fillellipse` to the exports (near line 53) and `xref _LVOAreaEllipse` to the external references (near line 69).

Add a new function `_fillellipse` that takes the same register inputs as `_ellipse` (d0=x, d1=y, d2=radius, d3=start, d4=end, d5=aspect). It only handles the full-ellipse case (the compiler will only call it for full ellipses):

```asm
_fillellipse:
    ; store parameters (same as _ellipse)
    move.l  d0,_x
    move.l  d1,_y
    move.l  d2,_radius
    move.l  d5,_aspect

    ; convert x,y to integers
    movea.l _MathBase,a6
    move.l  _x,d0
    jsr     _LVOSPFix(a6)
    move.l  d0,_x

    move.l  _y,d0
    jsr     _LVOSPFix(a6)
    move.l  d0,_y

    ; calculate x-radius = radius / aspect
    move.l  _radius,d0
    move.l  _aspect,d1
    jsr     _LVOSPDiv(a6)
    jsr     _LVOSPFix(a6)
    move.l  d0,_xradius

    ; coerce y-radius (must be > 0)
    move.l  _radius,d0
    jsr     _LVOSPFix(a6)
    cmpi.l  #0,d0
    bne.s   .store_yrad
    moveq   #1,d0
.store_yrad:
    move.l  d0,_radius

    ; --- set up area system ---

    ; initialize AreaInfo
    movea.l _GfxBase,a6
    lea     _areainfo,a0
    lea     _areabuffer,a1
    move.w  #21,d0              ; 20+1 vertices (enough for AreaEllipse)
    jsr     _LVOInitArea(a6)
    movea.l _RPort,a0
    move.l  #_areainfo,AreaInfo(a0)

    ; allocate TmpRas
    move.w  #2,d0
    jsr     _windowfunc
    move.l  d0,_WdwWidth

    move.w  #3,d0
    jsr     _windowfunc
    move.l  d0,_WdwHeight

    movea.l _GfxBase,a6
    move.l  _WdwWidth,d0
    move.l  _WdwHeight,d1
    jsr     _LVOAllocRaster(a6)
    cmpi.l  #0,d0
    beq     .quit_fillellipse
    move.l  d0,_TRBuf

    ; initialize TmpRas
    movea.l _GfxBase,a6
    move.l  _WdwWidth,d0
    move.l  _WdwHeight,d1
    jsr     _rassize
    lea     _tmpras,a0
    movea.l _TRBuf,a1
    jsr     _LVOInitTmpRas(a6)
    movea.l _RPort,a0
    move.l  #_tmpras,TmpRas(a0)

    ; --- call AreaEllipse ---
    movea.l _GfxBase,a6
    movea.l _RPort,a1
    move.l  _x,d0
    and.w   #$ffff,d0
    move.l  _y,d1
    and.w   #$ffff,d1
    move.l  _xradius,d2
    and.w   #$ffff,d2
    move.l  _radius,d3
    and.w   #$ffff,d3
    jsr     _LVOAreaEllipse(a6)

    ; --- render the fill ---
    movea.l _GfxBase,a6
    movea.l _RPort,a1
    jsr     _LVOAreaEnd(a6)

    ; --- cleanup ---
    movea.l _GfxBase,a6
    movea.l _TRBuf,a0
    move.l  _WdwWidth,d0
    move.l  _WdwHeight,d1
    jsr     _LVOFreeRaster(a6)

.quit_fillellipse:
    movea.l _RPort,a0
    move.l  #0,TmpRas(a0)
    move.l  #0,AreaInfo(a0)
    rts
```

Notes:
- Reuses existing BSS variables (`_x`, `_y`, `_radius`, `_xradius`, `_aspect`, `_WdwWidth`, `_WdwHeight`, `_TRBuf`, `_tmpras`, `_areainfo`, `_areabuffer`) already defined in `gfx.s`.
- Follows the same cleanup pattern as `_areafill` (lines 488-500): free raster, null out TmpRas and AreaInfo pointers.
- Uses `_windowfunc` (codes 2 and 3) to get window dimensions, same as `_areafill` does.
- `_rassize` (gfx.s:237) computes the buffer size for `InitTmpRas`.

### Verification

1. Rebuild the runtime library from `src/make/`:
   ```
   make -f Makefile-lib clean
   make -f Makefile-lib
   ```
   This must be done on the Amiga emulator. Verify `db.lib` is produced without assembler errors.

2. Add a compile-only test `verify/tests/cases/syntax/circle_fill.b`:
   ```basic
   REM Test: Filled circle compiles
   WINDOW 1,"Test",(0,0)-(320,200),6
   CIRCLE (160,100),50,1,,,,.44,F
   SLEEP FOR 1
   WINDOW CLOSE 1
   ```
   Run the test suite category: `rx runner.rexx syntax`
   Verify the test compiles to a `.s` file without errors.

---

## Phase 2: Compiler — Parse the Fill Flag

**Goal**: Extend the CIRCLE parser to accept an optional `,F` parameter and emit `jsr _fillellipse` when fill is requested for a full ellipse.

### Syntax

```
CIRCLE [STEP] (x,y),radius[,color,start,end,aspect[,F]]
```

The trailing `,F` requests a filled ellipse. It is only valid for whole circles (start=0, end=359 or both omitted). If start/end angles are explicitly set to non-default values along with F, the compiler emits an error (fill is not supported for arcs).

### Implementation

**File: `src/ace/c/gfx.c`** — Modify the `circle()` function.

1. Add a local variable:
   ```c
   BOOL fill=FALSE;
   ```

2. After the aspect ratio parsing block (after line 315), add detection for the fill flag:
   ```c
   if (sym == comma)
   {
     insymbol();
     if (sym == ident && id[0]=='F' && (id[1]=='\0' || id[1]==':'))
     {
       fill = TRUE;
       insymbol();
     }
     else _error(20);  /* unexpected symbol */
   }
   ```

3. Before the `jsr _ellipse` generation (line 356), add a conditional branch. If `fill` is TRUE and no explicit start/end angles were set (i.e., it is a full ellipse):
   ```c
   if (fill && !start_angle && !end_angle)
   {
     gen("jsr","_fillellipse","  ");
     enter_XREF("_fillellipse");
   }
   else if (fill && (start_angle || end_angle))
   {
     _error(31);  /* fill not supported for arcs */
   }
   else
   {
     gen("jsr","_ellipse","  ");
     enter_XREF("_ellipse");
   }
   ```
   The existing `enter_XREF` calls for `_GfxBase`, `_MathBase`, `_MathTransBase` remain (lines 358-360), as `_fillellipse` needs the same libraries.

4. If error 31 does not already exist, add an appropriate error message to the error table. Check `src/ace/c/acedef.h` or wherever error messages are defined.

### Assembly Output Example

```basic
CIRCLE (160,100),50,1,,,,.44,F
```

Generates (abbreviated):
```asm
    ; ... push x, y, radius, convert to float, set color ...
    move.l  _floatx,d0
    move.l  _floaty,d1
    moveq   #0,d3              ; start = 0 (default)
    move.l  #$b3800049,d4      ; end = 359 (default)
    move.l  #$e147af3f,d5      ; aspect = 0.44 (default)
    jsr     _fillellipse
    ; ... restore color if changed ...
```

### Verification

1. Rebuild the compiler from `src/make/`:
   ```
   make -f Makefile-ace clean
   make -f Makefile-ace
   ```
   This must be done on the Amiga emulator. Verify `bin/ace` is produced without errors.

2. Add tests to `verify/tests/cases/`:

   **Compile-only test** — `verify/tests/cases/syntax/circle_fill.b`:
   ```basic
   REM Test: Filled circle compiles successfully
   WINDOW 1,"Test",(0,0)-(320,200),6
   CIRCLE (160,100),50,1,,,,F
   SLEEP FOR 1
   WINDOW CLOSE 1
   ```
   Run: `rx runner.rexx syntax` — verify `.s` file is produced.

   **Error test** — `verify/tests/cases/errors/circle_fill_arc.b`:
   ```basic
   REM Test: Fill with arc angles should fail
   WINDOW 1,"Test",(0,0)-(320,200),6
   CIRCLE (160,100),50,1,45,270,,F
   WINDOW CLOSE 1
   ```
   Run: `rx runner.rexx errors` — verify compilation fails (fill+arc = error).

3. Rebuild the runtime library too (if not already done in Phase 1) so that end-to-end linking succeeds:
   ```
   make -f Makefile-lib clean
   make -f Makefile-lib
   ```

---

## Phase 2.5: Example Program — `examples/gfx/circles.b`

**Goal**: Provide a visual demo that exercises both filled and unfilled circles/ellipses, serving as a manual verification aid and a reference for users.

**File**: `examples/gfx/circles.b`

The example opens a 640x256 hires screen with 4 bitplanes (16 colors) and draws three rows:

1. **Unfilled circles** — four outlines with varying colors and aspect ratios (round, wide, tall).
2. **Filled circles** — four filled ellipses with the same size/aspect variations, using the new `,F` parameter.
3. **Filled + outline** — filled ellipse with an outline circle drawn on top in a contrasting color, demonstrating composability.

```basic
'..Filled and unfilled circles/ellipses demo

screen 1,640,256,4,2
window 1,"Circles",(0,0)-(640,256),32,1

palette 0,0,0,0
palette 1,1,1,1
palette 2,1,0,0
palette 3,0,1,0
palette 4,0,0,1
palette 5,1,1,0
palette 6,0,1,1
palette 7,1,0,1

'..unfilled circles
color 1
locate 2,4:print "Unfilled";

circle (80,60),40,1
circle (200,60),40,2
circle (320,60),30,3,,,0.7
circle (440,60),30,4,,,1.5

'..filled circles
locate 10,4:print "Filled";

circle (80,160),40,2,,,,F
circle (200,160),40,3,,,,F
circle (320,160),30,5,,,0.7,F
circle (440,160),30,6,,,1.5,F

'..mixed: filled with outline on top
locate 18,4:print "Filled + Outline";

circle (560,60),40,5,,,,F
circle (560,60),40,1

circle (560,160),30,7,,,0.7,F
circle (560,160),30,1,,,0.7

while inkey$="":sleep:wend

window close 1
screen close 1
```

### Verification

Run the example on the Amiga emulator after Phases 1 and 2 are complete:

1. Compile: `bas examples/gfx/circles` (no `.b` extension)
2. Run the resulting executable on the emulator.
3. Visually confirm:
   - Top row: four outlined (hollow) circles/ellipses in white, red, green, blue.
   - Middle row: four solid filled circles/ellipses in red, green, yellow, cyan.
   - Right column: filled shapes with a contrasting outline drawn over them.
   - Wide ellipses (aspect 0.7) and tall ellipses (aspect 1.5) render correctly in both filled and unfilled modes.
4. Press any key to exit cleanly.

---

## Phase 3: Documentation

**File: `docs/ref.txt`**

Update the CIRCLE entry (lines 396-407) to document the new parameter:

```
CIRCLE - syntax: CIRCLE [STEP] (x,y),radius[,color-id[,start,end[,aspect[,F]]]]

    where F indicates a filled circle/ellipse. F is only valid for
    whole circles (default start=0, end=359). Filling arcs is not
    supported.

    ...existing documentation...
```

---

## Summary of Changes

| File | Change |
|------|--------|
| `src/lib/asm/gfx.s` | Add `_fillellipse` routine, `xdef _fillellipse`, `xref _LVOAreaEllipse` |
| `src/ace/c/gfx.c` | Parse `,F` flag in `circle()`, emit `jsr _fillellipse` or error for arcs |
| `src/ace/c/acedef.h` | Add error message 31 if needed (fill not supported for arcs) |
| `examples/gfx/circles.b` | Visual demo of filled and unfilled circles/ellipses |
| `docs/ref.txt` | Document the `,F` parameter |
| `verify/tests/cases/syntax/circle_fill.b` | Compile-only test for filled circle |
| `verify/tests/cases/errors/circle_fill_arc.b` | Error test: fill + arc angles should fail |

## Risk Assessment

- **Low risk**: The change is additive — existing CIRCLE behavior is completely untouched unless `,F` is specified.
- **Reuses proven infrastructure**: TmpRas setup, AreaEnd, cleanup are copied from the working `_areafill` code path.
- **Standard Amiga API**: `AreaEllipse` is a well-documented graphics.library function available since Kickstart 1.0.
- **Pattern fills work automatically**: If the user has set an area pattern via `PATTERN`, the filled ellipse will respect it, since the area system inherits the RastPort's AreaPtrn.
