{*
** test_multiarray.b - Test module with multiple DIM arrays
** This tests Bug #1: Two or more DIM arrays crash
*}

DECLARE SUB MUIInit EXTERNAL
DECLARE SUB MUICleanup EXTERNAL

PRINT "Testing module with multiple DIM arrays..."

CALL MUIInit
PRINT "MUIInit OK"

CALL MUICleanup
PRINT "MUICleanup OK"

PRINT "TEST PASSED - Multi-array module works!"
END
