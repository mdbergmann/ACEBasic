# Changelog

## v2.6 (2026-01-25)

### New Features

- **GadTools Gadget Integration** - Full support for GadTools-based gadgets with modern Amiga look and feel. New syntax: `GADGET id, status, label$, (x1,y1)-(x2,y2), kind [, TAG=value ...]`
- **Gadget Kinds** - Support for BUTTON, CHECKBOX, INTEGER, STRING, LISTVIEW, MX (mutual exclude), CYCLE, PALETTE, SCROLLER, SLIDER, TEXT, and NUMBER gadgets.
- **GADGET FONT** - New syntax to set font for GadTools gadgets: `GADGET FONT name$, size`
- **GADGET SETATTR/GETATTR** - Runtime modification and querying of gadget attributes via tags.

### Documentation

- **txt2guide.rb** - Ruby script to auto-generate AmigaGuide documentation from text sources (ref.txt, ace.txt).

### Testing

- **GadTools test suite** - New `gtgadgets` test category for GadTools gadgets.
- **Legacy gadgets tests** - Separate `legacygadgets` category for original BOOPSI gadgets.

---

## v2.5 (2026-01-22)

### New Features

- **AGA Screen Support (modes 7-12)** - Full support for AGA chipset screens with up to 256 colors (8-bit depth).

### Toolchain Changes

- **vasm/vlink replaces legacy assembler/linker** - Uses vasm and vlink as the standard toolchain.

### Bug Fixes

- **FFP/vbcc floating-point compatibility fix** - Fixed FFP handling in runtime library for vbcc compatibility.

### Build System

- **GNU Makefile build system** - New `Makefile-ace` and `Makefile-lib` in `src/make/`.
- **Rebuilt runtime libraries** - Fresh `db.lib` and `startup.lib`.

### Project Housekeeping

- **Directory restructured** - `prgs/` renamed to `examples/`, organized `verify/` for tests.
- **Test suite added** - 35 test cases covering syntax, arithmetic, floats, control flow.
- **Documentation consolidated** - Single `README.md`.
