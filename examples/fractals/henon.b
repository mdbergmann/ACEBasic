{ Henon Attractors -- cf Becker & Dorfler, pp 62-64,68 }

const 	xscreen=640,yscreen=400

const	maxReal = 1E+18	
const	maxInt = 2147483647
const	true = -1&

'..planetary Henon attractor data
const	lt = -1.2
const	rt = 1.2
const	top = 1.2
const	bottom = -1.2
const 	phaseAngle = 1.111
const	x0 = 0.098
const	y0 = 0.061
const	dx0 = 0.04
const	dy0 = 0.03
const	orbitnumber = 40
const	pointnumber = 700

on menu gosub handle_menu
menu on
  
sub set_universal_point(xw,yw)
  xs = ((xw-lt) * xscreen / (rt-lt)) 
  ys = (yw-bottom) * yscreen / (top-bottom)
  pset (xs,ys)
end sub

sub HenonAttractor
single	cosA,sinA
single	xNew,yNew,xOld,yOld
single	deltaxperpixel,deltayperpixel
longint	i,j
longint	ok1,ok2
shortint pcolr

  cosA = cos(phaseAngle) : sinA = sin(phaseAngle)
  xOld = x0 : yOld = y0	'..starting point of first orbit
  deltaxperpixel = xscreen/(rt-lt)
  deltayperpixel = yscreen/(top-bottom)

  for j=1 to orbitnumber 
    i=1
    '..set foreground pen color
    pcolr = (pcolr + 1) mod 3 
    color pcolr+1
    while i <= pointnumber 
      if (abs(xOld) <= maxReal) and (abs(yOld) <= maxReal) then
  	xNew = xOld*cosA - (yOld - xOld*xOld)*sinA
	yNew = xOld*sinA + (yOld - xOld*xOld)*cosA
	ok1 = (abs(xNew-lt) < maxInt/deltaxperpixel)
	ok2 = (abs(top-yNew) < maxInt/deltayperpixel)
	if ok1 and ok2 then
	  set_universal_point(xNew,yNew)
	end if	
	xOld = xNew
	yOld = yNew
      end if  
      i = i + 1
    wend
    xOld = x0 + j * dx0
    yOld = y0 + j * dy0
  next	    
end sub

{ ** main ** }
screen 1,xscreen,yscreen,3,4
window 1,"Planetary Henon Attractor",(0,0)-(xscreen,yscreen),0,1

palette 0,0,0,0		'..black
palette 1,1,1,1		'..white
palette 2,0,1,0		'..green
palette 3,1,0,0		'..red
palette 4,1,1,0.13	'..yellow
palette 5,1,0.13,0.93	'..violet

menu 1,0,1,"Project"
menu 1,1,1,"Quit","Q"

HenonAttractor

while true
  sleep
wend

END

handle_menu:
  if menu(0) = 1 and menu(1) = 1 then 
    window close 1
    screen close 1
    STOP
  end if
return
