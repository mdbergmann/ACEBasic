{*
** A test of external function use.
** sub.c (compiled and assembled to produce sub.o)
** is used in conjunction with this:
**
** bas -O func sub.o
*}
  
deflng x,y,z

declare function subtract(x&,y&,z&) external

input "enter x: ",x
input "enter y: ",y
z=0

subtract(x,y,@z)
print x;"-";y;"=";z
