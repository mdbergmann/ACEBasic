' Test: CALLBACK SUB Register Preservation
' Purpose: Verify callback saves and restores all registers correctly
' Expected: Caller's state is not corrupted after callback returns

' Hook structure
STRUCT Hook
    ADDRESS h_MinNode_mln_Succ
    ADDRESS h_MinNode_mln_Pred
    ADDRESS h_Entry
    ADDRESS h_SubEntry
    ADDRESS h_Data
END STRUCT

' Library declaration
DECLARE FUNCTION LONGINT CallHookPkt(ADDRESS hook, ADDRESS obj, ADDRESS msg) LIBRARY utility

' CALLBACK that does lots of work to stress registers
SUB BusyCallback(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    LONGINT a
    LONGINT b
    LONGINT c
    LONGINT d
    LONGINT sum

    ' Do lots of calculations to use many registers
    a = 100&
    b = 200&
    c = 300&
    d = 400&

    sum = a + b + c + d

    ' Return the sum (should be 1000)
    BusyCallback = sum
END SUB

' Main program
LIBRARY "utility.library"

PRINT "CALLBACK Register Test"
PRINT "======================"

' Set up variables BEFORE calling callback
LONGINT testVal1
LONGINT testVal2
LONGINT testVal3
testVal1 = 11111&
testVal2 = 22222&
testVal3 = 33333&

PRINT "Values before callback:"
PRINT "  testVal1:"; testVal1
PRINT "  testVal2:"; testVal2
PRINT "  testVal3:"; testVal3

' Create hook structure (BSS object)
DECLARE STRUCT Hook myHook
myHook->h_Entry = @BusyCallback
myHook->h_SubEntry = 0&
myHook->h_Data = 0&

' Call the callback
PRINT ""
PRINT "Calling callback..."
retVal& = CallHookPkt(myHook, 0&, 0&)
PRINT "Return value (should be 1000):"; retVal&

' Check that our variables were not corrupted
PRINT ""
PRINT "Values after callback:"
PRINT "  testVal1:"; testVal1
PRINT "  testVal2:"; testVal2
PRINT "  testVal3:"; testVal3

SHORTINT passed
passed = -1
IF testVal1 <> 11111& THEN passed = 0 : PRINT "FAIL: testVal1 corrupted"
IF testVal2 <> 22222& THEN passed = 0 : PRINT "FAIL: testVal2 corrupted"
IF testVal3 <> 33333& THEN passed = 0 : PRINT "FAIL: testVal3 corrupted"
IF retVal& <> 1000& THEN passed = 0 : PRINT "FAIL: wrong return value"

IF passed THEN
    PRINT ""
    PRINT "PASS: All registers preserved correctly!"
END IF

LIBRARY CLOSE "utility.library"
END
