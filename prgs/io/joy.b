'..A test of the joystick functions
'..for gameport B. Hit any key to quit.

DEFINT a-z

window 1,"Joystick test",(0,0)-(640,200)

while inkey$=""
  fire = STRIG(3)
  x = STICK(2)  
  y = STICK(3)
  print "Fire:";fire;tab(20);"X:";x;tab(40);"Y:"y
wend

window close 1
