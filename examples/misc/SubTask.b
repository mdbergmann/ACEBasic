{*
** An example of creating a sub-task in ACE.
** Adapted from RKM: Libraries (1991), p 467-468.
*}

DEFLNG a-z

CONST stack_size = 1000&
CONST big_num = &H8000000

LIBRARY "exec.library"

'..library functions
DECLARE FUNCTION _Wait(signal&) LIBRARY exec
DECLARE FUNCTION Forbid() LIBRARY exec
DECLARE FUNCTION Permit() LIBRARY exec

'..external functions (ami.lib)
DECLARE FUNCTION CreateTask&(taskname$,pri&,initPC&,stackSize&) EXTERNAL
DECLARE FUNCTION DeleteTask(task&) EXTERNAL

'..stack-allocated global variables
ADDRESS task

'..static global variables
GLOBAL LONGINT sharedvar

'..subprograms
SUB simpletask
  while sharedvar < big_num
    ++sharedvar
  wend
  _Wait(0)
END SUB

'..main
sharedvar = 0
Print "Initial value of shared variable:";sharedvar

task = CreateTask("SimpleTask",0&,@simpletask,stack_size)

If task <> 0& Then
  Print "A sub-task has been spawned which is currently"
  Print "incrementing a variable that is shared between"
  Print "the main task and the sub-task."
  Input "Press return...",x$
  Print "The value of the shared variable is now:";sharedvar
  Forbid
  DeleteTask(task)
  Permit
End If
