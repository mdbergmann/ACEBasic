'...recursive triangle consisting of boxed edges.

sub boxit(n)
  if n=0 then 
    forward 3
  else
    boxit(n-1)
    turnleft 90
    boxit(n-1)
    turnright 90
    boxit(n-1)
    turnright 90
    boxit(n-1)
    turnleft 90
    boxit(n-1)
  end if 
end sub

window 1,"BoxIt",(0,0)-(640,200),6
font "topaz",8
color 2,1

 cls
 penup
 setxy 0,150
 pendown
 turnright 90
 boxit(4)

 locate 22,1
 print "press 'q' to quit."
 while ucase$(inkey$)<>"Q":wend

window close 1
