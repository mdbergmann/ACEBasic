' Test: TASK SUB with parameters error
' Purpose: Verify that TASK SUB with parameters produces error 102
' Expected: Compilation FAILS with error "TASK SUB must have zero parameters"

SUB worker(x&) TASK
    PRINT x&
END SUB

END
