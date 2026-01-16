{*
** A test of external function use.
** sub2.s (assembled to produce sub2.o) 
** is used in conjunction with this:
**
** bas -O func2 sub2.o
*}
  
defint x,y

declare function subtract%(x%,y%) external

input "enter x: ",x
input "enter y: ",y

print x;"-";y;"=";subtract(x,y)
