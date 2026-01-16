'...Chaos from a simple equation...

window 1,"chaos from kx^2-1",(0,0)-(640,200),6

color 2,1
penup

repeat
 CLS

 locate 2,1
 input "Value of k (0..2, 'q' to quit)";k$
 k$=ucase$(k$)

 if ucase$(k$)<>"Q" then
  k=val(k$)
  x=.1
  wf=3

  setxy 10,100

  FOR I%=10 TO 620 STEP WF
    x = k*x^2.0 - 1.0
    Ampl%=(x*25.0)+100
    line step (i%,ampl%) 
  NEXT

  locate 4,1
  print "press 'c' to continue..."

  while ucase$(inkey$)<>"C"
  wend

 end if
until k$="Q"

window close 1
