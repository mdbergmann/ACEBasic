'...calling a machine code subroutine from ACE with ALLOC.

declare function Delay(ticks&) library
 
const bytes=50&

power& = ALLOC(bytes)

'...store machine code
for i&=0 to 39
 read a%
 poke power&+i&,a% 
next

data &H2f,0,&H20,&H2f,0,8,&Hb0,&H3c,0,1,&H67,0,0,&He,0,&H39,0,2,0,&Hbf
data &He0,1,&H60,0,0,&Ha,2,&H39,0,&Hfd,0,&Hbf,&He0,1,&H20,&H1f,&H4e,&H75,0,0

'...flash power LED 5 times
for i=1 to 5
  print "off"
  mode&=0
  call power&(mode&)
  Delay(25)
  print "on"
  mode&=1
  call power&(mode&)
  Delay(25)
next  
