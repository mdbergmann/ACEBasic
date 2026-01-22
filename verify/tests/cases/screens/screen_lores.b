REM Test: Open and close a lores screen (320x200, 4 colors)
SCREEN 1,320,200,2,1
PRINT "Lores screen opened"
PRINT "320x200, 2 bitplanes (4 colors), mode 1"
SLEEP FOR 5
SCREEN CLOSE 1
