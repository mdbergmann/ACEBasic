REM Test: Open and close a lores interlaced screen (320x400)
SCREEN 1,320,400,2,3
PRINT "Lores interlaced screen opened"
PRINT "320x400, 2 bitplanes (4 colors), mode 3"
SLEEP FOR 5
SCREEN CLOSE 1
