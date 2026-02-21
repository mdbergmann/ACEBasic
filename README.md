# ACE - Amiga BASIC Compiler

ACE is a complete BASIC compiler for the Amiga computer platform. It compiles BASIC source code into native Amiga executables by generating Motorola 68000/68020 assembly code, bridging BASIC's ease of use with compiled performance.

Originally released under the GNU General Public License (GPL v2) in 1998. Current version: **3.0**

## Quick Example

```basic
PRINT "Hello, Amiga!"
```

Compile and run:
```
bas hello
hello
Hello, Amiga!
```

ACE shines when tapping into the Amiga's native capabilities:

```basic
REM -- Open a centered window with a message
SCREEN 1,640,256,4,2
WINDOW 1,"ACE BASIC",(100,50)-(540,200),30,1

COLOR 1,0
PRINT "Welcome to ACE BASIC!"
PRINT
PRINT "A native Amiga BASIC compiler"
PRINT "generating 68000 assembly."

WHILE INKEY$=""
WEND

WINDOW CLOSE 1
SCREEN CLOSE 1
```

## Features

### Core Language
- **Full type system** - Integers, IEEE single-precision floats, strings, atoms, arrays, pointers, and structures
- **Closures and function pointers** - First-class function references with `@`, `BIND` for partial application, `INVOKE` for indirect calls, and `INVOKABLE` keyword for callback SUBs
- **CALLBACK SUBs** - SUBs that can be invoked via AmigaOS CallHookPtr() for system callbacks
- **68020 native code generation** - Native 68020 instructions by default (use `OPTION 2-` for 68000 compatibility)
- **Tail-call optimization** - Self-recursive tail calls optimized to jumps for constant stack usage (with `-O` or `OPTION O+`)
- **Rich string functions** - TRIM$, LTRIM$, RTRIM$, RINSTR, STARTSWITH, ENDSWITH, REPLACE$, REVERSE$, REPEAT$, LPAD$, RPAD$, FMT$ (sprintf-style formatting), and MID$ statement form
- **File I/O** - Sequential and random access file operations with buffered reading for performance
- **Event-driven programming** - Event traps and handlers
- **External library calls** - Access AmigaDOS and shared library functions

### GUI and Graphics
- **MUI (Magic User Interface)** - High-level BASIC wrappers for modern Amiga GUIs via the MUI submodule
- **GadTools integration** - Full support for GadTools-based gadgets with modern look and feel
- **Amiga Intuition GUI** - Windows, menus, gadgets, and requesters
- **AGA screen support** - Modes 7-12 with up to 256 colors (8-bit depth)
- **P96/RTG screen support** - Mode 13 for Picasso96/RTG graphics cards with up to 32-bit TrueColor depth and `COLOR r,g,b` syntax
- **Graphics primitives** - Lines, circles (including filled), areas, and turtle graphics (via submodule)
- **Graphics double buffering** - Include file and examples for smooth animation
- **IFF picture support** - Load and display Amiga IFF images

### Utilities and Libraries
- **Double-precision math** - IEEE 64-bit floating point (15+ significant digits) with full arithmetic, trigonometric, and string conversion
- **TCP/HTTP client** - Struct-based TCP client with SSL/TLS support, plus full HTTP/1.1 client with GET/POST/PUT, chunked transfers, streaming callbacks, and HTTPS via AmiSSL
- **Lisp-style list library** - Singly-linked lists with higher-order functions (map, filter, reduce, etc.) - requires OS 3.0+
- **ASSERT statement** - Runtime assertion checking for defensive programming
- **Sound support** - Audio playback, speech synthesis, and SAGA 16-bit audio (Vampire)
- **Serial communication** - Serial port access

## Installation

### Modern Development Setup

This modern version of ACE is compiled with the **VBCC** C compiler toolchain:
- **vc** (VBCC compiler) instead of GCC/Sozobon C
- **vasmm68k_mot** instead of a68k assembler
- **vlink** instead of blink linker

See `CHANGELOG.txt` for detailed version history.

### Amiga Installation

Run the `Install-ACE` script from Shell or double-click it from Workbench:

```
execute Install-ACE
```

The installer will:
1. Create the `ACE:` assign pointing to the current directory
2. Set up derived assigns (`ACElib:`, `ACEbmaps:`, `ACEinclude:`, `ACEsubmods:`)
3. Add `ACE:bin` to the command path
4. Optionally append assigns to `S:user-startup` for persistence across reboots
5. If an existing `ACE:` installation is found, offer to copy/upgrade files

A manual install is of course also still possible. Just copy the extracted folder where you want it and setup the assigns as mentioned above.

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

The Makefile provides incremental builds, standard targets, and verbose/quiet modes. Requires GNU Make 3.80 or later and the VBCC toolchain.

### Building the Runtime Libraries (db.lib and startup.lib)

```bash
# Build both libraries (run from src/make/ directory)
make -f Makefile-lib           # Build db.lib and startup.lib
make -f Makefile-lib V=1       # Verbose output
make -f Makefile-lib clean     # Remove build artifacts
make -f Makefile-lib help      # Show all targets
```

Uses the VBCC/vasm toolchain to compile C sources from `src/lib/c/`, assemble sources from `src/lib/asm/`, and create the libraries in `lib/`.

See `src/lib/README.md` for details about the libraries.

### Compiling BASIC Programs

The `bas` wrapper script in `bin/` orchestrates the full pipeline:

```bash
bas <sourcefile>                    # Compile, assemble, link
bas <options> <sourcefile> <libs>   # With compiler options and extra libraries
```

The script also parses `REM #using` directives in the first 20 lines of your source to automatically link additional object files:

```basic
REM #using ace:submods/list/list.o
REM #using ace:submods/mui/mui.o
```

The script uses vasm (assembler) and vlink (linker). For Workbench 1.3
compatibility, see `bin/1.3/ReadMe`.

**Build Pipeline:**
```
Source (.bas) → Preprocess (yap) → Compile (ace) → Assemble (vasm) → Link (vlink) → Executable
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
| `submods/` | Reusable BASIC libraries (MUI, list, HTTP, turtle, etc.) |
| `utils/` | Utility programs (fd2bmap, convert2ace, yap preprocessor) |
| `docs/` | Documentation files |
| `verify/tests/` | Test suite |
| `verify/scripts/` | Verification and build scripts |

## Technologies

- **Languages**: C (K&R style) and Motorola 68000/68020 assembly
- **Target Platform**: AmigaOS 2.x, 3.x (68020+)
- **Build System**: GNU Make 3.80+ with VBCC toolchain
- **C Compiler**: VBCC (vc)
- **Assembler**: vasm (vasmm68k_mot)
- **Linker**: vlink
- **Float Format**: IEEE 754 single-precision (via mathieeesingbas.library / mathieeesingtrans.library)
- **Amiga APIs**: Exec, Dos, Graphics, Intuition, GadTools, MUI, Diskfont, DataTypes, Rexx, Picasso96, AmiSSL, bsdsocket

## Documentation

### User Documentation

- `docs/ace.txt` / `docs/ace.guide` - Main reference documentation
- `docs/ref.guide` - Language reference guide
- `docs/ACE_Tutorial.guide` - Tutorial for beginners
- `docs/history` - Version history and changes
- `docs/SuperOptimizer.guide` - Optimization techniques

### IDE Integration

- **CubicIDE ACE Plugin** - Syntax highlighting and IDE integration for CubicIDE
  - [Aminet](https://aminet.net/package/dev/basic/CubicIDE-ACE)
  - [GitHub](https://github.com/mdbergmann/amigastuff/tree/main/CubicIDE-ACE)

The included AIDE is there for legacy reasons. It may or may not work, it's up to you.

### Architecture Overview

ACE is a multi-pass compiler that translates BASIC to 68000 assembly:

1. **Lexical Analysis** (`lex.c`) - Tokenizes BASIC source
2. **Parsing** (`parse.c`, `parsevar.c`) - Recursive descent parser
3. **Expression Evaluation** (`expr.c`, `factor.c`) - Expression trees and type checking
4. **Statement Handling** (`statement.c`, `control.c`, `assign.c`) - Statement code generation
5. **SUB/FUNCTION Calls** (`invoke.c`) - Call site code generation
6. **Symbol Management** (`sym.c`, `symvar.c`) - Symbol table
7. **Code Generation** (`misc.c`, `codegen.c`) - Emits 68000 assembly with reusable helpers
8. **Optimization** (`opt.c`) - Peephole optimizer with tail-call optimization

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

## Submodules

Reusable BASIC libraries in `submods/`. Include the header with `#include <submods/module.h>` and link the compiled module via the bas script: `bas myprogram ace:submods/module/module.o`

### MUI Submodule (`submods/mui/`)

High-level MUI (Magic User Interface) support for creating modern Amiga GUIs. Provides BASIC wrappers for windows, buttons, lists, menus, tabs, and more.

Documentation: `docs/MUI-Submod.guide`

### List Submodule (`submods/list/`)

Lisp-style singly-linked list implementation with:
- Multiple data types (SHORTINT, LONGINT, SINGLE, STRING, nested lists)
- Builder pattern for easy list construction
- Higher-order functions: `LMap`, `LFilter`, `LReduce`, `LForEach`
- Both non-destructive and in-place (destructive) variants

Requires AmigaOS 3.0+ (uses AllocVec). Closures with `INVOKABLE` keyword needed for callbacks.

### TCP Client Submodule (`submods/tcpclient/`)

Struct-based TCP client with optional SSL/TLS support via AmiSSL. The caller owns `TcpConn` structs, so there is no connection limit. Provides raw send/receive, buffered reads, and line-oriented reading with automatic CR/LF handling.

- **Connection**: `TcpOpen` (plain or SSL), `TcpClose`, `TcpInit`, `TcpCleanup`
- **Send**: `TcpSend` (raw bytes)
- **Receive**: `TcpRecv` (unbuffered), `TcpRecvBuf` (buffered), `TcpRecvLine` (line-oriented), `TcpBufFlush`

Requires bsdsocket.library (AmiTCP, Roadshow). SSL requires AmiSSL.

### HTTP Client Submodule (`submods/httpclient/`)

Full HTTP/1.1 client library built on tcpclient, with three API tiers:
- **High-level**: One-call functions (`HttpGet`, `HttpPost`, `HttpPut`, `HttpRequest`)
- **Streaming**: Callback-based transfers for large data (`HttpGetStream`, `HttpPostStream`, `HttpPutStream`)
- **Low-level**: Struct-based control (`HttpOpen`, `HttpSetHeader`, `HttpSendRequest`, `HttpReadBody`, `HttpClose`)

Supports HTTP and HTTPS (via AmiSSL), chunked transfer encoding, custom headers, and URL encoding. Requires bsdsocket.library (AmiTCP, Roadshow).

### Double-Precision Math Submodule (`submods/dp-float/`)

IEEE 64-bit double-precision floating point for ACE BASIC programs. Wraps the Amiga's `mathieeedoubbas.library` and `mathieeedoubtrans.library` via inline ASSEM blocks, providing 15+ significant digits of precision (vs. ~7 for ACE's native IEEE single-precision SINGLE type).

Doubles are 8-byte values stored at ADDRESS pointers allocated with `DpNew`. All operations take and return ADDRESS parameters.

**32 public functions:**
- **Lifecycle**: `DpOpen`, `DpClose`, `DpNew`
- **Conversion**: `DpFromLong`, `DpToLong`, `DpFromSingle`, `DpToSingle`, `DpFromStr`, `DpToStr$`
- **Arithmetic**: `DpAdd`, `DpSub`, `DpMul`, `DpDiv`, `DpPow`
- **Comparison**: `DpCmp` (returns +1/0/-1)
- **Unary**: `DpAbs`, `DpNeg`, `DpCeil`, `DpFloor`
- **Trigonometric** (radians): `DpSin`, `DpCos`, `DpTan`, `DpAsin`, `DpAcos`, `DpAtan`, `DpSinCos`
- **Hyperbolic**: `DpSinh`, `DpCosh`, `DpTanh`
- **Exponential/Log**: `DpExp`, `DpLog`, `DpLog10`, `DpSqrt`

**Usage example:**
```basic
REM #using ace:submods/dp-float/dp-float.o
#include <submods/dp-float.h>

IF DpOpen THEN
  a = DpNew : b = DpNew : r = DpNew

  ' Arithmetic with integers
  DpFromLong(a, 355)
  DpFromLong(b, 113)
  DpDiv(r, a, b)
  PRINT "355/113 = "; DpToStr$(r)   ' 3.14159292035398

  ' Parse from string, use transcendentals
  DpFromStr(a, "3.141592653589793")
  DpSin(r, a)
  PRINT "sin(pi) = "; DpToStr$(r)   ' ~0

  ' Convert to/from ACE SINGLE
  DpFromSingle(a, 1.5)
  sv! = DpToSingle(a)

  DpClose
END IF
```

Compile: `bas -m dp-float` (module), then `bas myprogram ace:submods/dp-float/dp-float.o` or use `REM #using ace:submods/dp-float/dp-float.o` in your source.

### Turtle Graphics Submodule (`submods/turtle/`)

Logo-style turtle graphics with commands for movement (`TgForward`, `TgBack`), turning (`TgTurn`, `TgTurnLeft`, `TgTurnRight`), pen control (`TgPenUp`, `TgPenDown`), and state queries (`TgHeading`, `TgXcor`, `TgYcor`). Automatic pixel aspect ratio detection with manual override for different screen modes.

### SagaSound Submodule (`submods/sagasound/`)

Direct hardware access to the Vampire SAGA 16-bit audio chip. Supports 16 audio channels (vs. 4 on standard Amiga), 8/16-bit samples, stereo volume control, sample rates up to 56 kHz, and oneshot/looping modes.

### Other Submodules

- **complex** - Complex number arithmetic
- **easyrequest** - Simplified requester dialogs
- **fontreq** - Font selection requester
- **listbox** - ListBox gadget wrapper
- **menu** - Menu building utilities
- **runprog** - Program execution helper
- **wbarg** - Workbench argument handling

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

- K&R C rather than ANSI C (originally developed with Sozobon C v1.01, now built with VBCC)
- Single common header file for entire compiler (`acedef.h`)
- No source control was used in original development
- One small object module (`src/lib/obj/LoadIFFToWindow.o`) has no source (shared library stub for ilbm.lib)

## License

This project is licensed under the GNU General Public License v2. See the license file for details.

## History

ACE was originally developed by David Benn between November 1991 and September 1996. It was released as open source under the GPL in October 1998 (version 2.4 compiler, db.lib version 2.61).

ACE provides functionality comparable to Microsoft QuickBASIC or Turbo BASIC, specifically designed for Amiga development with full integration into the Amiga's native windowing and graphics systems.

### Version 3 Fork (2024-present)

The v3 fork adds significant new features and modernizes the toolchain. The move to VBCC, IEEE 754 floats, and 68020 as the default target makes v3 incompatible with older C compilers (GCC/ADE, Sozobon C) and AmigaOS 1.3. Minimum requirement is now AmigaOS 2.0 with a 68020 CPU.

- **v2.5** - AGA screen support, vasm/vlink toolchain, GNU Makefile build system
- **v2.6** - GadTools gadgets, ASSERT statement, 68020 native code generation
- **v2.7** - Closures and function pointers, MUI submodule, filled circles/ellipses, callback SUBs
- **v2.7.1** - ELSEIF keyword, LCASE$ function, list submodule with higher-order functions
- **v2.8** - YAP preprocessor, INVOKABLE keyword, REM #using directive, installer, major compiler refactoring
- **v2.9** - Struct enhancements (typed arrays, nested access, typed pointers, self-referential structs), 12 new string functions, P96/RTG screens (mode 13), tail-call optimization, buffered file I/O, HTTP/HTTPS client submodule, DP-float submodule, SagaSound submodule, turtle graphics submodule, codegen abstraction
- **v3.0** - VBCC toolchain migration (replacing GCC/ADE), IEEE 754 single-precision floats (replacing Motorola FFP), ATOM primitive type, EXIT WHILE/EXIT REPEAT, FREE statement, SUB tracing (-t flag, TRON/TROFF), CyberGfx screens (mode 14), IFF picture submodule, runtime library optimizations

See `CHANGELOG.txt` for full details. For the original 1998 release notes, see `docs/HISTORY-1998-Release.txt`.
