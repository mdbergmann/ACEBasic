'...IFS-compressed image reconstructor

SUB help
  dummy=MsgBox("Select project type and color.","Continue")
END SUB

SUB about
  msg$ = "Iterated Function System by David Benn "+chr$(169)
  msg$ = msg$+" 1994 for Karen."
  dummy=MsgBox(msg$,"Continue")
END SUB

SUB enable_menus
  menu 1,0,1	'..enable project menu
  menu 2,0,1	'..enable color menu
  menu 3,2,0	'..disable "stop" item
END SUB

randomize timer

'...read probability levels, x & y factors and IFS data...
CONST pats=6

dim n%(pats),xscale%(pats),yscale%(pats),xoffset%(pats),yoffset%(pats)

FOR R=1 TO pats
  read n%(r),xscale%(r),yscale%(r),xoffset%(r),yoffset%(r)
NEXT R

DATA 3,150,115,160,60	'..Sierpinski triangle
DATA 4,150,75,225,70	'..Square
DATA 4,25,12,285,60	'..Fern
DATA 4,250,225,300,60	'..Tree #1
DATA 4,150,75,160,40	'..Tree #2
DATA 4,54,26,230,50	'..Sunflower
  
pt=0      '...reset probability counter

dim a(pats,4),b(pats,4),c(pats,4),d(pats,4),e(pats,4),f(pats,4),p(pats,4)

FOR I=1 TO 3
  read a(1,I),b(1,I),c(1,I),d(1,I),e(1,I),f(1,I),pk
  pt=pt+pk
  p(1,I)=pt
NEXT I

FOR J=2 TO pats 
pt=0             '...reset probability counter 
  FOR L=1 TO 4
    read a(J,L)
    read b(J,L)
    read c(J,L)
    read d(J,L)
    read e(J,L)
    read f(J,L),pk
    pt=pt+pk
    p(J,L)=pt
  NEXT L
NEXT J

'...Sierpinski Triangle...

DATA .5,0,0,.5,0,0,.33
DATA .5,0,0,.5,1,0,.33
DATA .5,0,0,.5,.5,.5,.34

'...Square...

DATA .5,0,0,.5,0,0,.25
DATA .5,0,0,.5,.5,0,.25
DATA .5,0,0,.5,0,.5,.25
DATA .5,0,0,.5,.5,.5,.25

'...Fern...

DATA 0,0,0,.16,0,0,.01
DATA .2,-.26,.23,.22,0,1.6,.07
DATA -.15,.28,.26,.24,0,.44,.07
DATA .85,.04,-.04,.85,0,1.6,.85

'...Tree #1...

DATA 0,0,0,.5,0,0,.05
DATA .1,0,0,.1,0,.2,.15
DATA .42,-.42,.42,.42,0,.2,.4
DATA .42,.42,-.42,.42,0,.2,.4

'...Tree #2...

DATA 0.195,-0.488,0.344,0.443,0.722,0.536,0.25
DATA 0.462,0.414,-0.252,0.361,0.538,1.167,0.25
DATA -0.058,-0.070,0.453,-0.111,1.125,0.185,0.25
DATA -0.045,0.091,-0.469,-0.022,0.863,0.871,0.25

'...Sunflower...

DATA -.3,-.6,1.1,.11,4,0,.02
DATA -.3,-1,1,.01,4,0,.95
DATA .02,.01,0,-.2,0,0,.01
DATA 0,.02,0,0,.01,.02,.02

screen 1,640,225,3,2
window 1,"IFS",(0,0)-(640,225),0,1

const black=0,white=1,green=2,red=3,blue=4,yellow=5

palette black,0,0,0
palette white,1,1,1 
palette green,0,1,0 
palette red,1,0,0   
palette blue,.25,.25,1
palette yellow,1,1,.13

menu 1,0,1,"Project"
menu 1,1,1,"Sierpinski Triangle"
menu 1,2,1,"Square"
menu 1,3,1,"Fern"
menu 1,4,1,"Tree #1"
menu 1,5,1,"Tree #2"
menu 1,6,1,"Sunflower"
menu 1,7,0,"-------------------"
menu 1,8,1,"Help...","H"
menu 1,9,1,"About...","A"

menu 2,0,1,"Colour"
menu 2,1,1,"White"
menu 2,2,1,"Green"
menu 2,3,1,"Red"
menu 2,4,1,"Blue"
menu 2,5,1,"Yellow"

menu 3,0,1,"Special"
menu 3,1,0,"Clear Window","C"
menu 3,2,0,"Stop","S"
menu 3,3,1,"Quit","Q"

const havingfun=-1

while havingfun

 op%=0
 fgnd%=0

 repeat
   menu wait
   mnum = menu(0)
   item = menu(1)
   if mnum=1 then
	'..project
	if item=8 or item=9 then 
	  case
	    item=8 : help
	    item=9 : about
	  end case
	else
	  op% = item
	end if
   else
	if mnum=2 then
	  '..colour
	  fgnd% = item
	else
	  '..special
	  if item=1 then cls
	  if item=3 then quit
	end if
   end if
 until op% >= 1 and op% <= pats and fgnd% > 0
 
 '..disable menus 1 and 2
 menu 1,0,0
 menu 2,0,0

 '..enable special menu's CLS and STOP items
 menu 3,1,1
 menu 3,2,1
 
 ON MENU gosub handle_menu
 MENU ON

 '..initial x,y
 x=0
 y=0

 '...Do iterations
 color black,black
 CLS
 color fgnd%,black

 i&=1
 finished=0
 repeat
  R=RND
  IF R <= p(op%,1) THEN 
     k%=1
  ELSE
     IF R <= p(op%,2) THEN 
        k%=2
     ELSE
        IF R <= p(op%,3) THEN k%=3 ELSE k%=n%(op%)
     end if
  END IF 
  newx = a(op%,k%) * x + b(op%,k%) * y + e(op%,k%)
  newy = c(op%,k%) * x + d(op%,k%) * y + f(op%,k%) 
  x=newx
  y=newy
  outX% = x * xscale%(op%) + xoffset%(op%)
  outY% = 200 - (y * yscale%(op%) + yoffset%(op%)) 
  PSET (outX%,outY%)
  i&=i&+1
 until i& > 25000& or finished
 enable_menus
wend

handle_menu:
  mnum = menu(0)
  item = menu(1)
  if mnum=3 then
    if item=1 then cls
    if item=2 then finished = -1
    if item=3 then quit
  end if
RETURN

quit:
  menu clear
  window close 1
  screen close 1
END
