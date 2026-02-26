REM #using ace:submods/tasks/taskutil.o
REM #using ace:submods/testkit/testkit.o

{*
** test_multi.b - Multiple concurrent tasks test
** Tests: Launch 3 tasks simultaneously, each with its own userData
*}

#include <submods/taskutil.h>
#include <submods/testkit.h>

LIBRARY "dos.library"
DECLARE FUNCTION Delay(ticks&) LIBRARY dos

GLOBAL LONGINT result1
GLOBAL LONGINT result2
GLOBAL LONGINT result3
GLOBAL SHORTINT done1%
GLOBAL SHORTINT done2%
GLOBAL SHORTINT done3%

SUB workerA TASKPROC
  LONGINT ud
  ud = TaskGetData
  result1 = ud + 10
  done1% = -1
END SUB

SUB workerB TASKPROC
  LONGINT ud
  ud = TaskGetData
  result2 = ud + 20
  done2% = -1
END SUB

SUB workerC TASKPROC
  LONGINT ud
  ud = TaskGetData
  result3 = ud + 30
  done3% = -1
END SUB

{* ============== Test Suite ============== *}

PRINT "=== Tasks: Multiple Concurrent Tasks ==="
PRINT

TkInit

{* ============== Test 1: Launch 3 tasks at once ============== *}

PRINT "-- Test 1: Launch 3 tasks concurrently"
result1 = 0 : result2 = 0 : result3 = 0
done1% = 0 : done2% = 0 : done3% = 0

LONGINT hA&, hB&, hC&
hA& = TaskLaunch(SADD("taskA"), @workerA, 0, 4096, 100)
hB& = TaskLaunch(SADD("taskB"), @workerB, 0, 4096, 200)
hC& = TaskLaunch(SADD("taskC"), @workerC, 0, 4096, 300)

TkAssertTrue(hA& <> 0, "taskA launched")
TkAssertTrue(hB& <> 0, "taskB launched")
TkAssertTrue(hC& <> 0, "taskC launched")

' Wait for all three (max ~3 seconds)
SHORTINT waited%
waited% = 0
WHILE (done1% = 0 OR done2% = 0 OR done3% = 0) AND waited% < 60
  Delay(3)
  ++waited%
WEND

TkAssertTrue(done1% <> 0, "taskA completed")
TkAssertTrue(done2% <> 0, "taskB completed")
TkAssertTrue(done3% <> 0, "taskC completed")

TkAssertEq&(result1, 110, "100 + 10 = 110")
TkAssertEq&(result2, 220, "200 + 20 = 220")
TkAssertEq&(result3, 330, "300 + 30 = 330")

TaskTerminate(hA&)
TaskTerminate(hB&)
TaskTerminate(hC&)

{* ============== Summary ============== *}
TkSummary
