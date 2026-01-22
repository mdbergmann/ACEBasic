REM Test: Open and close a HAM8 lores screen (320x200)
REM HAM8 mode 10 requires AGA chipset for 262,144 colors
IF CHIPSET < 2 THEN PRINT "AGA required - skipping test" : END
SCREEN 1,320,200,8,10
PRINT "HAM8 Lores screen opened"
PRINT "320x200, 8 bitplanes, mode 10 (HAM8)"
PRINT "262,144 colors from 256-color palette"
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
