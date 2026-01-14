#include <SUBmods/complex.h>

DECLARE STRUCT Complex a,b,c,t,*d

window 1,,(0,0)-(400,400),16

on break goto quit

right  =   .75
left   = -2.25
top    =  1.5
bottom = -1.5

depth = 50

dx = (right-left)/400
dy = (bottom-top)/400

break on

for y = 1 to 400
  b->imag = top + y*dy
  for x = 1 to 400
    b->real = left + x*dx

    a->real = 0 : a->imag = 0
    r! = 0 : ctr = 0

    while r! < 100 and ctr < depth
      MulComp(a,a,c)
      AddComp(c,b,a)
      r! = (a->real * a->real) + (a->imag * a->imag)
      ++ctr
    wend

    color 1
    if ctr < depth then color 2
    if ctr< depth and abs(a->real) > 5 and abs(a->imag) > 5 then color 3
    pset (x,y)
  next
next

locate 0,0
input a$

quit:
  window close 1
  end
