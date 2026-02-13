{*
 * Turtle Graphics Submodule Header
 *
 * Logo-style turtle graphics for ACE BASIC.
 *
 * Usage:
 *   EXTERNAL turtle
 *   '$include "submods/turtle.h"
 *
 *   WINDOW 1,"My Window",(0,0)-(640,200),6
 *   TgInit(320, 100)     ' set home position and reset state
 *   TgForward(50)        ' move forward 50 pixels (draws if pen down)
 *   TgTurnRight(90)      ' turn 90 degrees to the right
 *
 * Heading convention: 0=right, 90=down, 180=left, 270=up.
 * Initial heading after TgInit is 270 (up).
 * Pen starts down (drawing enabled).
 *
 * API mapping from former built-in commands:
 *   FORWARD n       -> TgForward(n)       (n is SINGLE)
 *   BACK n          -> TgBack(n)          (n is SINGLE)
 *   HOME            -> TgHome
 *   PENDOWN         -> TgPenDown
 *   PENUP           -> TgPenUp
 *   SETHEADING n    -> TgSetHeading(n)    (n is SHORTINT degrees)
 *   SETXY x, y      -> TgSetXY(x, y)     (SHORTINT coords)
 *   TURN n          -> TgTurn(n)          (n is SHORTINT degrees)
 *   TURNLEFT n      -> TgTurnLeft(n)      (n is SHORTINT degrees)
 *   TURNRIGHT n     -> TgTurnRight(n)     (n is SHORTINT degrees)
 *   HEADING         -> TgHeading          (returns SHORTINT)
 *   XCOR            -> TgXcor             (returns SHORTINT)
 *   YCOR            -> TgYcor             (returns SHORTINT)
 *   (new)           -> TgInit(x, y)       (set home + reset)
 *   (new)           -> TgSetRatio(r)      (set pixel aspect ratio)
 *
 * Pixel aspect ratio constants (pass to TgSetRatio):
 *   TG_RATIO_LORES       = 0.9375   (320x200)
 *   TG_RATIO_HIRES       = 1.875    (640x200, default)
 *   TG_RATIO_LORES_LACE  = 0.46875  (320x400)
 *   TG_RATIO_HIRES_LACE  = 0.9375   (640x400)
 *   TG_RATIO_SUPERHIRES  = 3.75     (1280x200)
 *}

LIBRARY "mathffp"
LIBRARY "mathtrans"

REM --- Pixel aspect ratio constants ---
CONST TG_RATIO_LORES       = 0.9375
CONST TG_RATIO_HIRES       = 1.875
CONST TG_RATIO_LORES_LACE  = 0.46875
CONST TG_RATIO_HIRES_LACE  = 0.9375
CONST TG_RATIO_SUPERHIRES  = 3.75

DECLARE SUB TgInit(SHORTINT initX, SHORTINT initY) EXTERNAL
DECLARE SUB TgForward(SINGLE dist) EXTERNAL
DECLARE SUB TgBack(SINGLE dist) EXTERNAL
DECLARE SUB TgHome EXTERNAL
DECLARE SUB TgPenDown EXTERNAL
DECLARE SUB TgPenUp EXTERNAL
DECLARE SUB TgSetHeading(SHORTINT n) EXTERNAL
DECLARE SUB TgSetXY(SHORTINT x, SHORTINT y) EXTERNAL
DECLARE SUB TgSetRatio(SINGLE ratio) EXTERNAL
DECLARE SUB TgTurn(SHORTINT n) EXTERNAL
DECLARE SUB TgTurnLeft(SHORTINT n) EXTERNAL
DECLARE SUB TgTurnRight(SHORTINT n) EXTERNAL
DECLARE SUB SHORTINT TgHeading EXTERNAL
DECLARE SUB SHORTINT TgXcor EXTERNAL
DECLARE SUB SHORTINT TgYcor EXTERNAL
