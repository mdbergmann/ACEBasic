'...Sierpinski Triangle

screen 1,320,200,1,1

palette 0,0,0,0
palette 1,1,1,1

color 1,0
cls

randomize timer

'...Triangle corners...

dim xx%(4),yy%(4)

for i=1 to 3
  read xx%(i),yy%(i)
next

data 70,20,250,20,160,190

'..initial x,y
X%=160
Y%=20

while not mouse(0)
  posn%=INT(RND*3.0) + 1
  '..arithmetic right shift is 
  '..faster than integer division
  X% = shr((X% + xx%(posn%)),1&)
  Y% = shr((Y% + yy%(posn%)),1&)
  PSET (X%,Y%)
wend

screen close 1

end
