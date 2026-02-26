REM #using ace:submods/tasks/taskutil.o

{* test_basic.b - Basic task test *}

#include <submods/taskutil.h>

GLOBAL LONGINT counter
GLOBAL SHORTINT done%

SUB worker TASKPROC
  WHILE counter < 1000
    ++counter
  WEND
  done% = -1
END SUB

counter = 0
done% = 0

PRINT "Calling TaskLaunch..."
LONGINT hTask&
hTask& = TaskLaunch(SADD("worker"), @worker, 0, 4096, 0)
PRINT "TaskLaunch returned:"; hTask&

IF hTask& <> 0 THEN
  PRINT "Waiting..."
  LONGINT waited&
  waited& = 0
  WHILE done% = 0 AND waited& < 500000
    waited& = waited& + 1
  WEND
  PRINT "done% ="; done%
  PRINT "counter ="; counter
  PRINT "waited& ="; waited&
  PRINT "Terminating..."
  TaskTerminate(hTask&)
  PRINT "Done"
END IF
