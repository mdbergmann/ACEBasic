REM Test: Open and close an extra-halfbrite screen
REM EHB mode uses 6 bitplanes for 64 colors
SCREEN 1,320,200,6,6
PRINT "Extra-halfbrite screen opened"
PRINT "320x200, 6 bitplanes, mode 6 (EHB)"
SLEEP FOR 5
SCREEN CLOSE 1
