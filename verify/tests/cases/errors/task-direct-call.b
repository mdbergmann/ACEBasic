' Test: TASK SUB direct call error
' Purpose: Verify that calling a TASK SUB directly produces error 103
' Expected: Compilation FAILS with error "TASK SUB cannot be called from ACE code"

SUB worker TASK
    PRINT "task body"
END SUB

' This should produce error 103:
worker

END
