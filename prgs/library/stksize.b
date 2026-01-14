{* 
** Show the stack size of the current process. 
**
** Author: David J Benn
**   Date: 7th October 1995
*}

#include <dos/dosextens.h>

LIBRARY "exec.library"
DECLARE FUNCTION ADDRESS FindTask(ADDRESS taskName) LIBRARY exec

DECLARE STRUCT Process *myProcess

myProcess = FindTask(NULL)

IF myProcess <> NULL THEN
  MsgBox "Stack size is:"+STR$(myProcess->pr_StackSize)+" bytes.","Continue"
END IF
