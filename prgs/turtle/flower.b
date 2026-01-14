'...a flower via turtle graphics

defint i

window 1,"Flower",(0,0)-(640,200),6
font "topaz",8
color 2,1
cls

sub fourside
  for i=1 to 2
    forward 40
    turnright 30
    forward 40
    turnright 150
  next
end sub

sub flower
  for i=1 to 18
    fourside
    turnright 20
  next
end sub

penup
setxy 320,100
pendown

flower

locate 21,1
print "press 'q'..."

while ucase$(inkey$)<>"Q"
wend

window close 1
