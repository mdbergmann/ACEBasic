REM Test: Open and close a HAM8 hires screen (640x256)
REM HAM8 mode 11 requires AGA chipset for 262,144 colors
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,640,256,8,11
PRINT "HAM8 Hires screen opened"
PRINT "640x256, 8 bitplanes, mode 11 (HAM8)"
PRINT "262,144 colors from 256-color palette"
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
