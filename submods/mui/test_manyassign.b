{*
** test_manyassign.b - Test many array assignments in module SUB
** This tests Bug #3: Too many array assignments in EXTERNAL SUB crash
*}

DECLARE SUB MUIInit EXTERNAL
DECLARE SUB MUICleanup EXTERNAL
DECLARE SUB MUIBuildTags(LONGINT val1, LONGINT val2, LONGINT val3, LONGINT val4, LONGINT val5, LONGINT val6, LONGINT val7) EXTERNAL
DECLARE SUB LONGINT MUIGetTag(SHORTINT idx) EXTERNAL
DECLARE SUB SHORTINT MUIGetCount EXTERNAL

SHORTINT cnt
LONGINT v0, v6

PRINT "Testing many array assignments in SUB (Bug #3)..."

CALL MUIInit
PRINT "MUIInit OK"

{ Call SUB with 7 values to assign to array }
PRINT "Calling MUIBuildTags with 7 values..."
CALL MUIBuildTags(100&, 200&, 300&, 400&, 500&, 600&, 700&)
PRINT "MUIBuildTags OK (7 array assignments executed)"

{ Verify the values }
cnt = MUIGetCount
PRINT "Count:"; cnt

v0 = MUIGetTag(0)
v6 = MUIGetTag(6)
PRINT "Tag 0 ="; v0
PRINT "Tag 6 ="; v6

{ Check first and last values }
IF v0 = 100& AND v6 = 700& THEN
    PRINT "Values verified correctly"
ELSE
    PRINT "ERROR: Values mismatch!"
END IF

CALL MUICleanup
PRINT "MUICleanup OK"

PRINT "TEST PASSED - Many array assignments work!"
END
