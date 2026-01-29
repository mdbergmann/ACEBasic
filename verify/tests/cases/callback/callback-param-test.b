' Test: CALLBACK SUB Parameter Passing via CallHookPkt
' Purpose: Verify hook pointer (A0) and h_Data are received correctly
' Expected: Callback receives correct hook pointer and can read h_Data

' Hook structure layout (from utility/hooks.h):
'   Offset 0:  h_MinNode_mln_Succ (4 bytes)
'   Offset 4:  h_MinNode_mln_Pred (4 bytes)
'   Offset 8:  h_Entry (4 bytes)
'   Offset 12: h_SubEntry (4 bytes)
'   Offset 16: h_Data (4 bytes)

CONST HOOK_H_DATA_OFFSET = 16

' Hook structure
STRUCT Hook
    ADDRESS h_MinNode_mln_Succ
    ADDRESS h_MinNode_mln_Pred
    ADDRESS h_Entry
    ADDRESS h_SubEntry
    ADDRESS h_Data
END STRUCT

' Library declaration for CallHookPkt
DECLARE FUNCTION LONGINT CallHookPkt(ADDRESS hook, ADDRESS obj, ADDRESS msg) LIBRARY utility

' Our CALLBACK SUB - receives hook in A0, obj in A2, msg in A1
SUB TestCallback(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    ADDRESS hData

    ' Read h_Data from hook structure using PEEKL
    hData = PEEKL(hook + HOOK_H_DATA_OFFSET)

    ' Store h_Data at address passed in obj
    POKEL obj, hData

    TestCallback = 42&
END SUB

' Main program
LIBRARY "utility.library"

PRINT "CALLBACK Parameter Test"
PRINT "======================="

' Variable to store result from callback
LONGINT resultValue

' Create hook structure (BSS object)
DECLARE STRUCT Hook myHook
myHook->h_Entry = @TestCallback
myHook->h_SubEntry = 0&
myHook->h_Data = 12345&

PRINT "Hook address:"; myHook
PRINT "Callback address:"; @TestCallback
PRINT "h_Data set to: 12345"

' Call the callback via CallHookPkt
' We pass VARPTR(resultValue) as obj so callback can store h_Data there
PRINT "Calling CallHookPkt..."
retVal& = CallHookPkt(myHook, VARPTR(resultValue), 0&)

PRINT "Return value from callback:"; retVal&
PRINT "resultValue (should be 12345):"; resultValue

IF retVal& = 42& AND resultValue = 12345& THEN
    PRINT "PASS: Parameters passed correctly!"
ELSE
    PRINT "FAIL: Parameter mismatch"
    IF retVal& <> 42& THEN PRINT "  Expected return 42, got"; retVal&
    IF resultValue <> 12345& THEN PRINT "  Expected h_Data 12345, got"; resultValue
END IF

LIBRARY CLOSE "utility.library"
END
