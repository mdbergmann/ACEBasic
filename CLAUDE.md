# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow - CRITICAL

**ALWAYS work in small, incremental steps. Only proceed to the next step when the previous step has been verified working.**

### The Small Steps Principle

1. **Make ONE change at a time** - Don't bundle multiple changes together
2. **Verify it works** - Test, build, or run verification before continuing
3. **Only then proceed** - Move to the next change only after verification passes
4. **Document what worked** - Update status files (e.g., laststep-problems.txt)

### Why This Matters

- **Amiga environment is fragile** - Path handling, toolchain differences, AmigaOS quirks
- **Debugging is harder** - Limited tools, emulator environment, remote testing
- **Changes interact unexpectedly** - A working feature can break when combined with others
- **Rollback is easier** - Small steps mean small rollbacks if something breaks

### Example: DON'T Do This

```
❌ BAD: Make multiple changes at once
1. Update Makefile
2. Change build scripts
3. Modify verification tests
4. Update documentation
5. Then test everything together
Result: 10 failures, can't tell which change broke what
```

### Example: DO This Instead

```
✅ GOOD: One step at a time
1. Update Makefile → Test it works → Commit/document
2. Change build scripts → Test they work → Commit/document
3. Modify verification tests → Run them → Commit/document
4. Update documentation → Review it → Commit/document
Result: Each step verified, easy to identify issues
```

### Verification Points

After each change, verify by:
- **Build system changes**: Run a build, check executable exists
- **Script changes**: Execute the script, check output
- **Verification changes**: Run the test suite
- **Documentation changes**: Read it through for accuracy

### When Testing on Amiga

Because Amiga testing uses fs-uae emulation:
- **Each verification run takes 5-10 minutes** - Don't batch changes
- **Test early, test often** - Catch issues immediately
- **Use user-startup integration** - Automatic testing on boot
- **Check logs carefully** - Detailed logs in T: and project root

**Remember: "Make it work, then make it better" - not "Make everything at once and hope."**

## Project Overview

ACE (Amiga BASIC Compiler) is a complete BASIC compiler for the Amiga platform that generates native 68000 assembly code. Originally developed 1991-1996, released as GPL v2 in 1998.

## Build System

The ACE compiler is built using GNU Make with the ADE (Amiga Developer Environment).

### Building the ACE Compiler

```bash
# Build with Makefile-ace (run from make/ directory)
make -f Makefile-ace           # Build ACE compiler (quiet mode)
make -f Makefile-ace V=1       # Build with verbose output
make -f Makefile-ace clean     # Remove all build artifacts
make -f Makefile-ace clean all # Clean rebuild
make -f Makefile-ace backup    # Backup current executable to ace.old
make -f Makefile-ace help      # Show help
```

The Makefile provides incremental builds, standard targets, and verbose/quiet modes. Requires GNU Make 3.80 or later with ADE shell environment.

### Building the Runtime Library (db.lib)

```bash
# Build library (run from make/ directory)
lcmake <module>       # Compile a C library module
lmake <module>        # Assemble an assembly library module
makedb               # Build entire db.lib from sources
```

The `makedb` script compiles C sources from `src/lib/c/` and assembles sources from `src/lib/asm/`, then joins all objects into `lib/db.lib`.

### Building the Startup Library

```bash
# From src/lib/startup/
make                  # Creates startup.lib from startup.s
```

### Compiling BASIC Programs

Three wrapper scripts in `bin/` orchestrate the full pipeline:

```bash
# Legacy toolchain (a68k + blink)
bas <sourcefile>                    # Compile, assemble, link
bas <options> <sourcefile> <libs>   # With compiler options and extra libraries

# Modern toolchain (vasm + vlink)
bas.vb <sourcefile>                 # Preferred: uses vasmm68k_mot + vlink
bas.vb <options> <sourcefile> <libs>

# Phoenix toolchain
bas.phx <sourcefile>                # Uses PhxAss + PhxLnk
```

Pipeline: `app` (preprocess) → `ace` (compile) → `vasm` (assemble) → `vlink` (link)

Source files use `.b` or `.bas` extensions.

## Testing

```bash
# Run all tests
rx verify/tests/runner.rexx

# Run specific category
rx verify/tests/runner.rexx syntax
rx verify/tests/runner.rexx arithmetic
rx verify/tests/runner.rexx floats
rx verify/tests/runner.rexx control
rx verify/tests/runner.rexx errors
```

Test structure:
- `verify/tests/cases/<category>/` - Test source files (.b)
- `verify/tests/expected/` - Expected output files (.expected)
- `verify/tests/results/` - Runtime output (created during test runs)

Tests in `cases/errors/` are expected to fail compilation.

## Architecture

### ACE Compiler (`src/ace/c/`)

Multi-pass compiler that translates BASIC to 68000 assembly:

1. **Lexical Analysis** (`lex.c`) - Tokenizes BASIC source, handles keywords (defined in `acedef.h` as enum)
2. **Parsing** (`parse.c`, `parsevar.c`) - Recursive descent parser
3. **Expression Evaluation** (`expr.c`, `factor.c`) - Expression trees and type checking
4. **Statement Handling** (`statement.c`, `control.c`, `assign.c`) - Statement code generation
5. **Symbol Management** (`sym.c`, `symvar.c`) - Symbol table for variables, functions, labels
6. **Specialized Modules**:
   - `gfx.c` - Graphics primitives (LINE, CIRCLE, AREA)
   - `gadget.c`, `menu.c`, `window.c`, `screen.c` - Intuition GUI support
   - `file.c` - File I/O (sequential and random access)
   - `event.c` - Event traps and handlers
   - `libfunc.c` - External library calls
   - `serial.c` - Serial communication
   - `iff.c` - IFF picture loading
   - `basfun.c` - Built-in BASIC functions
   - `print.c` - PRINT statement handling
   - `sub.c` - SUB/FUNCTION procedures
   - `declare.c` - Variable and type declarations
6. **Code Generation** (`misc.c`) - Emits 68000 assembly
7. **Optimization** (`opt.c`) - Peephole optimizer (push/pop elimination, redundant move removal)
8. **Memory Management** (`alloc.c`, `memory.c`) - Dynamic allocation and code/data structures

Main header: `acedef.h` - Contains enums for all BASIC reserved words, structure definitions, function prototypes.

### Runtime Library (`src/lib/`)

Provides runtime support for compiled programs:

- **C modules** (`src/lib/c/`) - High-level library functions (file I/O, GUI, graphics, IFF, strings, text)
- **Assembly modules** (`src/lib/asm/`) - Low-level routines (string ops, math, sound, turtle graphics, file handling, screen/window functions)
- **Startup** (`src/lib/startup/startup.s`) - Program initialization and cleanup

All compiled into `lib/db.lib` and linked with every ACE program along with `startup.lib`.

### BMAP Files (`bmaps/`)

Binary maps for Amiga OS 39 shared libraries. Map library function offsets for external library calls via `LIBRARY` and `DECLARE FUNCTION` statements. Used by the compiler to resolve library function calls.

### Preprocessors

- **APP** - Original ACE preprocessor for include directives
- **ACPP** - C-style preprocessor for complex header files (see `include/` directory)

### Examples

The `examples/` directory contains 30+ categories of sample programs demonstrating all language features: games, graphics, GUI, fractals, turtle graphics, astronomy, benchmarks, file operations, networking.

## Code Style

- **K&R C style** - Original late-80s/early-90s C conventions
- Function definitions use K&R style (parameters on separate lines)
- Extensive use of Amiga-specific types: `BYTE`, `SHORT`, `LONG`, `BOOL`, `BPTR`
- Direct Amiga API calls via exec, dos, graphics, intuition libraries
- Manual memory management with Amiga AllocMem/FreeMem

## Key Files

- `acedef.h` - Central header with all type definitions, reserved word enums, function prototypes
- `parse.c` - Main parser entry point
- `lex.c` - Lexical analyzer
- `opt.c` - Peephole optimizer
- `make/Makefile-ace` - GNU Makefile for building ACE compiler
- `bin/bas.vb` - Primary build script (modern vasm/vlink toolchain)
- `verify/tests/runner.rexx` - Test harness

## Development Notes

- Build system uses GNU Make with ADE shell environment
- Library build scripts in `make/` use AmigaDOS shell syntax (`.key` directives)
- Test runner (`verify/tests/runner.rexx`) is an ARexx script
- All scripts assume execution on Amiga (or emulator)
- The ACE assign (logical device) must be set to the repository root
- Stack of 40000-65000 bytes required for compiler operations
- Generated assembly goes to `.s` files, objects to `.o`, executables have no extension
- Temporary files typically go to `ram:t/` or `T:`
