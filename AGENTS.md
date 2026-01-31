# AGENTS.md

AI agent guidance for this codebase. For project docs, build instructions, and architecture, see [README.md](README.md).

## Project Overview

ACE is a BASIC compiler for Amiga. It compiles BASIC source code (.b files) into native Amiga executables by generating Motorola 68000 assembly. The compiler is written in K&R C.

**Build Pipeline:**
```
Source (.b) → Preprocess (app) → Compile (ace) → Assemble (vasm) → Link (vlink) → Executable
```

The `bas` wrapper script in `bin/` orchestrates this full pipeline.

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `src/ace/c/` | Compiler source (lexer, parser, code generator) |
| `src/lib/c/` | Runtime library C sources |
| `src/lib/asm/` | Runtime library assembly sources |
| `src/make/` | **Build from here** - Makefiles and build scripts |
| `bin/` | Compiler binaries and bas wrapper script |
| `lib/` | Built libraries (db.lib, startup.lib) |
| `bmaps/` | Binary maps for Amiga shared libraries |
| `include/` | Amiga system headers and submodule headers |
| `submods/` | Submodules (reusable BASIC libraries) |
| `verify/tests/` | Test suite (cases/, expected/, results/) |
| `verify/scripts/otherthenamiga/` | Emulator and Amiga system files |
| `docs/` | Documentation (ref.txt for language reference) |
| `examples/` | Example programs by category |

## Workflow - CRITICAL

**Work in small, incremental steps. Only proceed when the previous step is verified working.**

1. Think test-driven: create a test first that specifies the implementation
2. Make ONE change at a time
3. Verify it works (build, test, or run)
4. Only then proceed to the next change
5. Every plan/spec is to be implemented in a separate git branch

Why: The Amiga environment is fragile - path handling, toolchain differences, and AmigaOS quirks mean changes interact unexpectedly. Small steps make debugging and rollback feasible.

### Verification After Each Change

- **Build changes**: Run a build, check executable exists
- **Script changes**: Execute the script, check output
- **Test changes**: Run the test suite
- **Compiler/library changes**: Build and run relevant tests (must run on emulator)

Note: Compiler/runtime rebuild is only necessary when its source files were changed.

## Amiga Emulator Testing

### Setup

- **Emulator app**: `verify/scripts/otherthenamiga/FS-UAE.app`
- **Config file**: `verify/scripts/otherthenamiga/ace-verify.fs-uae`
- **Amiga system**: `verify/scripts/otherthenamiga/aos3`
- **Startup script**: `aos3/S/user-startup` - edit this to run commands on boot

### Running the Emulator

```bash
# Start the emulator
open verify/scripts/otherthenamiga/FS-UAE.app --args verify/scripts/otherthenamiga/ace-verify.fs-uae
```

### Testing Workflow

1. Edit `aos3/S/user-startup` to run your test commands
2. Write output/logs to `ace:` (maps to project root on host)
3. Start/restart emulator
4. Periodically check for result files (every 30 secs)
5. Runs take 5-10 min when recompiling, <1 min otherwise

**IMPORTANT: The emulator MUST be restarted after every change to `user-startup`.** The startup script is only read once at boot time.

### Example user-startup for testing

```
; In aos3/S/user-startup
cd ace:submods/mui
bas test_minimal >ace:test-output.txt
test_minimal >>ace:test-output.txt
```

It may be necessary to call the commands of bas individually, i.e. to get the assembler source code .s.

A module must be compiled using `-m` switch: `bas -m mymod`.

## ACE BASIC Syntax

Full reference: `docs/ref.txt`

Key points:
- Comments: `REM` or `'`
- Variables: `DIM x AS INTEGER`, `DIM s AS STRING`
- Strings end with `$`: `name$`, `DIM text$ AS STRING`
- Arrays: `DIM arr(10) AS SINGLE`
- Structures: `DECLARE STRUCT mystruct`, access with `->`
- Library calls: `LIBRARY "library.library"`, `DECLARE FUNCTION`
- Labels for GOTO/GOSUB: `label:`
- Subprograms: `SUB name ... END SUB`, `FUNCTION name ... END FUNCTION`
- External modules: `EXTERNAL modulename`
- calling SUBs needs parenthesis
- don't use END inside IF blocks, use STOP.

## Pitfalls for AI Agents

### AmigaDOS Specifics

- **No stderr redirect**: `2>&1` doesn't work on AmigaDOS
- **No .b extension**: Call `bas myprog` not `bas myprog.b` (on emulator)
- **Debug build phases**: Split bas phases (ace, vasm, vlink) and redirect each to separate files to see what's happening

### Amiga Path Handling

- Amiga uses `:` not `/` for device paths: `ACE:bin/ace` not `ACE/bin/ace`
- Case-sensitive on Unix, case-insensitive on Amiga - be consistent
- **Makefiles must run from `src/make/`** - relative paths are based there
- Required assigns: `ACE:` (repo root), `ACElib:`, `ACEbmaps:`, `ACEinclude:`

### Code Style (Compiler Sources)

- **K&R C style throughout** - no ANSI C, no modern features
- Use Amiga types: `BYTE`, `SHORT`, `LONG`, `BOOL`, `BPTR` (not standard C types)
- Single header `acedef.h` included everywhere
- **Always read `acedef.h` first** when modifying the compiler

### Build System

- **Run make from `src/make/`**, not project root
- AmigaDOS scripts use `.key` directives, not bash syntax
- Use `make -f <Makefile> clean` to rebuild completely
- Stack requirement: 40000-65000 bytes for compiler operations

### Testing

- Error tests (`cases/errors/`) are expected to FAIL compilation
- Test results in `verify/tests/results/` - don't commit these
- Test runner is ARexx: `rx verify/tests/runner.rexx <category>`
- Categories: syntax, arithmetic, floats, control, errors

## Task Approach

### Building the Compiler

```bash
cd src/make
make -f Makefile-ace           # Build compiler
make -f Makefile-ace clean all # Clean rebuild
make -f Makefile-ace V=1       # Verbose output
```

### Building Runtime Libraries

```bash
cd src/make
make -f Makefile-lib           # Build db.lib and startup.lib
make -f Makefile-lib clean     # Clean first if needed
```

**IMPORTANT: compiling the ace compiler takes time, remove recom,piling from user-startup when not needed.**

### Modifying the Compiler

1. Read `acedef.h` first - contains all type definitions and prototypes
2. Find the relevant module:
   - `lex.c` - Lexical analysis (tokenizer)
   - `parse.c`, `parsevar.c` - Recursive descent parser
   - `expr.c`, `factor.c` - Expression evaluation
   - `statement.c`, `control.c`, `assign.c` - Statement handling
   - `sym.c`, `symvar.c` - Symbol table management
   - `misc.c` - Code generation (emits 68000 assembly)
   - `opt.c` - Peephole optimizer
3. Make minimal K&R C changes
4. Build and test after each change
5. Verify generated `.s` assembly is correct

### Modifying Runtime Libraries

1. Identify if C (`src/lib/c/`) or assembly (`src/lib/asm/`)
2. Rebuild: `make -f Makefile-lib` from `src/make/`
3. Test with example programs - runtime changes affect all compiled programs

### Adding Tests

1. Choose category: syntax, arithmetic, floats, control, errors
2. Create `.b` file in appropriate `cases/` subdirectory
3. Add `expected/<testname>.expected` if runtime verification needed
4. Run: `rx verify/tests/runner.rexx <category>`

### Compiling BASIC Programs

```bash
# On Amiga/emulator
bas myprogram           # Compile myprogram.b to executable

# To debug compilation issues, run phases separately:
ace myprogram.b         # Just compile to .s
vasm -Fhunk -o myprogram.o myprogram.s   # Assemble
vlink -o myprogram myprogram.o ACElib:db.lib ACElib:startup.lib  # Link
```

## Debugging and Troubleshooting

### When compilation fails

1. Check if it's a compiler bug or source code issue
2. Look at generated `.s` assembly file for clues
3. Run compiler phases separately to isolate the problem

### When emulator testing fails

1. Check `user-startup` syntax (AmigaDOS, not bash)
2. Verify assigns are set correctly
3. Check output file on host system (written to `ace:`)
4. Restart emulator if you changed user-startup

### When builds fail

1. Ensure you're running from `src/make/` directory
2. Run `make -f <Makefile> clean` first
3. Check for K&R vs ANSI C style issues in compiler changes

## Submodules

Submodules are reusable BASIC libraries in `submods/`. Each has:
- `.b` source file (the library code)
- Optional `.h` header in `include/submods/`
- Test files for verification

Use with `EXTERNAL modulename` in BASIC source.
