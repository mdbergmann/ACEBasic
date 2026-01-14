#include "complex.h"

DECLARE STRUCT Complex a,b,c,t,e,*d

t->real = 1.0 : t->imag = 0.0

const win = 400

window 1,,(0,0)-(win,win),16

on break goto quit

right  =  4.0
left   = -2.0
top    =  2.0
bottom = -4.0

depth = 50

dx = (right-left)/win
dy = (bottom-top)/win

break on

for y = 1 to win
  b->imag = top + y*dy
  for x = 1 to win
    b->real = left + x*dx

    a->real = 0 : a->imag = 0
    r! = 0 : ctr = 0

    while r! < 100 and ctr < depth
      MulComp(a,a,c)
      DivComp(t,b,e)
      AddComp(c,e,a)
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
