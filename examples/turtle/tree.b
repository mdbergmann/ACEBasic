REM #using ace:submods/turtle/turtle.o
'...Recursive binary tree using turtle graphics

#include <submods/turtle.h>

sub tree(n)
  if n<5 then exit sub
   TgTurnRight(30)
   TgForward(n)
   tree(n*.75)
   TgBack(n)
   TgTurnLeft(60)
   TgForward(n)
   tree(n*.75)
   TgBack(n)
   TgTurnRight(30)
end sub

sub usage
  print "usage: tree <depth>"
end sub

if argcount<>1 then
  ask.depth=-1
else
  ask.depth=0
  x$=arg$(1)
  if x$="?" then
    usage
    input "enter depth: ",depth
  else
    depth=val(x$)	'..get depth
  end if
end if

screen 1,640,200,2,2
window 1,,(0,10)-(640,200),32,1
font "topaz",8
color 1,0

 cls
 locate 3,1
 if ask.depth then
    input "enter depth: ",depth
    cls
    locate 3,1
 end if
 print "depth of tree is"
 print depth

 TgInit(320, 150)

 tree(depth)

 locate 23,1
 print "press 'q' to quit...";
 while ucase$(inkey$)<>"Q":wend

window close 1
screen close 1
