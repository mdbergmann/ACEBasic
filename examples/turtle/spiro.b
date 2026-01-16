'...SpiroGraph

defint a-z

const true = -1&, false = 0&

window 1,"SpiroGraph",(0,0)-(640,400),6	 '..good for productivity mode on A1200

font "topaz",8

menu 1,0,1,"Project"
menu 1,1,1,"Quit","Q"
on menu gosub quit
menu on

color 2,1
cls

sub poly(sides,length)
  for i=1 to sides
    forward length
    turnright 360\sides
  next
end sub

sub spiro(sides,length)
  repeat
    poly(sides,length)
    turnright 360\sides
    penup
    setxy 320,200
    pendown
  until false
end sub

'..main
locate 2,1
input "How many sides per polygon? (eg. 9)  ",sides
input "Length of each side?        (eg. 30) ",length
cls

penup
setxy 320,200
pendown

spiro(sides,length)

while true
wend

quit: 
  if menu(0) <> 1 or menu(1) <> 1 then return 
  window close 1
END
