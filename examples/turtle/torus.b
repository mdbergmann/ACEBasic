REM #using ace:submods/turtle/turtle.o
'..Torus

#include <submods/turtle.h>

defint a-z

screen 1,640,200,1,2
window 1,,(0,10)-(640,200),32,1

TgInit(280, 110)

for i=1 to 36
 for j=1 to 72
   TgForward(5)
   TgTurnRight(5)
 next
 TgForward(3)
 TgTurnRight(10)
next

while inkey$=""
wend

window close 1
screen close 1
