REM #using ace:submods/turtle/turtle.o
REM #using ace:submods/testkit/testkit.o
{*
 * Test program for the turtle graphics submodule.
 * Assertions run after WINDOW CLOSE so output goes to stdout.
 *}

#include <submods/turtle.h>
#include <submods/testkit.h>

REM Force _openmathtrans in startup so _MathTransBase is initialized.
SINGLE _forceMathtrans
_forceMathtrans = SIN(0.1)

SINGLE afterSquareH, afterTriH, afterTurnH
SINGLE homeX, homeY

PRINT "=== Turtle Tests ==="

TkInit

WINDOW 1,"Turtle Test",(0,0)-(640,200),6
FONT "topaz",8
COLOR 2,1
CLS

REM --- Initialize at screen center ---
TgInit(320, 100)

REM --- Draw a square (side=40) ---
FOR i% = 1 TO 4
  TgForward(40)
  TgTurnRight(90)
NEXT
afterSquareH = TgHeading

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
afterTriH = TgHeading

REM --- Test HOME: move away, then go home ---
TgPenUp
TgSetXY(500, 50)
TgPenDown
TgSetHeading(0)
TgForward(30)
TgHome
homeX = TgXcor
homeY = TgYcor

REM --- Test TgBack ---
TgPenUp
TgSetXY(100, 150)
TgPenDown
TgSetHeading(0)
TgForward(50)
TgBack(25)

REM --- Test TurnLeft ---
TgPenUp
TgSetXY(420, 150)
TgPenDown
TgSetHeading(270)
TgForward(30)
TgTurnLeft(90)
TgForward(30)
afterTurnH = TgHeading

SLEEP FOR 2

WINDOW CLOSE 1

REM --- Assertions after WINDOW CLOSE so output goes to stdout ---
PRINT "afterSquareH="; afterSquareH
PRINT "afterTriH="; afterTriH
PRINT "afterTurnH="; afterTurnH
PRINT "homeX="; homeX; " homeY="; homeY

TkAssertEqFloat(homeX, 320, "After home X=320")
TkAssertEqFloat(homeY, 100, "After home Y=100")

TkSummary
