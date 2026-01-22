REM Test: Open and close a HAM (hold-and-modify) screen
REM HAM mode requires 6 bitplanes for 4096 colors
SCREEN 1,320,200,6,5
PRINT "HAM screen opened"
PRINT "320x200, 6 bitplanes, mode 5 (HAM)"
SLEEP FOR 5
SCREEN CLOSE 1
