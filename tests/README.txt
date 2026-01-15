ACE BASIC Compiler Test Suite
=============================

This test suite validates the ACE BASIC compiler functionality.

Directory Structure
-------------------

tests/
  runner.rexx       - ARexx test runner script
  cases/            - Test source files
    syntax/         - Basic syntax tests
    arithmetic/     - Integer arithmetic tests
    floats/         - Floating point tests
    control/        - Control flow tests
    errors/         - Expected compilation failures
  expected/         - Expected output for runtime verification
  results/          - Test run output (created at runtime)

Running Tests
-------------

On Amiga (or emulator):

  rx tests/runner.rexx           ; Run all tests
  rx tests/runner.rexx syntax    ; Run only syntax tests
  rx tests/runner.rexx floats    ; Run only float tests
  rx tests/runner.rexx errors    ; Run only error tests

Test Levels
-----------

Level 1: Compile-only
  - Verifies ACE produces .s assembly file
  - Exit code 0 indicates success

Level 2-4: Full pipeline (when expected output exists)
  - Compiles, assembles, links, and runs
  - Compares output against expected/testname.expected

Error Tests
-----------

Tests in cases/errors/ are expected to FAIL compilation.
A passing error test means the compiler correctly rejected invalid code.

Adding New Tests
----------------

1. Create a .b file in the appropriate cases/ subdirectory
2. Optionally create expected/testname.expected for output verification
3. For error tests, place in cases/errors/ (compilation should fail)

Test Naming
-----------

Use descriptive names without spaces:
  - float_add.b, not "float add.b"
  - for_loop.b, not "for-loop.b"
