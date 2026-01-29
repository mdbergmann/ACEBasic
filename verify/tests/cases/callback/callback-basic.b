' Test: Basic CALLBACK SUB
' Purpose: Verify CALLBACK SUB generates correct assembly for Amiga Hook convention
' Expected: Compilation succeeds, assembly shows movem save/restore and register copies

SUB MyHook(ADDRESS hook, ADDRESS obj, ADDRESS msg) CALLBACK
    ' Simple callback that just returns 0
    MyHook = 0&
END SUB

' Main program just exits
PRINT "CALLBACK test compiled successfully"
END
