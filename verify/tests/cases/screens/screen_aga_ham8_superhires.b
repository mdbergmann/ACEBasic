REM Test: Open and close a HAM8 super-hires screen (1280x256)
REM HAM8 mode 12 requires AGA chipset for 262,144 colors
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,1280,256,8,12
PRINT "HAM8 Super-Hires screen opened"
PRINT "1280x256, 8 bitplanes, mode 12 (HAM8)"
PRINT "262,144 colors from 256-color palette"
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
