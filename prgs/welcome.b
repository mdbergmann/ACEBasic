dim voice%(8)

for i=0 to 8
  read voice%(i)
next

data 80,0,160,0,22900,64,10,0,0

x$="Welcome to ACE! The best PD Amiga BASIC compiler."

say translate$(x$),voice%
