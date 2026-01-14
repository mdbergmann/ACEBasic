'...Calling a machine code subroutine from ACE with ALLOC.

'...Thanks goes to Juergen Weinelt for the fade algorithm.

declare function Delay library dos
 
const bytes=50&
const ANY=6

power& = ALLOC(bytes,ANY)

'...store machine code
for i&=0 to 39
 read a%
 poke power&+i&,a% 
next

data &H2f,0,&H20,&H2f,0,8,&Hb0,&H3c,0,1,&H67,0,0,&He,0,&H39,0,2,0,&Hbf
data &He0,1,&H60,0,0,&Ha,2,&H39,0,&Hfd,0,&Hbf,&He0,1,&H20,&H1f,&H4e,&H75,0,0

'..cause the power LED to fade out and back in
'..until the left mouse button is pressed.
repeat
  '..fade out.
  counter%=0
  repeat
    call power&(0&)
    for a%=0 to 255
      if a%=counter% then call power&(1&)
    next
    ++counter%
    finished&=mouse(0)
  until counter%=256 or finished&

  '..fade in.
  counter%=255
  repeat
    call power&(0&)
    for a%=0 to 255
      if a%=counter% then call power&(1&)
    next
    --counter%
    finished&=mouse(0)
  until counter%=-1 or finished&
until finished&

'..make sure LED is left ON.
call power&(1&)
