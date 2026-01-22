REM Test: Open and close an AGA super-hires screen (1280x256, 16 colors)
REM AGA mode 9 requires AGA chipset
REM Note: Using 4 bitplanes as 8 bitplanes at 1280 width needs significant chip RAM
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,1280,256,4,9
PRINT "AGA Super-Hires screen opened"
PRINT "1280x256, 4 bitplanes (16 colors), mode 9"
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
