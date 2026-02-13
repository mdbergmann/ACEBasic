REM #using ace:submods/turtle/turtle.o

'...Fractal Snowflake.
'...You'll need a large stack (make it 40000 bytes) for this one.

#include <submods/turtle.h>

sub koch(depth,side)
 if depth = 0 then
   TgForward(side)
 else
  koch(depth-1,side\3) : TgTurnLeft(60)
  koch(depth-1,side\3) : TgTurnRight(120)
  koch(depth-1,side\3) : TgTurnLeft(60)
  koch(depth-1,side\3) :
 end if
end sub

sub snowflake(depth,side)
 koch(depth,side) : TgTurnRight(120)
 koch(depth,side) : TgTurnRight(120)
 koch(depth,side) : TgTurnRight(120)
end sub

screen 1,640,400,2,4
window 1,"Fractal Snowflake",(0,75)-(640,325),6,1
font "topaz",8
color 2,1

TgInit(250, 225)

another$="Y"
while another$="Y"
 cls
 locate 1,1
 input "Enter depth (try 4):   ",depth
 input "Enter sides (try 250): ",sides

 cls

 TgPenUp
 TgSetXY(250, 225)
 TgSetHeading(270)
 TgPenDown
 snowflake(depth,sides)

 locate 2,1
 print "Another (y/n)?"
 another$=""
 while another$<>"Y" and another$<>"N"
   another$=ucase$(inkey$)
 wend
wend

window close 1
screen close 1
