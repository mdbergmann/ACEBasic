'..a test of PATTERN, AREA, AREAFILL

dim pat%(7)

for i=0 to 7
 read pat%(i)
next

data 0,&Hffff,&Hf00f,&Hf00f,&Hf00f,&Hf00f,&Hffff,0

screen 1,640,200,2,2
window 1,,(0,0)-(640,200),32,1

palette 0,0,0,0
palette 1,1,1,1
palette 2,0,1,0
palette 3,1,0,0

pattern &Hcccc,pat%

area (320,0)
area step (-200,100)
area step (400,0)

color 1
areafill

line (100,125)-(200,125),3
line (100,150)-(200,200),2,bf

circle (100,100),20,2
paint (100,100),2

pattern restore

line (300,125)-(400,125),2
line (300,150)-(400,199),3,bf

while inkey$="":sleep:wend

window close 1
screen close 1
