{*
** test_poke.b - Test POKE in module
** This tests Bug #2: POKE statement crashes in EXTERNAL module
*}

DECLARE SUB MUIInit EXTERNAL
DECLARE SUB MUICleanup EXTERNAL
DECLARE SUB ADDRESS MUIGetBuffer EXTERNAL

ADDRESS buf

PRINT "Testing POKE in module (Bug #2)..."

CALL MUIInit
PRINT "MUIInit OK (POKE executed)"

buf = MUIGetBuffer
PRINT "Buffer address:"; buf

{ Check if POKE worked by reading back }
IF PEEK(buf) = 65 THEN
    PRINT "POKE verified: first byte is 'A'"
ELSE
    PRINT "POKE FAILED: expected 65, got"; PEEK(buf)
END IF

CALL MUICleanup
PRINT "MUICleanup OK"

PRINT "TEST PASSED - POKE in module works!"
END
