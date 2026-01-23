# Changelog

## v2.5 (2026-01-22)

### New Features

- **AGA Screen Support (modes 7-12)** - Full support for AGA chipset screens with up to 256 colors (8-bit depth), including new SCREEN modes for AGA resolutions.

### Toolchain Changes

- **vasm/vlink replaces legacy assembler/linker** - The `bas` compile/link script now uses vasm and vlink (contributed by/discussed with Frank Wille) as the standard toolchain for assembling and linking programs.

### Bug Fixes

- **FFP/vbcc floating-point compatibility fix** - Fixed FFP (Fast Floating Point) handling in the runtime library for compatibility with the vbcc-compiled code. Affects functions like `sleep_for_secs` and general float operations.

### Build System

- **GNU Makefile build system** - New `Makefile-ace` (compiler) and `Makefile-lib` (runtime libraries) replace legacy build scripts. Build from `src/make/`.
- **Rebuilt runtime libraries** - Fresh `db.lib` and `startup.lib` compiled with the new toolchain.
- **Legacy build system removed** - Old AmigaDOS build scripts have been retired.

### Project Housekeeping

- **Directory restructured** - `prgs/` renamed to `examples/`, build files moved to `src/make/`, test/verification files organized under `verify/`.
- **Test suite added** - 35 test cases covering syntax, arithmetic, floats, control flow, and expected-error scenarios.
- **Documentation consolidated** - Single comprehensive `README.md` replaces scattered `.doc` files.
