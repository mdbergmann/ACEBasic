REM Test: Open and close an AGA hires screen (640x256, 256 colors)
REM AGA mode 8 requires AGA chipset
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,640,256,8,8
PRINT "AGA Hires screen opened"
PRINT "640x256, 8 bitplanes (256 colors), mode 8"
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
