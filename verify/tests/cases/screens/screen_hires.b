REM Test: Open and close a hires screen (640x200, 4 colors)
SCREEN 1,640,200,2,2
PRINT "Hires screen opened"
PRINT "640x200, 2 bitplanes (4 colors), mode 2"
SLEEP FOR 5
SCREEN CLOSE 1
