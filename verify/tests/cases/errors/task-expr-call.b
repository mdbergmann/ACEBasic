' Test: TASK SUB call in expression context error
' Purpose: Verify that calling a TASK SUB in expression produces error 103
' Expected: Compilation FAILS with error "TASK SUB cannot be called from ACE code"

SUB LONGINT worker TASK
    worker = 42
END SUB

' This should produce error 103 (call in expression context):
LONGINT result&
result& = worker

END
