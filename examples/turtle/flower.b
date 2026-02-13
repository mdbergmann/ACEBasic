REM #using ace:submods/turtle/turtle.o
'...a flower via turtle graphics

#include <submods/turtle.h>

defint i

window 1,"Flower",(0,0)-(640,200),6
font "topaz",8
color 2,1
cls

sub fourside
  for i=1 to 2
    TgForward(40)
    TgTurnRight(30)
    TgForward(40)
    TgTurnRight(150)
  next
end sub

sub flower
  for i=1 to 18
    fourside
    TgTurnRight(20)
  next
end sub

TgInit(320, 100)

flower

locate 21,1
print "press 'q'..."

while ucase$(inkey$)<>"Q"
wend

window close 1
