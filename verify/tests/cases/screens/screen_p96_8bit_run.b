REM Test: Open and close a P96/RTG screen (800x600, 256 colors)
REM Requires Picasso96 to be installed
SCREEN 1,800,600,8,13
IF ERR = 600 THEN PRINT "P96 not available - skipping test" : STOP
PRINT "P96 screen opened"
PRINT "800x600, 8-bit (256 colors), mode 13 (RTG)"
LINE (10,50)-(200,150),2,bf
LINE (50,80)-(180,130),3,bf
CIRCLE (400,300),100,4
SLEEP FOR 3
SCREEN CLOSE 1
PRINT "Test completed"
