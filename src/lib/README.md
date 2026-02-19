# ACE Runtime Libraries

This directory contains the source code for building ACE's runtime libraries.

## Libraries Overview

| Library | Source | Build |
|---------|--------|-------|
| `db.lib` | `c/` and `asm/` | Built via `Makefile-lib` |
| `startup.lib` | `startup/` | Built via `Makefile-lib` |
| `ami.lib` | **No source** | Pre-built binary |

## Building db.lib and startup.lib

From `src/make/`:
```
make -f Makefile-lib
```

Uses vbcc/vasm toolchain to produce Amiga hunk format libraries.

## About ami.lib

`ami.lib` is a pre-built binary library (~90KB) included with the original ACE distribution. **There is no source code for it in this project.**

### What ami.lib provides

| Category | Functions | Description |
|----------|-----------|-------------|
| Amiga LVO stubs | `_LVOOpenLibrary`, `_LVOWrite`, etc. | Standard Amiga system call stubs |
| C library | `putchar`, `sprintf` | Standard C runtime functions |
| Float routines | `fpa`, `arnd`, `afp` | ACE-specific float-to-ASCII conversion |

### Why ami.lib is needed

The ACE runtime (db.lib) and programs compiled with ACE depend on functions from ami.lib:
- C library functions like `putchar` and `sprintf` for I/O
- Float ASCII conversion routines
- Amiga system call stubs for library function invocations

### Can vbcc's amiga.lib replace ami.lib?

**No.** vbcc's `amiga.lib` only provides Amiga LVO stubs. It does not include:
- C library functions (`putchar`, `sprintf`)
- ACE-specific float routines (`fpa`, `arnd`, `afp`)

### Rebuilding ami.lib (if needed)

Since no source exists, options include:

1. **Build a replacement** by combining:
   - `vlibos3:amiga.lib` - Amiga system stubs from vbcc
   - `vlibos3:vc.lib` - vbcc's C library
   - Custom float routines (`fpa`, `arnd`, `afp`) - would need to be written

2. **Find original source** - ami.lib was likely derived from a public domain C library from the early 90s Amiga era (possibly Matt Dillon's DICE or similar)

3. **Disassemble and modify** - Extract routines from the existing binary

The float routines are the most difficult part - they convert IEEE 754 floating point numbers to ASCII strings and vice versa.

## Directory Structure

```
src/lib/
├── asm/           # Assembly modules for db.lib
├── c/             # C modules for db.lib
├── startup/       # startup.s source for startup.lib
├── obj/           # Build output (not in repo)
└── README.md      # This file
```

## Link Order

When linking ACE programs, libraries must be specified in this order:
```
startup.lib db.lib ami.lib
```
