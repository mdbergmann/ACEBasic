REM Test: 256-color palette on AGA screen
REM Verifies PALETTE command works with colors 0-255 using SetRGB32
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,320,200,8,7
WINDOW 1,,(0,0)-(319,199),32,1
PRINT "256-color palette test"
REM Set up a gradient palette (red to blue)
FOR i = 0 TO 255
  PALETTE i, i/255, 0, (255-i)/255
NEXT i
REM Draw vertical lines using colors 0-255
FOR i = 0 TO 255
  COLOR i
  LINE (i+32,50)-(i+32,150)
NEXT i
PRINT "Gradient drawn using 256 colors"
SLEEP FOR 5
WINDOW CLOSE 1
SCREEN CLOSE 1
PRINT "Test completed"
