REM #using ace:submods/tasks/taskutil.o
REM #using ace:submods/testkit/testkit.o

{*
** test_userdata.b - Phase 3: tc_UserData parameter passing test
** Tests: TaskGetData retrieves value passed via TaskLaunch
*}

#include <submods/taskutil.h>
#include <submods/testkit.h>

LIBRARY "dos.library"
DECLARE FUNCTION Delay(ticks&) LIBRARY dos

GLOBAL LONGINT result
GLOBAL SHORTINT done%

SUB worker TASKPROC
  LONGINT startVal
  startVal = TaskGetData
  result = startVal * 2
  done% = -1
END SUB

{* ============== Test Suite ============== *}

PRINT "=== Tasks: UserData Test ==="
PRINT

TkInit

{* ============== Test 1: Pass LONGINT via tc_UserData ============== *}

PRINT "-- Test 1: Pass LONGINT via tc_UserData"
result = 0
done% = 0
LONGINT hTask&
hTask& = TaskLaunch(SADD("worker"), @worker, 0, 4096, 42)
TkAssertTrue(hTask& <> 0, "TaskLaunch non-zero")

' Wait for task to finish (max ~2 seconds)
SHORTINT waited%
waited% = 0
WHILE done% = 0 AND waited% < 40
  Delay(3)
  ++waited%
WEND
TkAssertTrue(done% <> 0, "task completed")
TkAssertEq&(result, 84, "42 * 2 = 84")

TaskTerminate(hTask&)

{* ============== Test 2: Pass different value ============== *}

PRINT "-- Test 2: Pass different value"
result = 0
done% = 0
hTask& = TaskLaunch(SADD("worker2"), @worker, 0, 4096, 100)
TkAssertTrue(hTask& <> 0, "TaskLaunch non-zero")

waited% = 0
WHILE done% = 0 AND waited% < 40
  Delay(3)
  ++waited%
WEND
TkAssertTrue(done% <> 0, "task2 completed")
TkAssertEq&(result, 200, "100 * 2 = 200")

TaskTerminate(hTask&)

{* ============== Summary ============== *}
TkSummary
