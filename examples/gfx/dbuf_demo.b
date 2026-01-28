{* Double Buffer Demo - Bouncing Ball
   Demonstrates tear-free animation using DoubleBuffer.h *}

#include <ace/DoubleBuffer.h>

CONST scrW = 320
CONST scrH = 256
CONST ballR = 15

'..Open a lores screen
SCREEN 1,scrW,scrH,4,1
WINDOW 1,,(0,0)-(scrW,scrH),32,1

PALETTE 0,0,0,0
PALETTE 1,1,1,1
PALETTE 2,1,0,0
PALETTE 3,0,0,1

'..Initialize double buffering
DbufInit

IF NOT DbufReady THEN
  PRINT "Failed TO allocate BACK buffer!"
  WINDOW CLOSE 1
  SCREEN CLOSE 1
  STOP
END IF

'..Ball state
SINGLE bx, by, dx, dy
bx = scrW / 2
by = scrH / 2
dx = 3
dy = 2

'..Animation loop
WHILE INKEY$ = ""
  '..Clear back buffer
  LINE (0,0)-(scrW-1,scrH-1),0,bf

  '..Update position
  bx = bx + dx
  by = by + dy

  '..Bounce
  IF bx - ballR < 0 OR bx + ballR >= scrW THEN
    dx = -dx
    bx = bx + dx
  END IF
  IF by - ballR < 0 OR by + ballR >= scrH THEN
    dy = -dy
    by = by + dy
  END IF

  '..Draw ball
  CIRCLE (CINT(bx), CINT(by)), ballR, 2,,,,F
  CIRCLE (CINT(bx), CINT(by)), ballR, 1

  '..Info text
  COLOR 3
  LOCATE 1,1
  PRINTS "Double Buffer Demo - Press any key"

  '..Swap buffers
  DbufSwap
WEND

'..Cleanup before closing screen
DbufCleanup

WINDOW CLOSE 1
SCREEN CLOSE 1
