# AGA Screen Support Implementation Plan

## Related Documentation

See [README.md](../README.md) for general project documentation, build instructions, and architecture details.

## Development Branch

**This feature must be developed on a separate branch.** Create a feature branch before starting implementation:

```bash
git checkout -b feature/aga-screen-support
```

Merge to master only after all phases are complete and tested.

## Overview

Add AGA (Advanced Graphics Architecture) screen support to ACE BASIC compiler, enabling:
- 8 bitplanes (256 colors) instead of current 6 bitplanes (64 colors)
- HAM8 mode (262,144 colors from 256-color palette)
- Higher resolutions up to 1280 pixels width (super-hires)
- 24-bit palette via SetRGB32()

## Current State

**Hardcoded OCS/ECS limits in `src/lib/asm/scrwin.s` (lines 399-417):**
- Max width: 640 pixels
- Max height: 512 pixels
- Max depth: 6 bitplanes
- Modes: 1-6 only

**Current modes:**
| Mode | Description | ModeID |
|------|-------------|--------|
| 1 | Lores (320px) | $0000 |
| 2 | Hires (640px) | $8000 |
| 3 | Lores Interlaced | $0004 |
| 4 | Hires Interlaced | $8004 |
| 5 | HAM6 | $0800 |
| 6 | Extra-Halfbrite | $0080 |

**Palette:** Uses `SetRGB4()` with 4-bit RGB (0-15), max 64 colors (lines 722-774)

## Approach

**Extend existing modes (7-12) while keeping 1-6 unchanged for backward compatibility.**

**New AGA modes:**
| Mode | Description | ModeID | Max Depth |
|------|-------------|--------|-----------|
| 7 | Lores AGA | $00000000 | 8 (256 colors) |
| 8 | Hires AGA | $00008000 | 8 (256 colors) |
| 9 | Super-Hires AGA | $00008020 | 8 (256 colors) |
| 10 | HAM8 Lores | $00000800 | 8 (262,144 colors) |
| 11 | HAM8 Hires | $00008800 | 8 (262,144 colors) |
| 12 | HAM8 Super-Hires | $00008820 | 8 (262,144 colors) |

## Files to Modify

### Primary Changes

1. **`src/lib/asm/scrwin.s`** - Main runtime screen handling
   - Lines 399-417: Update validation limits
   - Lines 457-489: Add new mode handlers for 7-12
   - Add `_openthescreen_aga` using `OpenScreenTagList()` for AGA modes
   - Lines 722-774: Update `_palette` to use `SetRGB32()` for depth > 6

2. **`src/lib/asm/scrwin_data.s`** - Data structures
   - Add `_aga_modeid` storage
   - Add `_aga_taglist` for `OpenScreenTagList()` tags
   - Add LVO references for `_LVOOpenScreenTagList`, `_LVOSetRGB32`

### Secondary Changes

3. **`src/lib/asm/gfx.s`** - Graphics functions
   - Verify color limits work correctly for 256-color modes

4. **`src/lib/c/scrfunc.c`** or new file - Chipset detection
   - Add `_chipset` function returning 0/1/2 for OCS/ECS/AGA

5. **`src/ace/c/gfx.c`** - Compiler graphics statements
   - Add `CHIPSET` keyword parsing (like existing `SCREEN()` function)
   - Generate call to `_chipset` runtime function

6. **`src/ace/c/acedef.h`** - Add `chipsetsym` keyword constant

## Implementation Phases

**Priority:** 256-color modes (7-9) first, HAM8 modes (10-12) later.
Each phase is self-contained and testable before proceeding to the next.

---

### Phase 1: Expand Validation Limits

#### Phase 1.1: Implementation

**Goal:** Allow larger parameter values without changing behavior.

**Files to modify:**
- `src/lib/asm/scrwin.s` (lines 401, 411, 417)

**Changes:**
1. Line 401: Change `cmpi.w #640,d1` to `cmpi.w #1280,d1`
2. Line 411: Change `cmpi.w #6,d3` to `cmpi.w #8,d3`
3. Line 417: Change `cmpi.w #6,d4` to `cmpi.w #12,d4`

**Completion Criteria:**
- [ ] All changes applied to `scrwin.s`
- [ ] Library builds without errors (`makedb`)

---

#### Phase 1.2: Testing

**Goal:** Verify expanded limits don't break existing functionality.

**Verification Checklist:**
- [ ] Existing test: `SCREEN 1,320,200,5,1` still opens correctly
- [ ] Existing test: `SCREEN 1,640,200,4,2` still opens correctly
- [ ] Existing test: `examples/gfx/ham.b` still works
- [ ] Mode 7+ attempts should fail gracefully (no handler yet)

---

### Phase 2: Add Chipset Detection Function

#### Phase 2.1: Implementation - Runtime Function

**Goal:** Add runtime function to detect OCS/ECS/AGA.

**Files to modify:**
- `src/lib/asm/scrwin.s` or new file `src/lib/asm/chipset.s`

**Changes:**
1. Add runtime function `_chipset` that returns 0=OCS, 1=ECS, 2=AGA
2. Rebuild library with `makedb`

**Completion Criteria:**
- [ ] `_chipset` function implemented in assembly
- [ ] Library builds without errors (`makedb`)

---

#### Phase 2.2: Implementation - Compiler Support

**Goal:** Add CHIPSET keyword to BASIC compiler.

**Files to modify:**
- `src/ace/c/acedef.h` - add `chipsetsym` constant
- `src/ace/c/lex.c` - add CHIPSET keyword recognition
- `src/ace/c/gfx.c` - add CHIPSET parsing and code generation

**Changes:**
1. Add `chipsetsym` to keyword constants in `acedef.h`
2. Add "CHIPSET" to keyword table in `lex.c`
3. Add CHIPSET parsing that generates call to `_chipset` runtime function

**Completion Criteria:**
- [ ] Compiler builds without errors (`make -f Makefile-ace`)
- [ ] CHIPSET keyword recognized by lexer

---

#### Phase 2.3: Testing

**Goal:** Verify CHIPSET function works on all chipset types.

**Test Program (`test_chipset.b`):**
```basic
c = CHIPSET
IF c = 0 THEN PRINT "OCS detected"
IF c = 1 THEN PRINT "ECS detected"
IF c = 2 THEN PRINT "AGA detected"
```

**Verification Checklist:**
- [ ] `test_chipset.b` compiles and links
- [ ] On A500 (OCS): returns 0
- [ ] On A600 (ECS): returns 1
- [ ] On A1200 (AGA): returns 2

---

### Phase 3: Add Mode 7 (Lores AGA 256-color)

#### Phase 3.1: Implementation - Data Structures

**Goal:** Add AGA-specific data structures for tag-based screen opening.

**Files to modify:**
- `src/lib/asm/scrwin_data.s`

**Changes:**
1. Add `_aga_modeid` storage (LONG)
2. Add `_aga_taglist` buffer for `OpenScreenTagList()` tags
3. Add LVO references for `_LVOOpenScreenTagList`

**Completion Criteria:**
- [ ] Data structures added to `scrwin_data.s`
- [ ] Library builds without errors (`makedb`)

---

#### Phase 3.2: Implementation - Mode Handler

**Goal:** Add mode 7 handler and AGA screen opening routine.

**Files to modify:**
- `src/lib/asm/scrwin.s`

**Changes:**
1. Add `_lores_aga` handler after `_halfbrite` label
2. Add `_openthescreen_aga` routine using `OpenScreenTagList()`
3. ModeID for mode 7: $00000000 (LORES_KEY)

**Completion Criteria:**
- [ ] Mode 7 handler added to `scrwin.s`
- [ ] `_openthescreen_aga` routine implemented
- [ ] Library builds without errors (`makedb`)

---

#### Phase 3.3: Testing

**Goal:** Verify mode 7 opens correctly on AGA systems.

**Test Program (`test_aga_mode7.b`):**
```basic
IF CHIPSET < 2 THEN PRINT "AGA required": END
SCREEN 1,320,200,8,7
WINDOW 1,,(0,0)-(320,200),32,1
PRINT "256-color AGA Lores"
SLEEP FOR 3
SCREEN CLOSE 1
```

**Verification Checklist:**
- [ ] `test_aga_mode7.b` compiles and links
- [ ] Screen opens on A1200/AGA emulator
- [ ] Screen has 8 bitplanes (256 colors available)
- [ ] Existing OCS/ECS modes (1-6) still work
- [ ] Mode 7 on OCS/ECS fails gracefully (returns to CLI)

---

### Phase 4: Add Mode 8 (Hires AGA 256-color)

#### Phase 4.1: Implementation

**Goal:** Add 640-pixel wide 256-color mode.

**Files to modify:**
- `src/lib/asm/scrwin.s`

**Changes:**
1. Add `_hires_aga` handler (mode 8)
2. ModeID for mode 8: $00008000 (HIRES_KEY)

**Completion Criteria:**
- [ ] Mode 8 handler added to `scrwin.s`
- [ ] Library builds without errors (`makedb`)

---

#### Phase 4.2: Testing

**Goal:** Verify mode 8 opens correctly with hires dimensions.

**Test Program (`test_aga_mode8.b`):**
```basic
IF CHIPSET < 2 THEN PRINT "AGA required": END
SCREEN 1,640,256,8,8
WINDOW 1,,(0,0)-(640,256),32,1
PRINT "256-color AGA Hires (640x256)"
SLEEP FOR 3
SCREEN CLOSE 1
```

**Verification Checklist:**
- [ ] `test_aga_mode8.b` compiles and links
- [ ] Screen opens at 640x256 with 8 bitplanes
- [ ] Mode 7 still works
- [ ] Modes 1-6 still work

---

### Phase 5: Add Mode 9 (Super-Hires AGA)

#### Phase 5.1: Implementation

**Goal:** Add 1280-pixel wide mode for productivity.

**Files to modify:**
- `src/lib/asm/scrwin.s`

**Changes:**
1. Add `_superhires_aga` handler (mode 9)
2. ModeID for mode 9: $00008020 (SUPER_KEY)

**Completion Criteria:**
- [ ] Mode 9 handler added to `scrwin.s`
- [ ] Library builds without errors (`makedb`)

---

#### Phase 5.2: Testing

**Goal:** Verify mode 9 opens correctly with super-hires dimensions.

**Test Program (`test_aga_mode9.b`):**
```basic
IF CHIPSET < 2 THEN PRINT "AGA required": END
SCREEN 1,1280,256,4,9
WINDOW 1,,(0,0)-(1280,256),32,1
PRINT "Super-Hires AGA (1280x256)"
SLEEP FOR 3
SCREEN CLOSE 1
```

**Verification Checklist:**
- [ ] `test_aga_mode9.b` compiles and links
- [ ] Screen opens at 1280x256
- [ ] Modes 7-8 still work
- [ ] Modes 1-6 still work

---

### Phase 6: Update Palette for 256 Colors

#### Phase 6.1: Implementation

**Goal:** Enable PALETTE command to work with colors 0-255 on AGA screens.

**Files to modify:**
- `src/lib/asm/scrwin.s` (lines 722-774)

**Changes:**
1. Expand color-id limit from 63 to 255 (line 730)
2. Add depth check: if depth > 6, use SetRGB32; else use SetRGB4
3. For SetRGB32: multiply FFP value by $FFFFFFFF instead of 15

**Completion Criteria:**
- [ ] Color limit expanded to 255
- [ ] SetRGB32 path added for depth > 6
- [ ] Library builds without errors (`makedb`)

---

#### Phase 6.2: Testing

**Goal:** Verify PALETTE works with 256 colors on AGA and doesn't break OCS/ECS.

**Test Program (`test_aga_palette.b`):**
```basic
IF CHIPSET < 2 THEN PRINT "AGA required": END
SCREEN 1,320,200,8,7
WINDOW 1,,(0,0)-(320,200),32,1
FOR i = 0 TO 255
  PALETTE i, i/255, 0, (255-i)/255
NEXT
FOR i = 0 TO 255
  COLOR i: LINE (i,0)-(i,199)
NEXT
SLEEP FOR 5
SCREEN CLOSE 1
```

**Verification Checklist:**
- [ ] `test_aga_palette.b` compiles and links
- [ ] All 256 colors display correctly (gradient visible)
- [ ] Palette on OCS/ECS modes (depth<=6) still uses SetRGB4
- [ ] `PALETTE 0,1,0,0` on mode 1 still works

---

### Phase 7: Add HAM8 Modes (10-12) - Optional

#### Phase 7.1: Implementation

**Goal:** Add HAM8 support for 262,144 colors from 256-palette.

**Files to modify:**
- `src/lib/asm/scrwin.s`

**Changes:**
1. Add `_ham8_lores` handler (mode 10, ModeID $0800)
2. Add `_ham8_hires` handler (mode 11, ModeID $8800)
3. Add `_ham8_superhires` handler (mode 12, ModeID $8820)

**Completion Criteria:**
- [ ] Mode 10 handler added
- [ ] Mode 11 handler added
- [ ] Mode 12 handler added
- [ ] Library builds without errors (`makedb`)

---

#### Phase 7.2: Testing

**Goal:** Verify HAM8 modes open correctly on AGA systems.

**Test Program (`test_aga_ham8.b`):**
```basic
IF CHIPSET < 2 THEN PRINT "AGA required": END
SCREEN 1,320,200,8,10
WINDOW 1,,(0,0)-(320,200),32,1
PRINT "HAM8 Mode - 262,144 colors"
SLEEP FOR 3
SCREEN CLOSE 1
```

**Verification Checklist:**
- [ ] `test_aga_ham8.b` compiles and links
- [ ] HAM8 screen opens with 8 bitplanes
- [ ] Modes 7-9 still work
- [ ] Modes 1-6 still work

---

### Phase 8: Documentation and Final Testing

#### Phase 8.1: Documentation

**Goal:** Document all new features for users.

**Files to modify:**
- `docs/ref.txt` or `docs/ace.guide`

**Changes:**
1. Document modes 7-12 with parameters and requirements
2. Document CHIPSET function
3. Add example programs to `examples/`

**Completion Criteria:**
- [ ] SCREEN mode 7-12 documented
- [ ] CHIPSET function documented
- [ ] Example programs added

---

#### Phase 8.2: Final Integration Testing

**Goal:** Comprehensive testing of all features together.

**Verification Checklist:**
- [ ] All existing examples in `examples/gfx/` still work
- [ ] New test programs work on AGA emulator
- [ ] New test programs fail gracefully on OCS/ECS
- [ ] Documentation is complete and accurate
- [ ] No regressions in existing functionality

**Backward Compatibility Tests:**
- [ ] Run `examples/gfx/ham.b` (mode 5) - must still work
- [ ] Run `examples/gfx/ehb.b` (mode 6) - must still work
- [ ] Run `examples/Screen.b` - must still work

**Environment:**
- Test with FS-UAE configured for A1200 (AGA chipset)
- Verify graceful failure on OCS/ECS (A500 config)

---

## Technical Details

### Chipset Detection Function

Query `GfxBase->ChipRevBits0` to detect chipset:

```asm
_chipset:
    movea.l _GfxBase,a0
    move.b  $ec(a0),d0      ; GfxBase->ChipRevBits0 (offset 236)

    ; Check for AGA (GFXB_AA_ALICE = bit 2, GFXB_AA_LISA = bit 3)
    btst    #2,d0           ; AA_ALICE?
    bne.s   _is_aga
    btst    #3,d0           ; AA_LISA?
    bne.s   _is_aga

    ; Check for ECS (GFXB_HR_AGNUS = bit 0, GFXB_HR_DENISE = bit 1)
    btst    #0,d0           ; HR_AGNUS?
    bne.s   _is_ecs
    btst    #1,d0           ; HR_DENISE?
    bne.s   _is_ecs

    ; OCS
    moveq   #0,d0
    rts
_is_ecs:
    moveq   #1,d0
    rts
_is_aga:
    moveq   #2,d0
    rts
```

**BASIC usage:** `IF CHIPSET >= 2 THEN SCREEN 1,320,200,8,7`

### OpenScreenTagList Implementation

For AGA modes, use tag-based screen opening instead of NewScreen structure:

```asm
_openthescreen_aga:
    lea     _aga_taglist,a0
    ; SA_Width tag
    move.l  #$80000023,(a0)+    ; SA_Width
    move.l  d1,(a0)+            ; width value
    ; SA_Height tag
    move.l  #$80000024,(a0)+    ; SA_Height
    move.l  d2,(a0)+            ; height value
    ; SA_Depth tag
    move.l  #$80000025,(a0)+    ; SA_Depth
    move.l  d3,(a0)+            ; depth value
    ; SA_DisplayID tag (the AGA ModeID)
    move.l  #$80000032,(a0)+    ; SA_DisplayID
    move.l  _aga_modeid,(a0)+
    ; SA_Type tag
    move.l  #$8000002D,(a0)+    ; SA_Type
    move.l  #$000F,(a0)+        ; CUSTOMSCREEN
    ; TAG_DONE
    clr.l   (a0)+

    movea.l _IntuitionBase,a6
    sub.l   a0,a0               ; NewScreen = NULL
    lea     _aga_taglist,a1
    jsr     _LVOOpenScreenTagList(a6)
```

### SetRGB32 for 24-bit Palette

```asm
_use_rgb32:
    ; Convert FFP 0.0-1.0 to 32-bit unsigned
    ; Multiply by $FFFFFFFF (or use shift trick)
    movea.l _GfxBase,a6
    movea.l _ViewPort,a0
    move.w  _color_id,d0
    move.l  _red,d1         ; 32-bit red
    move.l  _green,d2       ; 32-bit green
    move.l  _blue,d3        ; 32-bit blue
    jsr     _LVOSetRGB32(a6)
```

## Risk Mitigation

1. **Backward compatibility:** Modes 1-6 unchanged, existing code works
2. **Graceful degradation:** AGA modes on OCS/ECS will fail screen open (return NULL)
3. **Incremental approach:** Each phase verified before proceeding
4. **Runtime detection:** Depth check determines SetRGB4 vs SetRGB32

## References

- `include/graphics/ModeID.h` - Amiga ModeID constants
- `include/intuition/Screens.h` - SA_* tag definitions
- `include/funcs/graphics_funcs.h` - SetRGB32 declaration (line 185)
