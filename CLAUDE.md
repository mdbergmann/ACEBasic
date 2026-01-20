# CLAUDE.md

This file provides guidance to Claude Code and other AI agents when working with this codebase.

**For general project documentation, build instructions, and architecture details, see [README.md](README.md).**

## Development Workflow - CRITICAL

**ALWAYS work in small, incremental steps. Only proceed to the next step when the previous step has been verified working.**

### The Small Steps Principle

1. **Make ONE change at a time** - Don't bundle multiple changes together
2. **Verify it works** - Test, build, or run verification before continuing
3. **Only then proceed** - Move to the next change only after verification passes
4. **Document what worked** - Update status files or commit with clear messages

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

## Critical Paths and Locations

### Build System
- **Makefile location**: `src/make/Makefile-ace` (must run from `src/make/` directory)
- **Build scripts**: `src/make/` (Makefile-ace, Makefile-lib)
- **Output binaries**: `bin/ace` (compiler), `lib/db.lib` (runtime), `lib/startup.lib` (startup)

### Source Code
- **Compiler source**: `src/ace/c/` (all .c files)
- **Compiler objects**: `src/ace/obj/` (build artifacts)
- **Main header**: `src/ace/c/acedef.h` (central header for entire compiler)
- **Library source**: `src/lib/c/` (C modules), `src/lib/asm/` (assembly modules)

### Testing and Verification
- **Test runner**: `verify/tests/runner.rexx` (ARexx script)
- **Test cases**: `verify/tests/cases/<category>/` (syntax, arithmetic, floats, control, errors)
- **Expected output**: `verify/tests/expected/` (.expected files)
- **Test results**: `verify/tests/results/` (created during test runs)
- **Verification scripts**: `verify/scripts/` (automated verification phases)

### Important Directories
- **ACE assign must point to repository root** - All AmigaDOS scripts expect this
- **Temporary files**: `ram:t/` or `T:` on Amiga
- **Generated assembly**: `.s` files (not `.asm`)
- **Object files**: `.o` files
- **Executables**: No extension

## Common Pitfalls and Gotchas

### Path Handling
- **Amiga uses `:` in paths** - `ACE:bin/ace` not `ACE/bin/ace`
- **Case-sensitive on Unix, case-insensitive on Amiga** - Be consistent
- **Relative paths in Makefile** - Must be correct from `src/make/` working directory
- **Assigns are critical** - Scripts expect `ACE:`, `ACElib:`, `ACEbmaps:`, `ACEinclude:`

### File Naming
- **BASIC source**: Use `.b` or `.bas` extensions
- **Assembly output**: `.s` extension (not `.asm`)
- **Object files**: `.o` extension
- **Executables**: No extension (Amiga convention)
- **Test expected files**: `<testname>.expected` in `verify/tests/expected/`

### Code Style
- **K&R C style** - Parameters on separate lines in function definitions
- **Amiga types everywhere** - `BYTE`, `SHORT`, `LONG`, `BOOL`, `BPTR` (not standard C types)
- **No ANSI C** - Compiled with old Sozobon C v1.01 originally, now GCC but K&R style maintained
- **Single header file** - `acedef.h` is included everywhere, contains everything

### Build System
- **Run make from src/make/** - Not from project root
- **GNU Make 3.80+** - Requires specific make version
- **ADE shell environment** - Amiga Developer Environment assumed
- **Stack size matters** - Compiler needs 40000-65000 bytes stack

### Testing
- **Error tests should fail** - Tests in `cases/errors/` are expected to fail compilation
- **Expected files optional** - Compile-only tests don't need `.expected` files
- **Test results ignored** - `verify/tests/results/` should not be committed
- **ARexx syntax** - Test runner uses ARexx, not standard shell scripting

## How to Approach Different Tasks

### Modifying the Compiler
1. **Always read `acedef.h` first** - Understand types and structures
2. **Find the relevant module** - See module list in README.md Architecture section
3. **Make minimal changes** - K&R C style, no modern C features
4. **Test immediately** - Build and run test suite after each change
5. **Check generated assembly** - Verify `.s` output is correct

### Modifying the Runtime Library
1. **Identify if C or assembly** - `src/lib/c/` vs `src/lib/asm/`
2. **Rebuild libraries** - `make -f Makefile-lib` from `src/make/`
3. **Test with example programs** - Runtime changes affect all compiled programs
4. **See src/lib/README.md** - Documents library structure and ami.lib

### Modifying Build Scripts
1. **AmigaDOS syntax** - Scripts use `.key` directives, not bash
2. **Test on Amiga** - Scripts must run in AmigaDOS environment
3. **Path handling critical** - Amiga paths use `:` separator
4. **Verify assigns work** - Scripts depend on `ACE:`, `ACElib:`, etc.

### Adding Tests
1. **Choose correct category** - syntax, arithmetic, floats, control, errors
2. **Use descriptive names** - `float_add.b` not `test1.b`
3. **Add expected output if needed** - For runtime verification tests
4. **Run test immediately** - `rx verify/tests/runner.rexx <category>`
5. **Check results carefully** - Logs in `verify/tests/results/`

### Modifying Documentation
1. **README.md for users** - General project information, build instructions
2. **CLAUDE.md for AI agents** - Workflow, gotchas, agent-specific guidance
3. **Keep them separate** - Don't duplicate content between files
4. **Update both if needed** - But focus content appropriately

## Key Files to Know

When working with specific areas:

**Compiler Core:**
- `src/ace/c/acedef.h` - Master header (types, enums, prototypes)
- `src/ace/c/parse.c` - Main parser entry point
- `src/ace/c/lex.c` - Lexical analyzer and tokenizer
- `src/ace/c/expr.c` - Expression evaluation
- `src/ace/c/misc.c` - Code generation routines

**Build System:**
- `src/make/Makefile-ace` - Compiler build makefile
- `src/make/Makefile-lib` - Runtime library build (db.lib, startup.lib)
- `bin/bas` - Compile/link wrapper script (vasm/vlink)

**Testing:**
- `verify/tests/runner.rexx` - Test harness (ARexx)
- `verify/scripts/run-auto-verify.sh` - Automated verification orchestrator
- `verify/scripts/phase*.script` - Individual verification phases

**Configuration:**
- `verify/scripts/otherthenamiga/ace-verify.fs-uae` - FS-UAE emulator config
- `verify/scripts/otherthenamiga/aos3/s/user-startup` - Amiga startup script (sets assigns)

## Finding Information

- **Build instructions** → README.md "Building" section
- **Testing** → README.md "Testing" section
- **Project structure** → README.md "Project Structure" section
- **Architecture overview** → README.md "Documentation > Architecture Overview"
- **Examples** → `examples/` directory (30+ categories)
- **Language reference** → `docs/ace.guide` or `docs/ref.guide`
- **Historical context** → `docs/HISTORY-1998-Release.txt`

## Quick Reference Commands

```bash
# Build compiler (from src/make/)
make -f Makefile-ace

# Run all tests
rx verify/tests/runner.rexx

# Run specific test category
rx verify/tests/runner.rexx floats

# Compile BASIC program
bas myprogram.b

# Rebuild runtime libraries (from src/make/)
make -f Makefile-lib

# Git workflow
git commit -m "message"
git push
```

## Remember

1. **Small steps** - One change, verify, next change
2. **Test immediately** - Don't batch changes before testing
3. **Read README.md first** - For general project information
4. **This file is for workflow** - Not general documentation
