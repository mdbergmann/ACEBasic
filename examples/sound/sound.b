'...an example of SOUND & WAVE usage

print
print "white noise:"
print
size&=4000
addr&=ALLOC(size&,0)    '...size& bytes of CHIP RAM

print "writing random bytes..."

for i&=0 to size&-1
  r%=rnd*128
  s%=rnd*2
  if s%=1 then r%=r%*-1
  poke addr&+i&,r%
  if i& mod 1000 = 0 then print i& 
next	
print

wave 0,addr&,size&

sound 300,18
for d=1 to 2000:next d  '...pause

sound 300,18,,0
for d=1 to 2000:next d  

sound 300,18,64
for d=1 to 2000:next d  

vol=64
for i%=400 to 200 step -15
 sound i%,4.5,vol,0
 vol=vol-3
next
for i%=200 to 400 step 15
 sound i%,4.5,vol,0
 vol=vol+3
next
