
CONST x=400, y=150

deflng a-z
SINGLE t0,t1

FOR n=1 to 5

t0=timer
for i=1 to x
  for j=1 to y
  next
next
t1=timer

print "FOR:";t1-t0;"seconds."

t0=timer
i=1
while i<=x
  j=1
  while j<=y
    ++j
  wend
  ++i
wend
t1=timer

print "WHILE:"t1-t0;"seconds."

t0=timer
i=1
repeat
  j=1
  repeat 
    ++j
  until j>y
  ++i
until i>x
t1=timer

print "REPEAT:"t1-t0;"seconds."

PRINT
NEXT
