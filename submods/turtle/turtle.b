{*
 * Turtle Graphics Submodule for ACE BASIC
 *
 * Provides Logo-style turtle graphics as an external module.
 * Replaces the former built-in turtle commands with equivalent SUB calls.
 *
 * Usage:
 *   EXTERNAL turtle
 *   '$include "submods/turtle.h"
 *
 *   WINDOW 1,"...",(0,0)-(640,200),6
 *   TgInit(320, 100)
 *   TgForward(50)
 *   TgTurnRight(90)
 *
 * Call TgInit before using any other turtle commands.
 * A WINDOW must be open since turtle draws to the current window.
 *
 * NOTE: Heading normalization uses INT(d/360)*360 for modulo since
 * ACE's "/" is always float division (standard BASIC).
 * CONST SINGLE values generate wrong FFP literals in modules (-m),
 * so literal values are used for the ratio assignments.
 *}

REM --- Pixel aspect ratio constants ---
CONST TG_RATIO_LORES       = 0.9375
CONST TG_RATIO_HIRES       = 1.875
CONST TG_RATIO_LORES_LACE  = 0.46875
CONST TG_RATIO_HIRES_LACE  = 0.9375
CONST TG_RATIO_SUPERHIRES  = 3.75

REM --- Module-level state ---
SHORTINT tgInitX
SHORTINT tgInitY
SHORTINT tgTx
SHORTINT tgTy
SHORTINT tgDegs
SHORTINT tgPen
SINGLE _tgXYRatio

REM --- Initialize turtle state and set home position ---
REM Also auto-detects pixel aspect ratio from the current screen.
SUB TgInit(SHORTINT initX, SHORTINT initY) EXTERNAL
SHARED tgInitX, tgInitY, tgTx, tgTy, tgDegs, tgPen, _tgXYRatio
  LONGINT scrAddr
  SHORTINT scrW, scrH

  tgInitX = initX
  tgInitY = initY
  tgTx = initX
  tgTy = initY
  tgDegs = 270
  tgPen = 1

  REM Guess pixel aspect ratio from screen dimensions
  scrAddr = PEEKL(WINDOW(7) + 46)  ' Window->WScreen
  scrW = PEEKW(scrAddr + 12)       ' Screen->Width
  scrH = PEEKW(scrAddr + 14)       ' Screen->Height

  REM Use literal values (not CONST names) due to compiler bug
  IF scrW >= 1280 THEN
    _tgXYRatio = 3.75
  ELSEIF scrW >= 640 THEN
    _tgXYRatio = 1.875
  ELSE
    _tgXYRatio = 0.9375
  END IF

  REM Interlace doubles the vertical resolution, halving the ratio
  IF scrH >= 300 THEN _tgXYRatio = _tgXYRatio / 2
END SUB

REM --- Set pixel aspect ratio (use TG_RATIO_* constants) ---
SUB TgSetRatio(SINGLE ratio) EXTERNAL
SHARED _tgXYRatio
  _tgXYRatio = ratio
END SUB

REM --- Move by dist pixels at given angle (private helper) ---
SUB _TgMove(SHORTINT angle, SINGLE dist) EXTERNAL
SHARED tgTx, tgTy, tgPen, _tgXYRatio
  SINGLE theta
  SHORTINT dx, dy, newX, newY

  theta = angle * .0174533
  dx = _tgXYRatio * dist * COS(theta)
  dy = dist * SIN(theta)

  newX = tgTx + dx
  newY = tgTy + dy

  IF tgPen = 1 THEN
    LINE (tgTx, tgTy)-(newX, newY)
  END IF

  tgTx = newX
  tgTy = newY
END SUB

REM --- Move forward by dist pixels ---
SUB TgForward(SINGLE dist) EXTERNAL
SHARED tgDegs
  _TgMove(tgDegs, dist)
END SUB

REM --- Move backward by dist pixels ---
SUB TgBack(SINGLE dist) EXTERNAL
SHARED tgDegs
  SHORTINT angle
  angle = tgDegs + 180
  IF angle >= 360 THEN angle = angle - 360
  _TgMove(angle, dist)
END SUB

REM --- Return to home position (draws if pen down) ---
SUB TgHome EXTERNAL
SHARED tgInitX, tgInitY, tgTx, tgTy, tgPen
  IF tgPen = 1 THEN
    LINE (tgTx, tgTy)-(tgInitX, tgInitY)
  END IF
  tgTx = tgInitX
  tgTy = tgInitY
END SUB

REM --- Put pen down (drawing enabled) ---
SUB TgPenDown EXTERNAL
SHARED tgPen
  tgPen = 1
END SUB

REM --- Lift pen up (drawing disabled) ---
SUB TgPenUp EXTERNAL
SHARED tgPen
  tgPen = 0
END SUB

REM --- Set heading to n degrees (0=right, 90=down, 180=left, 270=up) ---
SUB TgSetHeading(SHORTINT n) EXTERNAL
SHARED tgDegs
  SHORTINT d
  d = n - INT(n / 360) * 360
  IF d < 0 THEN d = d + 360
  tgDegs = d
END SUB

REM --- Move to position (x,y) - draws if pen down ---
SUB TgSetXY(SHORTINT x, SHORTINT y) EXTERNAL
SHARED tgTx, tgTy, tgPen
  IF tgPen = 1 THEN
    LINE (tgTx, tgTy)-(x, y)
  END IF
  tgTx = x
  tgTy = y
END SUB

REM --- Turn by n degrees from current heading ---
SUB TgTurn(SHORTINT n) EXTERNAL
SHARED tgDegs
  SHORTINT d
  d = tgDegs + n
  d = d - INT(d / 360) * 360
  IF d < 0 THEN d = d + 360
  tgDegs = d
END SUB

REM --- Turn left by n degrees ---
SUB TgTurnLeft(SHORTINT n) EXTERNAL
SHARED tgDegs
  SHORTINT d
  d = tgDegs - n
  d = d - INT(d / 360) * 360
  IF d < 0 THEN d = d + 360
  tgDegs = d
END SUB

REM --- Turn right by n degrees ---
SUB TgTurnRight(SHORTINT n) EXTERNAL
SHARED tgDegs
  SHORTINT d
  d = tgDegs + n
  d = d - INT(d / 360) * 360
  IF d < 0 THEN d = d + 360
  tgDegs = d
END SUB

REM --- Return current heading in degrees ---
SUB SHORTINT TgHeading EXTERNAL
SHARED tgDegs
  TgHeading = tgDegs
END SUB

REM --- Return current X coordinate ---
SUB SHORTINT TgXcor EXTERNAL
SHARED tgTx
  TgXcor = tgTx
END SUB

REM --- Return current Y coordinate ---
SUB SHORTINT TgYcor EXTERNAL
SHARED tgTy
  TgYcor = tgTy
END SUB
