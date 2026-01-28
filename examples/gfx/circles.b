'..Filled and unfilled circles/ellipses demo

screen 1,640,256,4,2
window 1,"Circles",(0,0)-(640,256),32,1

palette 0,0,0,0
palette 1,1,1,1
palette 2,1,0,0
palette 3,0,1,0
palette 4,0,0,1
palette 5,1,1,0
palette 6,0,1,1
palette 7,1,0,1

'..unfilled circles
color 1
locate 2,4:print "Unfilled";

circle (80,60),40,1
circle (200,60),40,2
circle (320,60),30,3,,,0.7
circle (440,60),30,4,,,1.5

'..filled circles
locate 10,4:print "Filled";

circle (80,160),40,2,,,,F
circle (200,160),40,3,,,,F
circle (320,160),30,5,,,0.7,F
circle (440,160),30,6,,,1.5,F

'..mixed: filled with outline on top
locate 18,4:print "Filled + Outline";

circle (560,60),40,5,,,,F
circle (560,60),40,1

circle (560,160),30,7,,,0.7,F
circle (560,160),30,1,,,0.7

while inkey$="":sleep:wend

window close 1
screen close 1
