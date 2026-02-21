REM #using ace:submods/turtle/turtle.o
{*
 * Test program for the turtle graphics submodule.
 * Writes diagnostic steps to file #1 (ace:test-output.txt)
 * so output is visible even after WINDOW changes PRINT target.
 *}

#include <submods/turtle.h>

REM Force _openmathtrans in startup so _MathTransBase is initialized.
REM The turtle module uses COS/SIN via _MathTransBase but the compiler
REM only calls _openmathtrans if the MAIN program references it.
REM This is a known compiler limitation (see specs/submod-test-runner-state.txt).
SINGLE _forceMathtrans
_forceMathtrans = SIN(0.1)

PRINT "Turtle submodule test"

WINDOW 1,"Turtle Test",(0,0)-(640,200),6
FONT "topaz",8
COLOR 2,1
CLS

REM --- Initialize at screen center ---
TgInit(320, 100)
PRINT "Init: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

REM --- Draw a square (side=40) ---
FOR i% = 1 TO 4
  TgForward(40)
  TgTurnRight(90)
NEXT
PRINT "After square: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

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
PRINT "After triangle: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

REM --- Test HOME: move away, then go home ---
TgPenUp
TgSetXY(500, 50)
TgPenDown
TgSetHeading(0)
TgForward(30)
PRINT "Before home: X=";TgXcor;" Y=";TgYcor
TgHome
PRINT "After home: X=";TgXcor;" Y=";TgYcor

REM --- Test TgBack ---
TgPenUp
TgSetXY(100, 150)
TgPenDown
TgSetHeading(0)
TgForward(50)
TgBack(25)
PRINT "After fwd50+back25: X=";TgXcor;" Y=";TgYcor

REM --- Test TurnLeft ---
TgPenUp
TgSetXY(420, 150)
TgPenDown
TgSetHeading(270)
TgForward(30)
TgTurnLeft(90)
TgForward(30)
PRINT "After TurnLeft: X=";TgXcor;" Y=";TgYcor;" H=";TgHeading

PRINT "PASS"

SLEEP FOR 2

WINDOW CLOSE 1
