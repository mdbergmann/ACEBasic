REM #using ace:submods/tasks/taskutil.o
REM #using ace:submods/testkit/testkit.o

{*
** test_struct.b - Phase 3: Struct as user data test
** Tests: Pass struct address via tc_UserData, access members in task
*}

#include <submods/taskutil.h>
#include <submods/testkit.h>

LIBRARY "dos.library"
DECLARE FUNCTION Delay(ticks&) LIBRARY dos

STRUCT WorkerArgs
  LONGINT x
  LONGINT y
END STRUCT

GLOBAL LONGINT result
GLOBAL SHORTINT done%

SUB worker TASKPROC
  DECLARE STRUCT WorkerArgs params
  params = TaskGetData
  result = params->x + params->y
  done% = -1
END SUB

{* ============== Test Suite ============== *}

PRINT "=== Tasks: Struct UserData Test ==="
PRINT

TkInit

{* ============== Test 1: Pass struct via tc_UserData ============== *}

PRINT "-- Test 1: Pass struct via tc_UserData"
DECLARE STRUCT WorkerArgs args
args->x = 10
args->y = 20
result = 0
done% = 0

LONGINT hTask&
hTask& = TaskLaunch(SADD("worker"), @worker, 0, 4096, args)
TkAssertTrue(hTask& <> 0, "TaskLaunch non-zero")

' Wait for task to finish (max ~2 seconds)
SHORTINT waited%
waited% = 0
WHILE done% = 0 AND waited% < 40
  Delay(3)
  ++waited%
WEND
TkAssertTrue(done% <> 0, "task completed")
TkAssertEq&(result, 30, "10 + 20 = 30")

TaskTerminate(hTask&)

{* ============== Test 2: Different struct values ============== *}

PRINT "-- Test 2: Different struct values"
args->x = 1000
args->y = 234
result = 0
done% = 0

hTask& = TaskLaunch(SADD("worker2"), @worker, 0, 4096, args)
TkAssertTrue(hTask& <> 0, "TaskLaunch non-zero")

waited% = 0
WHILE done% = 0 AND waited% < 40
  Delay(3)
  ++waited%
WEND
TkAssertTrue(done% <> 0, "task2 completed")
TkAssertEq&(result, 1234, "1000 + 234 = 1234")

TaskTerminate(hTask&)

{* ============== Summary ============== *}
TkSummary
