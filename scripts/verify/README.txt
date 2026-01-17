================================================================================
  ACE Makefile Verification Scripts
================================================================================

This directory contains ARexx scripts for verifying the Makefile-ace
migration using fs-uae emulation.

================================================================================
REQUIREMENTS
================================================================================

- fs-uae configured with AmigaOS 3.x
- ACE: assign pointing to repository root
- GNU Make 3.80 (or compatible) installed
- gcc 2.95.3 installed
- Standard AmigaDOS commands (copy, delete, list, etc.)

================================================================================
SCRIPTS
================================================================================

verify-makefile.rexx
--------------------
Main verification suite - runs all 15 tests defined in the verification plan.
Comprehensive testing of all Makefile-ace functionality.

Usage:
  cd ACE:scripts/verify
  rx verify-makefile.rexx

Duration: 5-10 minutes (depends on build speed)
Output: Console output + T:makefile-verification.log


quick-test.rexx
---------------
Quick verification - runs essential tests only (clean, no-op, incremental, clean).
Use this for fast iteration during development.

Usage:
  cd ACE:scripts/verify
  rx quick-test.rexx

Duration: 1-2 minutes
Output: Console output + T:quicktest*.log files


================================================================================
RUNNING ON fs-uae
================================================================================

From macOS Host:
----------------

1. Launch fs-uae:
   ~/Applications/Emu/Amiga/FS-UAE/FS-UAE.app/Contents/MacOS/fs-uae \
     /Users/mbergmann/Documents/FS-UAE/Configurations/sys3xdev.fs-uae

2. Wait for AmigaOS to boot

3. Open Shell

4. Verify ACE: assign exists:
   assign

5. Change to scripts directory:
   cd ACE:scripts/verify

6. Run verification:
   rx verify-makefile.rexx

   Or for quick test:
   rx quick-test.rexx


From AmigaOS Shell:
-------------------

If ACE: assign is already configured:

  cd ACE:scripts/verify
  rx verify-makefile.rexx

================================================================================
INTERPRETING RESULTS
================================================================================

Exit Codes:
-----------
0 = All tests passed
1 = One or more tests failed
2 = Script error

Test Results:
-------------
PASS = Test succeeded
FAIL = Test failed (check log files)
SKIP = Test skipped (prerequisites not met)
INFO = Informational only (not pass/fail)

Log Files:
----------
All log files are written to T: (RAM disk)

Main logs:
  T:makefile-verification.log  - Complete verification log
  T:quicktest.log              - Quick test build log

Per-test logs:
  T:test1-clean.log            - Test 1 clean output
  T:test1-build.log            - Test 1 build output
  T:test2-noop.log             - Test 2 no-op build
  T:test3-incremental.log      - Test 3 incremental build
  T:test4-clean.log            - Test 4 clean target
  T:test5-verbose.log          - Test 5 verbose build (V=1)
  T:test6-quiet.log            - Test 6 quiet build
  T:test7-script.log           - Test 7 script build
  T:test8-makefile.log         - Test 8 makefile build
  T:test11-backup.log          - Test 11 backup target
  T:test12-help.log            - Test 12 help output
  T:test14-error.log           - Test 14 error handling
  T:test15-regression.log      - Test 15 regression tests

Comparison artifacts:
  ACE:bin/ace.script           - Script-built executable
  ACE:bin/ace.makefile         - Makefile-built executable
  ACE:bin/ace.old              - Backup from Test 11

================================================================================
TROUBLESHOOTING
================================================================================

"rx: command not found"
-----------------------
ARexx is not installed or not in path. Install ARexx or use full path:
  rexx verify-makefile.rexx

"make: command not found"
-------------------------
GNU Make is not installed. Install GNU Make 3.80 for AmigaOS.

"gcc: command not found"
------------------------
gcc 2.95.3 is not installed. Install gcc for AmigaOS.

"ACE: assign not found"
-----------------------
The ACE: logical device is not configured. In fs-uae, ensure the
configuration maps ACE: to the repository directory.

Tests fail with file not found errors
--------------------------------------
Verify ACE: assign points to correct directory:
  cd ACE:
  list

Should show: bin/ src/ make/ scripts/ etc.

Build succeeds but binaries differ in size
-------------------------------------------
This may indicate:
  - Different gcc versions
  - Different compiler flags
  - Optimization differences

Check that both builds use identical gcc version and flags.

Incremental builds always recompile everything
-----------------------------------------------
Timestamp tracking issue. Check:
  - Make is properly tracking .o file timestamps
  - File system supports timestamps correctly
  - No 'wait' delays needed between operations

================================================================================
VERIFICATION WORKFLOW
================================================================================

During Development:
-------------------
1. Make changes to Makefile-ace
2. Run quick-test.rexx (fast feedback)
3. Fix any issues
4. Repeat

Before Committing:
------------------
1. Run full verify-makefile.rexx
2. Ensure all tests pass
3. Review T:makefile-verification.log
4. Check comparison artifacts

Before Merging to Master:
-------------------------
1. Run full verification suite
2. Verify 100% test pass rate
3. Run regression tests (Test 15)
4. Archive verification log for reference

================================================================================
ADDING NEW TESTS
================================================================================

To add new verification tests:

1. Edit verify-makefile.rexx
2. Add new test section following existing pattern
3. Update total test count at top of script
4. Add test name to GetTestName() function
5. Update this README with new test description
6. Update Makefile-Verification-Plan.txt with test specification

================================================================================
RELATED DOCUMENTATION
================================================================================

specs/Makefile-Migration-Spec.txt      - Migration specification
specs/Makefile-Verification-Plan.txt   - Detailed verification plan
specs/Source-File-Verification.txt     - Source file verification
CLAUDE.md                              - Project overview and build system

================================================================================
SUPPORT
================================================================================

For issues or questions about these verification scripts:

1. Check Makefile-Verification-Plan.txt for test specifications
2. Review log files in T: for error details
3. Verify fs-uae configuration is correct
4. Ensure all prerequisites are installed

================================================================================
END OF README
================================================================================
