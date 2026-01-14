'..Dragon Curve 
'..(recursive).

sub dragon(depth,side)
 if depth = 0 then
   Forward(side)
 else
   if depth > 0 then
    dragon(depth-1,side)
    turnRight(90)
    dragon(-(depth-1),side)
   else
    dragon(-(depth+1),side)
    turnRight(270)
    dragon(depth+1,side)
   end if
 end if
end sub

window 1,"Dragon Curve",(0,0)-(640,250),6
font "topaz",8
color 2,1

another$="Y"
while another$="Y"
 cls
 locate 1,1
 input "Enter depth (try 10): ",depth 
 input "Enter sides (try 3):  ",sides 
 
 cls

 penup
 setxy 320,125
 pendown
 dragon(depth,sides)

 locate 26,1
 print "another (y/n)?"
 another$=""
 while another$<>"Y" and another$<>"N"
   another$=ucase$(inkey$)
 wend
wend

window close 1
