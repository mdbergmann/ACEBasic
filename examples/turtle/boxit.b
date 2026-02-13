REM #using ace:submods/turtle/turtle.o
'...recursive triangle consisting of boxed edges.

#include <submods/turtle.h>

sub boxit(n)
  if n=0 then
    TgForward(3)
  else
    boxit(n-1)
    TgTurnLeft(90)
    boxit(n-1)
    TgTurnRight(90)
    boxit(n-1)
    TgTurnRight(90)
    boxit(n-1)
    TgTurnLeft(90)
    boxit(n-1)
  end if
end sub

window 1,"BoxIt",(0,0)-(640,200),6
font "topaz",8
color 2,1

 cls
 TgInit(0, 150)
 TgTurnRight(90)
 boxit(4)

 locate 22,1
 print "press 'q' to quit."
 while ucase$(inkey$)<>"Q":wend

window close 1
