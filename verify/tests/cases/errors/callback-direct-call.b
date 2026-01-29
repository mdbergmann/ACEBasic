' Test: CALLBACK SUB direct call error
' Purpose: Verify that calling a CALLBACK SUB directly produces error 85
' Expected: Compilation FAILS with error "CALLBACK SUB cannot be called from ACE code"

SUB MyHook(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    MyHook = 0&
END SUB

' This should produce error 85:
CALL MyHook(0&, 0&, 0&)

END
