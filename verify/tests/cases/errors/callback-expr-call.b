' Test: CALLBACK SUB call in expression context error
' Purpose: Verify that calling a CALLBACK SUB in expression produces error 85
' Expected: Compilation FAILS with error "CALLBACK SUB cannot be called from ACE code"

SUB MyHook(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    MyHook = 0&
END SUB

' This should produce error 85 (call in expression context):
result& = MyHook(0&, 0&, 0&)

END
