REM Test: Open and close an AGA lores screen (320x200, 256 colors)
REM AGA mode 7 requires AGA chipset
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,320,200,8,7
PRINT "AGA Lores screen opened"
PRINT "320x200, 8 bitplanes (256 colors), mode 7"
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
