{*
** This program must be linked with the ACE
** SUBprogram library module WBarg.o.
**
** Try various combinations of icon selection
** (including just launching the executable)
** from the Workbench and observe the effects.
**
** Author: David J Benn
**   Date: 29th,30th December 1994
*}

#include <SUBmods/WBarg.h>

IF NOT WBlaunched THEN STOP

WINDOW 1,,(0,0)-(640,200)

FOR i=0 TO WBargcount
  PRINT "[";i;"]";
  theArg$ = WBargpath$(i)+WBarg$(i)
  PRINT TAB(10);theArg$;
  theValue$ = ToolTypeVal$(theArg$,"COLOR")
  PRINT TAB(30);theValue$;
  PRINT TAB(50);ToolTypeValMatched(theValue$,"red");
  PRINT TAB(60);DefaultTool$(theArg$)
NEXT

PRINT:PRINT "<< Click close gadget >>"

GADGET WAIT 0

WINDOW CLOSE 1
