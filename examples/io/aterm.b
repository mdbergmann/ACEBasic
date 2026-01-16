'..Test of serial port functions in ACE via a simple terminal program.
'..Run this program from a shell/CLI. There is NO translation of
'..incoming escape sequences.

DEFLNG   a-z

LIBRARY "graphics.library"
DECLARE FUNCTION SetDrMd(Rp&,MODE) LIBRARY

CONST    true=-1&, false=0&
CONST	 buffer_size=1024&
CONST	 unit=0&
CONST	 COMPLEMENT=2&,JAM2=1&

STRING   buffer, parity, data_bits, stop_bits, wires, Xon, share, fast
LONGINT  baud, chars, maxcolor, rp

SUB cursoron
shared maxcolor,rp
  SetDrMd(rp,COMPLEMENT)
  color maxcolor 
  print "|";
  color 1
  SetDrMd(rp,JAM2)
END SUB

SUB cursoroff
shared maxcolor,rp
  SetDrMd(rp,COMPLEMENT)
  locate csrlin,pos-1
  color maxcolor
  print "|"+chr$(8);
  color 1
  SetDrMd(rp,JAM2)
END SUB

'..main
if argcount<>4 then 
  print "usage: ";arg$(0);" baud parity data stop"
  STOP
else
  '..get serial parameters
  baud=val(arg$(1))
  parity=arg$(2)
  data_bits=arg$(3)
  stop_bits=arg$(4)
  wires="7"
  Xon="X"
  share="?"
  fast="?"
  param$ = parity+data_bits+stop_bits+wires+Xon+share+fast
end if

window 1,"ACE Terminal (hit ESC to quit)",(0,0)-(640,200)

maxcolor = window(6)
rp = window(8)

on error goto quit
error on

serial open 1,unit,baud,param$,1024

cursoron

finished=false

repeat
  '..incoming?
  chars = serial(1,0)
  if chars<>0 then 
    serial read 1,buffer,chars
    cursoroff
    print buffer;
    cursoron
  end if  
  '..outgoing?
  k$=inkey$
  if k$=chr$(27) then 
    finished=true
  else
    if k$<>"" then serial write 1,k$,1
  end if
until finished

quit:
  window close 1
  serial close 1
