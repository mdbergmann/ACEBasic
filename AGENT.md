# AGENT.md

AI agent guidance for this codebase. For project docs, build instructions, and architecture, see [README.md](README.md).

## Workflow - CRITICAL

**Work in small, incremental steps. Only proceed when the previous step is verified working.**

1. Think test-driven, a test should be first created that specifies the implementation (see Testing below)
2. Make ONE change at a time
3. Verify it works (build, test, or run)
4. Only then proceed to the next change

Why: The Amiga environment is fragile - path handling, toolchain differences, and AmigaOS quirks mean changes interact unexpectedly. Small steps make debugging and rollback feasible.

### Verification After Each Change

- **Build changes**: Run a build, check executable exists
- **Script changes**: Execute the script, check output
- **Test changes**: Run the test suite
- **Compiler/library changes**: Build and run relevant tests (must be on emu, check next section)

### Amiga Emulator Testing

- Emulator: `verify/scripts/otherthenamiga/FS-UAE.app`
- Config (A4000/AGA): `verify/scripts/otherthenamiga/ace-verify.fs-uae`
- Amiga system: `verify/scripts/otherthenamiga/aos3`
- Runs take 5-10 min when recompiling, <1 min otherwise
- Adapt `aos3/S/user-startup` to run/execute a script or manual commands on boot. Whatever it is, in order to be able to verify, what has been added should write log to ace: where it can be checked on the host system
- run emulator using 'open' command.
- Running the emulator should periodically (30 secs) check for a result (if some log file is generated)

## ACE Basic syntax

Check docs/ref.txt

## Pitfalls for AI Agents

### AmigaDOS 

- stderr redirection (2>&1) on AmigaDOS doesn't work.
- call bin/bas script without .b extension.

### Amiga Path Handling
- Amiga uses `:` not `/` for device paths: `ACE:bin/ace` not `ACE/bin/ace`
- Case-sensitive on Unix, case-insensitive on Amiga - be consistent
- Makefiles must run from `src/make/` - relative paths are based there
- Scripts expect assigns: `ACE:`, `ACElib:`, `ACEbmaps:`, `ACEinclude:`

### Code Style (Compiler Sources)
- K&R C style throughout - no ANSI C, no modern features
- Use Amiga types: `BYTE`, `SHORT`, `LONG`, `BOOL`, `BPTR` (not standard C types)
- Single header `acedef.h` included everywhere
- Always read `acedef.h` first when modifying the compiler

### Build System
- Run make from `src/make/`, not project root
- AmigaDOS scripts use `.key` directives, not bash syntax
- call the makefiles with 'clean' to rebuild completely

### Testing
- Error tests (`cases/errors/`) are expected to FAIL compilation
- Test results in `verify/tests/results/` - don't commit these
- Test runner is ARexx, not shell script

## Task Approach

### Modifying the Compiler
1. Read `acedef.h` first
2. Find the relevant module (see README Architecture section)
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
