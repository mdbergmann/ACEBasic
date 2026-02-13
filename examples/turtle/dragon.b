REM #using ace:submods/turtle/turtle.o
'..Dragon Curve
'..(recursive).

#include <submods/turtle.h>

sub dragon(depth,side)
 if depth = 0 then
   TgForward(side)
 else
   if depth > 0 then
    dragon(depth-1,side)
    TgTurnRight(90)
    dragon(-(depth-1),side)
   else
    dragon(-(depth+1),side)
    TgTurnRight(270)
    dragon(depth+1,side)
   end if
 end if
end sub

window 1,"Dragon Curve",(0,0)-(640,250),6
font "topaz",8
color 2,1

TgInit(320, 125)

another$="Y"
while another$="Y"
 cls
 locate 1,1
 input "Enter depth (try 10): ",depth
 input "Enter sides (try 3):  ",sides

 cls

 TgPenUp
 TgSetXY(320, 125)
 TgSetHeading(270)
 TgPenDown
 dragon(depth,sides)

 locate 26,1
 print "another (y/n)?"
 another$=""
 while another$<>"Y" and another$<>"N"
   another$=ucase$(inkey$)
 wend
wend

window close 1
