/*
** Load and execute a program with control over stack size and
** retrieval of the AmigaDOS return code (neither of which ACE's 
** SYSTEM command gives you). Requires version 36 or higher of the 
** OS (Wb 2.x/3.x). RunProg returns -1 if an error occurs when
** attempting to run the program.
** 
** Author: David J Benn
**   Date: 4th-6th March 1995
*/

CONST null = 0&
CONST bad = -1&

SUB LONGINT RunProg(STRING theProg, STRING theArgs, LONGINT stackSize) EXTERNAL
{*
** Declare shared library functions.
*}
DECLARE FUNCTION ADDRESS LoadSeg(STRING loadFile) LIBRARY dos
DECLARE FUNCTION UnLoadSeg(ADDRESS segList) LIBRARY dos
DECLARE FUNCTION LONGINT RunCommand(ADDRESS segList, LONGINT stackSize, ~
			            ADDRESS argPtr, LONGINT argSize) LIBRARY dos
{*
** Segment list address, AmigaDOS return code.
*}
ADDRESS segList
LONGINT result

  IF theProg = "" THEN
    RunProg = bad 
  ELSE
    segList = LoadSeg(theProg)
    IF segList = null THEN
      RunProg = bad
    ELSE
      IF theArgs <> "" AND RIGHT$(theArgs,1) <> CHR$(10) THEN 
	theArgs = theArgs+CHR$(10)
      END IF
      result = RunCommand(segList,stackSize,theArgs,LEN(theArgs))
      UnLoadSeg(segList)  {* I assume RunCommand() does not do this! *}
      RunProg = result
    END IF
  END IF
END SUB
