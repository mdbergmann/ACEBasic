
'..AGA 256-color screen mode demo in ACE.
'..Demonstrates 8 bitplanes with full 256-color palette.
'
'..Requires AGA chipset (A1200, A4000, CD32).

DEFLNG a-z

'..Check for AGA chipset
IF CHIPSET < 2 THEN
  PRINT "This demo requires AGA chipset."
  PRINT "Please run on A1200, A4000, or CD32."
  STOP
END IF

'..Open 256-color AGA lores screen
SCREEN 1,320,200,8,7

'..Set up a 256-color gradient palette
'..Colors 0-63: Red gradient
'..Colors 64-127: Green gradient
'..Colors 128-191: Blue gradient
'..Colors 192-255: Gray gradient

FOR i = 0 TO 63
  PALETTE i, i/63, 0, 0
NEXT i

FOR i = 0 TO 63
  PALETTE i+64, 0, i/63, 0
NEXT i

FOR i = 0 TO 63
  PALETTE i+128, 0, 0, i/63
NEXT i

FOR i = 0 TO 63
  PALETTE i+192, i/63, i/63, i/63
NEXT i

WINDOW 1,,(0,0)-(320,200),32,1

'..Draw color bars showing all 256 colors
PRINT "AGA 256-Color Demo"
PRINT "Mode 7: 320x200, 8 bitplanes"
PRINT

'..Red bar
FOR c = 0 TO 63
  COLOR c
  LINE (c*5,50)-(c*5+4,70),,bf
NEXT c

'..Green bar
FOR c = 0 TO 63
  COLOR c+64
  LINE (c*5,80)-(c*5+4,100),,bf
NEXT c

'..Blue bar
FOR c = 0 TO 63
  COLOR c+128
  LINE (c*5,110)-(c*5+4,130),,bf
NEXT c

'..Gray bar
FOR c = 0 TO 63
  COLOR c+192
  LINE (c*5,140)-(c*5+4,160),,bf
NEXT c

COLOR 255
LOCATE 23,1
PRINT "Press any key to exit";

WHILE INKEY$="":SLEEP:WEND

WINDOW CLOSE 1
SCREEN CLOSE 1
