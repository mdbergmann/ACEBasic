Submodule Test Conventions
==========================

This directory contains reusable BASIC library modules (submodules) for the
ACE compiler. Each submodule lives in its own subdirectory and includes test
files verified by a unified test runner.


Directory Layout
----------------

Each submodule directory contains:

  modulename/
    modulename.b      Main module source code
    modulename.o      Compiled module object (produced by: bas -m modulename)
    make              AmigaDOS build script (runs: bas -m modulename)
    test_*.b          One or more test files
    README.txt        Optional description

Module headers live in include/submods/:

  include/submods/modulename.h


Test Runner
-----------

The unified test runner is submods/runner.rexx (ARexx script).

Run from the ACE:submods/ directory on the emulator:

  cd ACE:submods
  rx runner.rexx              ; Run all submodule tests
  rx runner.rexx all          ; Same as above
  rx runner.rexx dp-float     ; Run tests for one submodule only

For each submodule the runner:
  1. Builds the module (executes its make script, if present)
  2. Discovers all test_*.b files
  3. Compiles each test with: bas testname
  4. Runs the executable and captures output
  5. Cleans up generated files (.s, .o, executable)


Test Outcomes
-------------

Three possible outcomes per test:

  PASS  - Test ran to completion without failures.
  FAIL  - Testkit "Results:" shows failures, or "ASSERT FAILED", or build/link failed.
  SKIP  - Output contains "SKIPPED:" or source has REM $skip: directive.


Writing Tests
-------------

File naming:
  - Must match the pattern test_*.b (e.g. test_mymod.b, test_edge_cases.b)
  - The runner discovers tests automatically; no registration needed

Module linkage:
  - Use REM #using at the top to link the module's compiled .o file:
      REM #using ace:submods/modulename/modulename.o
  - Link the testkit:
      REM #using ace:submods/testkit/testkit.o
  - Include headers:
      #include <submods/modulename.h>
      #include <submods/testkit.h>

Assertions (via testkit):
  - TkAssertTrue(condition, "description")
  - TkAssertFalse(condition, "description")
  - TkAssertEq%(actual, expected, "description")   SHORTINT equality
  - TkAssertEq&(actual, expected, "description")    LONGINT equality
  - TkAssertEqAddr(actual, expected, "description") ADDRESS equality
  - TkAssertEqStr(actual$, expected$, "description") STRING equality
  - TkAssertEqFloat(actual, expected, "description") SINGLE with tolerance
  - TkAssertNeq&(actual, notExpected, "description") LONGINT inequality
  - TkAssertNeqAddr(actual, notExpected, "description") ADDRESS inequality
  - On failure, testkit prints "FAIL: description" which the runner detects

Summary pattern:
  - Call TkInit at the start and TkSummary at the end
  - TkSummary prints "Results: N passed, M failed" and ASSERTs M = 0

Skipping tests:
  - At compile time (source directive, checked in first 10 lines):
      REM $skip: reason why this test is skipped
  - At runtime (printed to output):
      PRINT "SKIPPED: reason why this test is skipped"

Test structure (recommended):
  1. REM #using for module + testkit at top
  2. #include for module header + testkit.h
  3. Variable declarations
  4. TkInit
  5. Test groups with descriptive PRINT headers
  6. Individual test cases with TkAssert* calls
  7. TkSummary

See test_tmpl.b in this directory for a skeleton test file.


Build Script (make)
-------------------

Each submodule should have a make script (AmigaDOS):

  ; Build modulename
  execute ACE:bin/bas -m modulename

The runner executes this script before running tests. If the make script
fails (non-zero return code), all tests in that submodule are marked FAIL.


Pitfalls
--------

- Call bas without the .b extension on the emulator: bas testname (not bas testname.b)
- Do not use reserved words as identifiers (see src/ace/c/lexvar.c rword[])
- PRINT #n, "" writes a null byte before newline; use dos _Write for clean output
- STRING params in SUBs are pass-by-value; assignment inside SUB does not affect caller
- Do not use @structInstance to pass struct addresses to SUBs (wrong indirection level)
- Use STOP instead of END inside IF blocks
