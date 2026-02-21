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

  PASS  - Test ran to completion without assertion failures.
  FAIL  - Output contains "ASSERT FAILED", or build/link failed.
  SKIP  - Output contains "SKIPPED:" or source has REM $skip: directive.


Writing Tests
-------------

File naming:
  - Must match the pattern test_*.b (e.g. test_mymod.b, test_edge_cases.b)
  - The runner discovers tests automatically; no registration needed

Module linkage:
  - Use REM #using at the top to link the module's compiled .o file:
      REM #using ace:submods/modulename/modulename.o
  - Include the module header:
      #include <submods/modulename.h>

Assertions:
  - Use ACE's built-in ASSERT to validate results:
      ASSERT condition, "description of what failed"
  - The runner detects "ASSERT FAILED" in output to mark a test as FAIL
  - For detailed diagnostics, also PRINT pass/fail per test case

Summary pattern:
  - Track passed/failed counts and print a summary at the end
  - Use a final ASSERT to signal overall pass/fail:
      ASSERT failed = 0, "Some tests failed"

Skipping tests:
  - At compile time (source directive, checked in first 10 lines):
      REM $skip: reason why this test is skipped
  - At runtime (printed to output):
      PRINT "SKIPPED: reason why this test is skipped"

Test structure (recommended):
  1. REM #using and #include at top
  2. Variable declarations
  3. Initialize counters (passed = 0, failed = 0)
  4. Test groups with descriptive PRINT headers
  5. Individual test cases with ASSERT or pass/fail counting
  6. Summary: print results, final ASSERT

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
