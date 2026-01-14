{* A test of the RunProg function. *}

#include <SUBmods/RunProg.h>

LONGINT result, stackSize
STRING prg, args

prg = InputBox$("Enter program path and name")
args = InputBox$("Enter command-line arguments")
stackSize = 8000

result = RunProg(prg, args, stackSize)

IF result = -1 THEN 
  MsgBox "RunProg: an error occurred.","Continue"
ELSE
  MsgBox "RunProg returned: "+STR$(result),"Continue"
END IF
