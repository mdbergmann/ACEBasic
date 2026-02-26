REM Test: TASK SUB modifier
REM Purpose: Verify TASK SUB compiles and is XDEF'd
REM Note: Cannot test runtime (needs Exec CreateTask), only compilation

SUB worker TASK
    LONGINT dummy
    dummy = 42
END SUB

PRINT "task_sub: ALL PASSED"
