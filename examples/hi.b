defint a-z

screen 1,320,200,3,1

palette 0,0,0,0
palette 1,0,0,1
palette 2,0,1,0
palette 3,0,1,1
palette 4,1,0,0
palette 5,1,0,1
palette 6,1,1,0
palette 7,1,1,1

window 1,"Hello World!  <press 'q' key to quit>",(0,0)-(320,200),32,1

while inkey$<>"q"
 x=rnd*80
 y=rnd*25
 repeat 
  f=rnd*7+1
  b=rnd*8
 until f <> b
 color f,b
 locate y,x
 print "Hi There!";
wend

window close 1
screen close 1
