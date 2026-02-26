{* taskutil.b - Exec Task management submodule for ACE BASIC *}

#include <exec/tasks.h>

DECLARE FUNCTION FindTask&(taskName$) LIBRARY exec
DECLARE FUNCTION Forbid() LIBRARY exec
DECLARE FUNCTION Permit() LIBRARY exec

DECLARE FUNCTION CreateTask&(n&,p&,pc&,sz&) EXTERNAL
DECLARE FUNCTION DeleteTask(task&) EXTERNAL

SUB _TaskOpenExec
  LIBRARY "exec.library"
END SUB

SUB _TaskCloseExec
  LIBRARY CLOSE "exec.library"
END SUB

SUB LONGINT TaskLaunch(LONGINT taskNameAddr, LONGINT entryPoint, LONGINT pri, LONGINT stackSize, LONGINT userData) EXTERNAL
  _TaskOpenExec
  DECLARE STRUCT Task taskPtr
  LONGINT hTask
  Forbid
  hTask = CreateTask(taskNameAddr, pri, entryPoint, stackSize)
  IF hTask <> 0 THEN
    taskPtr = hTask
    taskPtr->tc_UserData = userData
  END IF
  Permit
  TaskLaunch = hTask
END SUB

SUB LONGINT TaskGetData EXTERNAL
  _TaskOpenExec
  DECLARE STRUCT Task taskPtr
  taskPtr = FindTask(0&)
  TaskGetData = taskPtr->tc_UserData
END SUB

SUB TaskTerminate(LONGINT hTask) EXTERNAL
  _TaskOpenExec
  Forbid
  DeleteTask(hTask)
  Permit
  _TaskCloseExec
END SUB
