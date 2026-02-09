REM Test: P96/RTG HiColor screen with COLOR r, g, b
REM Requires Picasso96 to be installed
SCREEN 1,800,600,16,13
IF ERR = 600 THEN PRINT "P96 not available - skipping test" : STOP
PRINT "P96 HiColor screen opened"
PRINT "800x600, 16-bit (65536 colors), mode 13 (RTG)"
REM Test COLOR r, g, b (3-arg RGB form)
COLOR 255, 0, 0
LINE (10,50)-(200,50)
COLOR 0, 255, 0
LINE (10,70)-(200,70)
COLOR 0, 0, 255
LINE (10,90)-(200,90)
COLOR 255, 255, 0
CIRCLE (400,300),100
COLOR 255, 128, 0
LINE (300,200)-(500,400),b
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
