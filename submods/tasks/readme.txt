Tasks Submodule
===============

Wraps Amiga Exec task creation with a simple API.
Requires the TASKPROC compiler keyword for task entry points.


Requirements
------------

- ACE compiler with TASKPROC support
- amiga.lib (provides CreateTask/DeleteTask)


API
---

TaskLaunch(taskNameAddr&, entryPoint&, pri&, stackSize&, userData&) -> LONGINT
  Creates and launches a new Exec task. Returns task address, 0 on failure.
  taskNameAddr is SADD("name"), entryPoint is @SubName.
  userData is stored in tc_UserData (pass 0 if unused).

TaskGetData -> LONGINT
  Returns tc_UserData of the calling task. Call from within a TASKPROC SUB.

TaskTerminate(hTask&)
  Deletes a task (Forbid/DeleteTask/Permit).


Usage
-----

#include <submods/taskutil.h>
REM #using ace:submods/tasks/taskutil.o

GLOBAL LONGINT counter

SUB worker TASKPROC
  WHILE counter < 1000
    ++counter
  WEND
END SUB

LONGINT hTask&
hTask& = TaskLaunch(SADD("worker"), @worker, 0, 4096, 0)
' ... do work ...
TaskTerminate(hTask&)


Notes
-----

- Task SUBs must use GLOBAL variables (not SHARED) for cross-task data.
- No string operations or library open/close inside task SUBs.
- Minimum recommended stack size: 4096 bytes.
- For cooperative shutdown, use a GLOBAL flag the task checks periodically.
- Pass structured data via tc_UserData using a STRUCT address.

See test_basic.b, test_userdata.b, and test_struct.b for examples.


Build
-----

On Amiga: execute make
