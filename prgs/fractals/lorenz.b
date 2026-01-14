{ The Lorenz Attractor }

const	true=-1&,false=0&
const 	xscreen=640,yscreen=400
const 	delta=0.01

single	x,y,z
single	xf,yf
longint	lt,rt,top,bottom

on menu gosub handle_menu

sub draw_universal_line(xw,yw)
shared xf,yf
shared lt,rt,top,bottom
  xs = ((xw*xf-lt) * xscreen / (rt-lt)) + xscreen/2
  ys = (yw*yf-bottom) * yscreen / (top-bottom)
  color int(rnd*2)+1
  line step (xs,ys)
end sub

sub universal_x&(xw)
shared xf
shared lt,rt
  universal_x& = ((xw*xf-lt) * xscreen / (rt-lt)) + xscreen/2
end sub

sub universal_y&(yw)
shared yf
shared top,bottom
  universal_y& = (yw*yf-bottom) * yscreen / (top-bottom)
end sub

sub calc
shared x,y,z
  dx = 10.0*(y-x)
  dy = x*(28.0-z)-y
  dz = x*y - (8.0/3.0)*z
  x = x + delta*dx
  y = y + delta*dy
  z = z + delta*dz
end sub

sub LorenzAttractor
shared x,y,z
  x=1 : y=1 : z=1
  calc
  penup
  setxy universal_x&(x),universal_y&(z)
  repeat
    calc
    menu stop
    draw_universal_line(x,z)
    menu on
  until false
end sub
     
{ ** main ** }
screen 1,xscreen,yscreen,2,4
window 1,"Lorenz Attractor",(0,0)-(xscreen,yscreen),0,1

palette 0,0,0,0		'..black
palette 1,1,1,1		'..white
palette 2,0,1,0		'..green

menu 1,0,1,"Project"
menu 1,1,1,"Quit","Q"

lt=0	'..window dimensions
rt=xscreen
top=0
bottom=yscreen

xf=14.0	'..scale up x and y
yf=7.0

LorenzAttractor

END 

handle_menu:
  if menu(0) = 1 and menu(1) = 1 then 
    if MsgBox("Really quit?","Yes","No") then
      window close 1
      screen close 1
      STOP
    end if
  end if
return
