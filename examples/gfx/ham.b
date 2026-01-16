
'..A test of HAM screen mode in ACE.
'..Based upon a C program in "Inside Amiga Graphics", p 259-262.
'..David J Benn, August 1994.

DEFLNG a-z

const modblu = 10
const modred = 20
const modgrn = 30

screen 1,320,200,6,5

palette 0,0,0,0
palette 1,0,.53,.53
palette 2,.67,0,.27
palette 3,.2,.6,0

window 1,,(0,0)-(320,200),32,1

'..demo
for c=1 to 15
  color modred+c
  line (18*c,20)-(18*c+17,40),,bf
  line (18*c,110)-(18*c+17,130),modred+c,bf

  color modgrn+c
  line (18*c,50)-(18*c+17,70),,bf
  line (18*c,140)-(18*c+17,160),modred+c,bf
  
  color modblu+c
  line (18*c,80)-(18*c+17,100),,bf
  line (18*c,170)-(18*c+17,190),modred+c,bf
next

for c=1 to 3
  color c
  line (18,30*c+80)-(18,30*c+100)
  sleep for .25
next

while inkey$="":sleep:wend

window close 1
screen close 1
