REM Test: TASKPROC SUB modifier
REM Purpose: Verify TASKPROC SUB compiles and is XDEF'd
REM Note: Cannot test runtime (needs Exec CreateTask), only compilation

SUB worker TASKPROC
    LONGINT dummy
    dummy = 42
END SUB

PRINT "task_sub: ALL PASSED"
