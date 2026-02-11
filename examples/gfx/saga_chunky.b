{*
** SAGA/P96 chunky screen example.
**
** Opens a P96/RTG screen (mode 13) which gives a linear chunky
** framebuffer. On the Vampire, the SAGA P96 driver maps this
** directly to SAGA hardware.
**
** A borderless backdrop window provides IDCMP for keyboard input.
** PRINT/LOCATE work on top of direct pixel writes.
**
** Press any key to exit.
**
** Requires: Picasso96 with a compatible graphics card (or Vampire SAGA)
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

' Set rainbow palette (256 entries).
' Cycle: red -> yellow -> green -> cyan -> blue -> magenta
FOR i% = 0 TO 255
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

' Get the chunky framebuffer address from the screen's BitMap.
' SCREEN(4) returns &Screen->BitMap (embedded struct).
' BitMap->Planes[0] at offset 8 is the framebuffer pointer.
' For a P96 chunky screen, Planes[0] is the linear pixel buffer.
bitmapAddr& = SCREEN(4)
frameAddr& = PEEKL(bitmapAddr& + 8)

' Fill the screen with horizontal rainbow bars.
' Map each row to a color index 0-255 across the full height.
' This writes directly into the chunky framebuffer: one byte per pixel.
FOR y% = 0 TO SCR_H - 1
  offset& = CLNG(y%) * CLNG(SCR_W)
  i% = (y% * 256) / SCR_H
  FOR x% = 0 TO SCR_W - 1
    POKE frameAddr& + offset& + CLNG(x%), i%
  NEXT
NEXT

' Demonstrate that PRINT still works on top of direct pixel writes.
' The OS draws text through the same RastPort into the same bitmap.
COLOR 1, 0
LOCATE 2, 5
PRINT "P96 Chunky - Direct framebuffer access"
LOCATE 4, 5
PRINT "IDCMP + PRINT work alongside pixel writes."
LOCATE 6, 5
PRINT "Press any key to exit."

' Wait for keypress via IDCMP (INKEY$)
WHILE INKEY$ = ""
WEND

WINDOW CLOSE 1
SCREEN CLOSE 1
