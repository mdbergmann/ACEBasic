REM #using ace:submods/turtle/turtle.o
{*
 * Test program for the turtle graphics submodule.
 * Visual verification: draws a square, a triangle, and tests HOME.
 * Also writes state values to ACE:test-output.txt for checking.
 *}

#include <submods/turtle.h>

OPEN "O",#1,"ACE:test-output.txt"
PRINT #1, "Turtle submodule test"

WINDOW 1,"Turtle Test",(0,0)-(640,200),6
FONT "topaz",8
COLOR 2,1
CLS

REM --- Initialize at screen center ---
TgInit(320, 100)
PRINT #1, "Init: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

REM --- Draw a square (side=40) ---
FOR i% = 1 TO 4
  TgForward(40)
  TgTurnRight(90)
NEXT
PRINT #1, "After square: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

REM --- Move right with pen up ---
TgPenUp
TgSetXY(200, 100)
TgPenDown

REM --- Draw a triangle (side=60) ---
TgSetHeading(0)
FOR i% = 1 TO 3
  TgForward(60)
  TgTurnRight(120)
NEXT
PRINT #1, "After triangle: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

REM --- Test HOME: move away, then go home ---
TgPenUp
TgSetXY(500, 50)
TgPenDown
TgSetHeading(0)
TgForward(30)
PRINT #1, "Before home: X=";TgXcor;" Y=";TgYcor
TgHome
PRINT #1, "After home: X=";TgXcor;" Y=";TgYcor

REM --- Test TgBack ---
TgPenUp
TgSetXY(100, 150)
TgPenDown
TgSetHeading(0)
TgForward(50)
TgBack(25)
PRINT #1, "After fwd50+back25: X=";TgXcor;" Y=";TgYcor

REM --- Test TurnLeft ---
TgPenUp
TgSetXY(420, 150)
TgPenDown
TgSetHeading(270)
TgForward(30)
TgTurnLeft(90)
TgForward(30)
PRINT #1, "After TurnLeft: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

PRINT #1, "PASS"
CLOSE #1

LOCATE 24,1
PRINT "Done. Press 'q' to quit.";

WHILE UCASE$(INKEY$) <> "Q" : WEND

WINDOW CLOSE 1
