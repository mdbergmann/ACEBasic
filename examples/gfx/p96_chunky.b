{*
** P96/RTG chunky screen example.
**
** Opens a Picasso96 screen (mode 13) which gives a linear chunky
** framebuffer. Works on any P96-compatible hardware: Vampire SAGA,
** Picasso boards, UAE RTG, etc.
**
** Demonstrates:
**   - Direct framebuffer pixel writes (POKE)
**   - OS drawing primitives on a chunky screen
**   - PRINT/LOCATE text output
**   - LINE, CIRCLE, filled shapes
**   - IDCMP keyboard input via backdrop window
**
** Press any key to exit.
**
** Requires: Picasso96 RTG
*}

CONST SCR_W = 800
CONST SCR_H = 600
CONST SCR_DEPTH = 8

LONGINT bitmapAddr&, frameAddr&, offset&
SHORTINT x%, y%, i%, r%, g%, b%

' Open a 256-color P96/RTG chunky screen.
' Mode 13 = P96, gives a linear chunky framebuffer.
SCREEN 1, SCR_W, SCR_H, SCR_DEPTH, 13
IF ERR = 600 THEN
  PRINT "P96 not available or no matching display mode."
  STOP
END IF

' Open a borderless backdrop window covering the full screen.
' This gives us IDCMP (keyboard, mouse, etc.) for free.
WINDOW 1,"",(0,0)-(SCR_W-1,SCR_H-1),0,1

' Set rainbow palette (entries 0-253).
' Cycle: red -> yellow -> green -> cyan -> blue -> magenta
FOR i% = 0 TO 253
  IF i% < 43 THEN
    r% = 255
    g% = i% * 6
    b% = 0
  ELSEIF i% < 86 THEN
    r% = 255 - (i% - 43) * 6
    g% = 255
    b% = 0
  ELSEIF i% < 128 THEN
    r% = 0
    g% = 255
    b% = (i% - 86) * 6
  ELSEIF i% < 171 THEN
    r% = 0
    g% = 255 - (i% - 128) * 6
    b% = 255
  ELSEIF i% < 213 THEN
    r% = (i% - 171) * 6
    g% = 0
    b% = 255
  ELSE
    r% = 255
    g% = 0
    b% = 255 - (i% - 213) * 6
  END IF
  PALETTE i%, r%/255, g%/255, b%/255
NEXT

' Reserve palette entries for UI: black and white
PALETTE 254, 0, 0, 0
PALETTE 255, 1, 1, 1

' --- Part 1: Direct framebuffer pixel writes ---
' Get the chunky framebuffer address from the screen's BitMap.
' SCREEN(4) returns &Screen->BitMap (embedded struct).
' BitMap->Planes[0] at offset 8 is the linear pixel buffer.
bitmapAddr& = SCREEN(4)
frameAddr& = PEEKL(bitmapAddr& + 8)

' Fill the screen with horizontal rainbow bars via direct POKE.
' Map each row to a color index 0-253 across the full height.
FOR y% = 0 TO SCR_H - 1
  offset& = CLNG(y%) * CLNG(SCR_W)
  i% = (y% * 254) / SCR_H
  FOR x% = 0 TO SCR_W - 1
    POKE frameAddr& + offset& + CLNG(x%), i%
  NEXT
NEXT

' --- Part 2: OS drawing primitives ---
' These all go through graphics.library which P96 patches for chunky.

' Text output
COLOR 255, 254
LOCATE 2, 3
PRINT "P96 Chunky Screen - Drawing Primitives Demo"

' Lines
COLOR 255, 0
LINE (20,80)-(380,80)
LINE (20,80)-(20,280)

' Filled rectangle (LINE with BF)
COLOR 200, 0
LINE (400,80)-(600,180),200,bf

' Outline rectangle (LINE with B)
COLOR 255, 0
LINE (400,200)-(600,280),255,b

' Circles
COLOR 100, 0
CIRCLE (200,180),80
COLOR 50, 0
CIRCLE (200,180),60,,,,f

' Diagonal lines
COLOR 255, 0
LINE (620,80)-(780,280)
LINE (780,80)-(620,280)

' Labels
COLOR 255, 254
LOCATE 20, 3
PRINT "LINE";
LOCATE 20, 25
PRINT "RECT fill/outline";
LOCATE 20, 48
PRINT "Diagonal X"

LOCATE 22, 3
PRINT "CIRCLE open/filled"

' --- Part 3: Info text ---
LOCATE 36, 3
PRINT "Direct POKE + OS primitives on the same P96 chunky buffer."
LOCATE 38, 3
PRINT "Press any key to exit."

' Wait for keypress via IDCMP (INKEY$)
WHILE INKEY$ = ""
WEND

WINDOW CLOSE 1
SCREEN CLOSE 1
