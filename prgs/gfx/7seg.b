{*
** 7-segment digit string display.
**
** Author: David J Benn
**   Date: 2nd,3rd,13th December 1994
**
**	  1
**	 ____
**    2 |    | 3
**    	|____|
**      | 4  |
**    5	|____| 6
**
**	  7
**
** Values passed to DrawSegment (see below) are based upon the
** following grid:
**
**	0 1 2 3 4 5 6
**    0 xxxxxxxxxxxxx
**    1 xxxxxxxxxxxxx
**    2 xx	   xx
**    3 xxxxxxxxxxxxx
**    4 xxxxxxxxxxxxx
**    5 xx	   xx
**    6 xxxxxxxxxxxxx
**    7 xxxxxxxxxxxxx
**
** Modify xScale and yScale CONSTs to change the size
** and shape of the digits, eg.
**
**	xScale	yScale
**	------  ------
**	25	17	
**	15	10
**	5	3
**	2	1
*}

CONST xScale = 15, yScale = 10
CONST digitWidth = 6, gap = 1
CONST true=-1&, false=0&

SHORTINT xOff,yOff,colr

DIM SHORTINT digit(9,7)

{*
** Store 7-segment configuration for each digit (1=ON, 0=OFF).
** More patterns can easily be added here, eg. for hex. digits.
*}
FOR i=0 TO 9
  FOR j=1 TO 7
    READ digit(i,j)
  NEXT
NEXT

{*
**   1 2 3 4 5 6 7 	<- segments
*}
DATA 1,1,1,0,1,1,1	'..0
DATA 0,0,1,0,0,1,0	'..1
DATA 1,0,1,1,1,0,1	'..2
DATA 1,0,1,1,0,1,1	'..3
DATA 0,1,1,1,0,1,0	'..4
DATA 1,1,0,1,0,1,1	'..5
DATA 0,1,0,1,1,1,1	'..6
DATA 1,0,1,0,0,1,0	'..7
DATA 1,1,1,1,1,1,1	'..8
DATA 1,1,1,1,0,1,0	'..9

SUB DrawSegment(SHORTINT x1,SHORTINT y1,SHORTINT x2,SHORTINT y2)
SHARED xOff,yOff,colr
  '..Render a single segment.
  LINE (xOff+x1*xScale,yOff+y1*yScale)- ~
       (xOff+x2*xScale,yOff+y2*yScale),colr,bf
END SUB

SUB PlotDigit(SHORTINT n)
SHARED digit,xOff
  '..Render a whole digit one segment at a time.
  FOR i=1 TO 7
    IF digit(n,i) = 1 THEN
      CASE
    	i = 1 : DrawSegment(0,0,6,1)
    	i = 2 : DrawSegment(0,0,1,4)
    	i = 3 : DrawSegment(5,0,6,4)
    	i = 4 : DrawSegment(0,3,6,4)
    	i = 5 : DrawSegment(0,3,1,7)
    	i = 6 : DrawSegment(5,3,6,7)
    	i = 7 : DrawSegment(0,6,6,7)
      END CASE
    END IF
  NEXT
  '..Advance to the next digit position.
  xOff = xOff + digitWidth*xScale + gap*xScale
END SUB

SUB DisplayNumber(STRING theNumber)
  '..Render a string of digits.
  FOR i=1 TO LEN(theNumber)
    PlotDigit(VAL(MID$(theNumber,i,1)))
  NEXT
END SUB

{*
** Main: seconds display.
*}
SCREEN 1,640,200,3,2
WINDOW 1,"Seconds",(0,0)-(640,200),31,1

MENU 1,0,1,"Project"
MENU 1,1,1,"Quit","Q"
ON MENU GOSUB handle_menu
MENU ON

ON WINDOW GOSUB handle_window
WINDOW ON

PALETTE 0,0,0,0
PALETTE 1,1,1,1
PALETTE 2,0,0,1
PALETTE 3,0,1,0
PALETTE 4,0,1,1
PALETTE 5,1,0,0
PALETTE 6,1,0,1
PALETTE 7,1,1,0

'..Continuously display seconds.
yOff=50
finished = false

REPEAT
  xOff = 190
  colr = 7
  sec$ = RIGHT$(TIME$,2)
  DisplayNumber(sec$)
  time0=TIMER
  WHILE TIMER<time0+1:WEND
  xOff = 190
  colr = 0
  DisplayNumber(sec$)
UNTIL finished

WINDOW CLOSE 1
SCREEN CLOSE 1
STOP

{*
** Event handlers.
*}
handle_menu:
  IF MENU(0) = 1 AND MENU(1) = 1 THEN finished = true
RETURN

handle_window:
  finished = true
RETURN
