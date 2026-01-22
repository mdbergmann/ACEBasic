REM Test: Open and close a hires interlaced screen (640x400)
SCREEN 1,640,400,2,4
PRINT "Hires interlaced screen opened"
PRINT "640x400, 2 bitplanes (4 colors), mode 4"
SLEEP FOR 5
SCREEN CLOSE 1
