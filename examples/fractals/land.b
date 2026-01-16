{ Fractal Landscapes }

const parts=34,partsplus2=36
const xscreen=640,yscreen=200
	
longint initial,picsize
single	mini,maxi,depth,lt,rt,top,bottom
dim 	value&(parts,partsplus2)

sub rndchoice&(a,b)
shared picsize,initial,mini,maxi
  zw = (a+b) / 2 + rnd mod picsize - initial
  if zw < mini then mini = zw
  if zw > maxi then maxi = zw
  rndchoice& = zw
end sub

sub full
shared initial,picsize,value&
longint xko,yko
  yko = 0
  repeat 
    xko = initial
    repeat
      value&(xko,yko)=rndchoice&(value&(xko-initial,yko),value&(xko+initial,yk0))
      value&(yko,yko)=rndchoice&(value&(yko,xko-initial),value&(yko,xko+initial))
      a = value&(xko-initial,parts-xko-yko+initial)
      b = value&(xko+initial,parts-xko-yko-initial)
      value&(xko,parts-xko-yko)=rndchoice&(a,b)
      xko = xko + picsize
    until xko > (parts - yko)
    yko = yko + picsize
  until yko >= parts 
end sub

sub fill
shared mini,maxi,value&,picsize,initial
longint i,j
  for i=0 to parts
    for j=0 to partsplus2
      value&(i,j) = 0
    next
  next

  mini=0 : maxi=0
  picsize = parts
  initial = picsize \ 2

  repeat
    full
    picsize = initial
    initial = initial \ 2
  until initial = picsize

  value&(0,parts+1) = mini
  value&(1,parts+1) = maxi
  value&(2,parts+1) = picsize
  value&(3,parts+1) = initial
end sub

sub set_universal_point(xw,yw)
shared lt,rt,top,bottom
  xs = ((xw-lt) * xscreen / (rt-lt)) 
  ys = (yw-bottom) * yscreen / (top-bottom)
  pset (xs,ys) 
end sub

sub draw_universal_line(xw,yw)
shared lt,rt,top,bottom
  xs = ((xw-lt) * xscreen / (rt-lt)) 
  ys = (yw-bottom) * yscreen / (top-bottom)
  line step (xs,ys) 
end sub

sub universal_x&(xw)
shared lt,rt
  universal_x& = ((xw-lt) * xscreen / (rt-lt)) 
end sub

sub universal_y&(yw)
shared top,bottom
  universal_y& = (yw-bottom) * yscreen / (top-bottom)
end sub

on mouse gosub finish
mouse on

sub slant(yko)
shared value&,depth
longint xko
 
  setxy universal_x&(yko),universal_y&(yko+value&(0,yko)*depth)

  for xko=0 to parts-yko
    draw_universal_line(xko+yko,yko+value&(xko,yko)*depth)
  next

 { for xko=parts-yko to parts
    draw_universal_line(xko+yko,yko+value&(parts-yko,parts-xko)*depth)
  next    }  
end sub

sub along(xko)
shared value&,depth
longint yko

  setxy universal_x&(xko),universal_y&(value&(xko,0)*depth)

  for yko = 0 to parts-xko
    draw_universal_line(xko+yko,yko+value&(xko,yko)*depth)
  next

{  for yko = parts-xko to parts
    draw_universal_line(xko+yko,xko+value&(parts-yko,parts-xko)*depth)
  next}
end sub
    
sub draw
shared depth,value&
longint xko,yko

  for yko = 0 to parts
    slant(yko)
  next

  for xko = 0 to parts
    along(xko)
  next
end sub

mouse off

sub initialise
shared lt,rt,top,bottom,depth
{ input "left   (try  0)   : ",lt
 input "right  (try 15)   : ",rt
 input "bottom (try 15)   : ",bottom
 input "top    (try  0)   : ",top
 input "depth  (try  0.05): ",depth }
 
 '..demo parameters
 lt = 0
 rt = 20
 bottom = 10
 top = 0
 depth = 0.15
end sub

sub compute_and_display
  fill
  draw
end sub
     
{ ** main ** }
initialise

screen 1,xscreen,yscreen,2,2

palette 0,0,0,0
palette 1,1,1,1

color 1

penup
randomize timer
compute_and_display

finish:
 locate 3,5
 prints "hit a key..."
 while inkey$="":Sleep:wend

 screen close 1

 STOP  
