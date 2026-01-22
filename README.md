# ACE - Amiga BASIC Compiler

ACE is a complete BASIC compiler for the Amiga computer platform. It compiles BASIC source code into native Amiga executables by generating Motorola 68000 assembly code, bridging BASIC's ease of use with compiled performance.

Released under the GNU General Public License (GPL v2) in 1998.

## Features

- **Full type system** - Integers, single/double precision floats, strings, arrays, pointers, and structures
- **Amiga Intuition GUI integration** - Windows, menus, gadgets, and requesters
- **Graphics primitives** - Lines, circles, areas, and turtle graphics
- **File I/O** - Sequential and random access file operations
- **Event-driven programming** - Event traps and handlers
- **External library calls** - Access AmigaDOS and shared library functions
- **Sound support** - Audio playback and speech synthesis
- **Serial communication** - Serial port access
- **IFF picture support** - Load and display Amiga IFF images

## Installation

### Modern Development Setup

This modern version of ACE can be compiled with GCC (included in ADE, available on Aminet) and uses modern toolchains:
- **vasmm68k_mot** instead of a68k assembler
- **vlink** instead of blink linker

Key fixes in this version:
- Single precision floating point now works correctly (fixed variable type for `singleval` from float to LONG to work with mathffp library)
- Updated build scripts use modern toolchain (vasm/vlink)

### Traditional Amiga Installation

Installing ACE on an Amiga system:

1. **Unpack the archive** to a hard disk drawer (e.g., `sys:ACE`):
   ```
   lha -a x ace24.lha
   ```
   The `-a` switch preserves file attributes (e.g., the "s" bit on shell scripts).

2. **Add assigns and paths** to your `s:user-startup` (WB 2.x/3.x) or `s:startup-sequence` (WB 1.3):
   ```
   assign ACE: sys:ACE              ; Main ACE directory
   path ACE:bin add                 ; Add compiler to path
   assign ACElib: ACE:lib           ; bas finds scanned libraries here
   assign ACEbmaps: ACE:bmaps       ; ace looks here for .bmap files
   assign ACEinclude: ACE:include   ; app uses this for include files
   ```

3. **Reboot** your Amiga to activate the assigns and path.

Note: Hard disk recommended. For floppy-based systems, unpack to RAM disk and distribute across multiple floppies.

## Building

### Building the ACE Compiler

```bash
# Build with Makefile-ace (run from src/make/ directory)
make -f Makefile-ace           # Build ACE compiler (quiet mode)
make -f Makefile-ace V=1       # Build with verbose output
make -f Makefile-ace clean     # Remove all build artifacts
make -f Makefile-ace clean all # Clean rebuild
make -f Makefile-ace backup    # Backup current executable to ace.old
make -f Makefile-ace help      # Show help
```

The Makefile provides incremental builds, standard targets, and verbose/quiet modes. Requires GNU Make 3.80 or later with ADE shell environment.

### Building the Runtime Libraries (db.lib and startup.lib)

```bash
# Build both libraries (run from src/make/ directory)
make -f Makefile-lib           # Build db.lib and startup.lib
make -f Makefile-lib V=1       # Verbose output
make -f Makefile-lib clean     # Remove build artifacts
make -f Makefile-lib help      # Show all targets
```

Uses vbcc/vasm toolchain to compile C sources from `src/lib/c/`, assemble sources from `src/lib/asm/`, and create the libraries in `lib/`.

See `src/lib/README.md` for details about the libraries, including information about `ami.lib`.

### Compiling BASIC Programs

The `bas` wrapper script in `bin/` orchestrates the full pipeline:

```bash
bas <sourcefile>                    # Compile, assemble, link
bas <options> <sourcefile> <libs>   # With compiler options and extra libraries
```

The script uses vasm (assembler) and vlink (linker). For Workbench 1.3
compatibility, see `bin/1.3/ReadMe`.

**Build Pipeline:**
```
Source (.bas) → Preprocess (app) → Compile (ace) → Assemble (vasm) → Link (vlink) → Executable
```

Source files use `.b` or `.bas` extensions.

## Testing

ACE includes a comprehensive test suite for validation.

### Running Tests

```bash
# Run all tests
rx verify/tests/runner.rexx

# Run specific category
rx verify/tests/runner.rexx syntax      # Basic syntax tests
rx verify/tests/runner.rexx arithmetic  # Integer arithmetic tests
rx verify/tests/runner.rexx floats      # Floating point tests
rx verify/tests/runner.rexx control     # Control flow tests
rx verify/tests/runner.rexx errors      # Expected compilation failures
```

### Test Structure

```
verify/tests/
  runner.rexx       - ARexx test runner script
  cases/            - Test source files
    syntax/         - Basic syntax tests
    arithmetic/     - Integer arithmetic tests
    floats/         - Floating point tests
    control/        - Control flow tests
    errors/         - Expected compilation failures
  expected/         - Expected output for runtime verification
  results/          - Test run output (created at runtime)
```

### Test Levels

**Level 1: Compile-only**
- Verifies ACE produces `.s` assembly file
- Exit code 0 indicates success

**Level 2-4: Full pipeline** (when expected output exists)
- Compiles, assembles, links, and runs
- Compares output against `expected/testname.expected`

**Error Tests**
- Tests in `cases/errors/` are expected to FAIL compilation
- A passing error test means the compiler correctly rejected invalid code

### Adding New Tests

1. Create a `.b` file in the appropriate `cases/` subdirectory
2. Optionally create `expected/testname.expected` for output verification
3. For error tests, place in `cases/errors/` (compilation should fail)

Use descriptive names without spaces: `float_add.b`, not `float add.b`

## Project Structure

| Directory | Description |
|-----------|-------------|
| `src/ace/c/` | ACE compiler source (lexer, parser, code generator) |
| `src/ace/obj/` | Compiler build artifacts |
| `src/lib/c/` | Runtime library C sources |
| `src/lib/asm/` | Runtime library assembly sources |
| `src/lib/startup/` | Startup library source |
| `src/make/` | Build scripts and makefiles |
| `include/` | Amiga system header files |
| `lib/` | Built libraries (db.lib, startup.lib) |
| `bin/` | ACE compiler and build scripts |
| `bmaps/` | Binary maps for Amiga OS 39 shared libraries |
| `examples/` | Example programs (30+ categories) |
| `utils/` | Utility programs (fd2bmap, convert2ace, etc.) |
| `docs/` | Documentation files |
| `verify/tests/` | Test suite |
| `verify/scripts/` | Verification and build scripts |

## Technologies

- **Languages**: C (K&R style) and Motorola 68000 assembly
- **Target Platform**: Amiga 1.3, 2.x, 3.x
- **Build System**: GNU Make 3.80+ with ADE shell
- **Assembler**: vasm (vasmm68k_mot) - modern, or a68k - legacy
- **Linker**: vlink - modern, or blink - legacy
- **Amiga APIs**: Exec, Dos, Graphics, Intuition, Diskfont, DataTypes, Rexx

## Documentation

### User Documentation

- `docs/ace.txt` / `docs/ace.guide` - Main reference documentation
- `docs/ref.guide` - Language reference guide
- `docs/ACE_Tutorial.guide` - Tutorial for beginners
- `docs/history` - Version history and changes

### Developer Documentation

- `CLAUDE.md` - Development workflow guide (for Claude Code)
- `docs/SuperOptimizer.guide` - Optimization techniques

### Architecture Overview

ACE is a multi-pass compiler that translates BASIC to 68000 assembly:

1. **Lexical Analysis** (`lex.c`) - Tokenizes BASIC source
2. **Parsing** (`parse.c`, `parsevar.c`) - Recursive descent parser
3. **Expression Evaluation** (`expr.c`, `factor.c`) - Expression trees and type checking
4. **Statement Handling** (`statement.c`, `control.c`, `assign.c`) - Statement code generation
5. **Symbol Management** (`sym.c`, `symvar.c`) - Symbol table
6. **Code Generation** (`misc.c`) - Emits 68000 assembly
7. **Optimization** (`opt.c`) - Peephole optimizer

Main header: `src/ace/c/acedef.h` - Contains all type definitions, enums, and function prototypes.

## Example Programs

The `examples/` directory contains extensive examples organized by category:

- **Games** - Game implementations
- **Graphics** - Graphics demonstrations
- **GUI** - Interface examples (windows, menus, gadgets)
- **Fractals** - Mathematical visualizations
- **Turtle** - Logo-style turtle graphics
- **Astronomy** - Scientific calculations
- **Benchmarks** - Performance tests
- **File operations** - File I/O examples
- **Network/Ports** - Communications examples
- **Sound** - Audio and speech synthesis
- **IFF** - Image loading and display

## Development Notes

### Code Style

- K&R C style - original late-80s/early-90s conventions
- Function definitions use K&R style (parameters on separate lines)
- Extensive use of Amiga-specific types: `BYTE`, `SHORT`, `LONG`, `BOOL`, `BPTR`
- Direct Amiga API calls via exec, dos, graphics, intuition libraries
- Manual memory management with Amiga AllocMem/FreeMem

### Requirements

- Stack of 40000-65000 bytes required for compiler operations
- ACE assign (logical device) must be set to repository root
- Generated assembly goes to `.s` files, objects to `.o`, executables have no extension
- Temporary files typically go to `ram:t/` or `T:`

### Known Limitations

- K&R C rather than ANSI C (developed with Sozobon C v1.01)
- Single common header file for entire compiler (`acedef.h`)
- No source control was used in original development
- One small object module (`src/lib/obj/LoadIFFToWindow.o`) has no source (shared library stub for ilbm.lib)

## License

This project is licensed under the GNU General Public License v2. See the license file for details.

## History

ACE was originally developed by David Benn between November 1991 and September 1996. It was released as open source under the GPL in October 1998 (version 2.4 compiler, db.lib version 2.61).

ACE provides functionality comparable to Microsoft QuickBASIC or Turbo BASIC, specifically designed for Amiga development with full integration into the Amiga's native windowing and graphics systems.

The modern fork includes fixes for GCC compatibility, floating-point handling, and support for modern assemblers and linkers (vasm/vlink).

For the complete 1998 release notes from David Benn, see `docs/HISTORY-1998-Release.txt`.
