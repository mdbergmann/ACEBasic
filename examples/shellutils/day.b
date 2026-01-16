'..Compute the day of the week for dates after 
'..the start of the Gregorian Calendar.

shortint d,m,y
dim dy$(7)

for i=1 to 7
 read dy$(i)
next

data Sunday,Monday,Tuesday,Wednesday
data Thursday,Friday,Saturday

if argcount<>3 then
  print "usage: day dd mm yyyy"
  stop
else
  d=val(arg$(1))
  m=val(arg$(2))
  y=val(arg$(3))
end if

if d < 1 or d > 31 then
  print "The day must be from 1 to 31."
  stop
end if

if m < 1 or m > 12 then
  print "The month must be from 1 to 12."
  stop
end if

if y <= 1582 then
  print "The year must be after 1582."
  stop
end if

'..calculate day
k=int(0.6+(1/m))
l=y-k
o=m+12*k
p=l/100
z1=int(p/4)
z2=int(p)
z3=int((5*l)/4)
z4=int(13*(o+1)/5)
z=z4+z3-z2+z1+d-1
z=z-(7*int(z/7))+1
print "The day of the week is ";dy$(z);"."
