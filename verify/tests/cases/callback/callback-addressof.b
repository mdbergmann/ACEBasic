' Test: CALLBACK SUB address-of operator (@)
' Purpose: Verify @SubName works for CALLBACK SUBs to get function address
' Expected: Compilation succeeds, generated assembly shows pea _SUB_MYHOOK

SUB MyHook(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    ' Simple callback that just returns 0
    MyHook = 0&
END SUB

' Get the address of the CALLBACK SUB
hookAddr& = @MyHook

' Print to verify address is non-zero
PRINT "Hook address:"; hookAddr&

END
