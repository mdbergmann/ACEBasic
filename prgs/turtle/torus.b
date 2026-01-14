'..Torus

defint a-z

screen 1,640,200,1,2
window 1,,(0,10)-(640,200),32,1

penup
setxy 280,110
pendown

for i=1 to 36
 for j=1 to 72
   forward 5
   turnright 5
 next
 forward 3
 turnright 10
next

while inkey$=""
wend 

window close 1
screen close 1
