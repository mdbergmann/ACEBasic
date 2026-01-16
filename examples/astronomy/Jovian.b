{ Displays the positions of the Galilean
  satellites relative to Jupiter for a 
  given date and period of time.

  The view is as it would appear through
  an inverting telescope in the Southern
  Hemisphere.

  All dates and times must be entered in 
  Universal (Greenwich Mean) Time.

  Method taken from Jean Meeus' 
  "Astronomical Algorithms", ch 43.

  Author: David J Benn
    Date: 11th,12th,13th,17th,26th July 1993,
	  18th December 1993,
	  7th March 1994,
	  14th August 1994 }

CONST radconv=57.295779
CONST xorigin=320!, yorigin=116!
CONST radius=5
CONST true=-1&, false=0&
CONST JovianColor=2
CONST black=0
CONST xscale=10, yscale=7.5

SINGLE   JDE
SINGLE   d,V,M,N,J,A,B,K,R,rr,delta,psi,DE
SINGLE   first_u1,first_u2,first_u3,first_u4
SINGLE   u1,u2,u3,u4
SINGLE   G,H
SINGLE   r1,r2,r3,r4
LONGINT  first
SHORTINT moon

DIM x(4),y(4),lastx(4)

SUB SINGLE decimal_hours(hrs,mins,secs)
'..return decimal hours

  decimal_hours = hrs + mins/60 + secs/3600
END SUB

SUB SINGLE JulianDay(dy,mn,yr) 
SINGLE m1,y1,a,b,c,d,dj
'..This routine calculates the number of days elapsed 
'..since the epoch 1900 January 0.5 (ie: 1200 GMT, 31st Dec 1899). 
 
 if yr = 0 then 
   dj=-1  '..error 
 else 
   m1=mn : y1=yr : b=0 

  if y1 < 1 then ++y1 
  if mn < 3 then m1=mn+12 : --y1 
 
  if y1 > 1582 or mn > 10 or dy >= 15 then  
    a=int(y1/100) : b=2-a+int(a/4) 
    c=int(365.25*y1)-694025 
    if y1 < 0 then c=fix((365.25*y1)-0.75)-694025 
    d=int(30.6001*(m1+1))
    dj=b+c+d+dy-0.5 
  else 
    if (y1<1582 or (y1=1582 and mn<10) or (y1=1582 and mn=10 and dy<5)) then
      c=int(365.25*y1)-694025 
      if y1 < 0 then c=fix((365.25*y1)-0.75)-694025 
      d=int(30.6001*(m1+1)); dj=b+c+d+dy-0.5 
    else 
      dj=-1  '..error
    end if
  end if 
 end if
 
 JulianDay = dj  '..Return Julian Date (error = -1)
END SUB

SUB STRING time_from_day_fraction(SINGLE fd)
'..return time string from day fraction.
SINGLE hrs,mins
  
  hrs = 24*fd
  mins = 60*(hrs-fix(hrs))
  hr$ = str$(fix(hrs))
  min$ = str$(fix(mins))
  hr$ = right$(hr$,len(hr$)-1)
  min$ = right$(min$,len(min$)-1)
  if len(hr$)=1 then hr$="0"+hr$
  if len(min$)=1 then min$="0"+min$

  time_from_day_fraction = hr$+":"+min$
END SUB

SUB STRING date_and_time(dj!)
'..This routine converts the number of (Julian) days since 
'..1900 January 0.5 into the calendar date and time.
SINGLE a,b,c,d,g,i,fd

 d=dj!+0.5 : i=int(d) : fd=d-i 
 
 if fd = 1 then fd=0 : ++i 
 
 if i > -115860 then 
   a=int((i/36524.25)+9.9835726e-1)+14 
   i=i+1+a-int(a/4) 
 end if 
 
 b=int((i/365.25)+8.02601e-1) 
 c=i-int((365.25*b)+7.50001e-1)+416 
 g=int(c/30.6001) : mn=g-1 
 dy=c-int(30.6001*g)+fd : yr=b+1899 
 if g > 13.5 then mn=g-13 
 if mn < 2.5 then yr=b+1900 
 if yr < 1 then --yr 

 '..return a date string (whole days only) 
 dy$=str$(int(dy)) : if dy < 10 then dy$="0"+right$(dy$,1)
 dy$=right$(dy$,2)
 mn$=str$(int(mn)) : if mn < 10 then mn$="0"+right$(mn$,1)
 mn$=right$(mn$,2)
 yr$=str$(int(yr))
 yr$=right$(yr$,4)

 date_and_time = dy$+"-"+mn$+"-"+yr$+"   "+time_from_day_fraction(fd)
END SUB 

SUB SINGLE in_range(n)
'..ensure n is in the range 0..360 degrees
  if n<0! then 
    in_range = 360! + (n mod 360!)
  else
    if n>360! then in_range = n mod 360!
  end if
END SUB

SUB SINGLE sinh(x)
'..return hyperbolic sine of x
  sinh = (exp(x)-exp(-x))/2!
END SUB

SUB JovianEphemeris(SINGLE JDE)
SHARED d,V,M,N,J,A,B,K,R,rr,delta,psi,DE
'..calculate circumstances of Jupiter at JDE

  '..days since 2000 January 1, 12h
  d = JDE - 36525.0

  '..argument for long-period term in motion of Jupiter	
  V = in_range(172.74 + 0.00111588*d)	

  '..mean anomalies of Earth and Jupiter
  M = in_range(357.529 + 0.9856003*d)
  N = 20.02 + 0.0830853*d + 0.329*sin(V/radconv)

  '..difference between mean heliocentric 
  '..longitudes of Earth and Jupiter
  J = in_range(66.115 + 0.9025179*d - 0.329*sin(V/radconv))

  '..equations of the center of Earth and Jupiter
  A = 1.915*sin(M/radconv) + 0.02*sin((2*M)/radconv)
  B = 5.555*sin(N/radconv) + 0.168*sin((2*N)/radconv)
  K=J+A-B

  '..radius vector of Earth
  R = 1.00014 - 0.01671*cos(M/radconv) - 0.00014*cos((2*M)/radconv)

  '..radius vector of Jupiter
  rr = 5.20872 - 0.25208*cos(N/radconv) - 0.00611*cos((2*N)/radconv)  

  '..Earth-Jupiter distance
  delta = ABS(SQR(rr*rr + R*R - 2*rr*R*cos(K/radconv)))

  '..phase angle (Earth-Jupiter-Sun)
  sin_of_psi = (R/delta)*sin(K/radconv)
  psi = sinh(sin_of_psi)*radconv

  '..longitudes of central meridian in systems I and II
  w1 = in_range(210.98 + 877.8169088*(d-(delta/173!)) + psi - B)
  w2 = in_range(187.23 + 870.1869088*(d-(delta/173!)) + psi - B)

  '..heliocentric longitude
  lambda = 34.35 + 0.083091*d + 0.329*sin((V+B)/radconv)

  '..planetocentric declination
  DS = 3.12*sin((lambda+42.8)/radconv)
  DE = DS - 2.22*sin(psi/radconv)*cos((lambda+22!)/radconv)
  DE = DE - 1.3*((rr-delta)/delta)*sin((lambda-100.5)/radconv)  
END SUB

SUB AngleFromInfConj
'..calculate angle from inferior conjunction
SHARED d,delta,psi,B
SHARED first_u1,first_u2,first_u3,first_u4
SHARED u1,u2,u3,u4
SHARED G,H

  deltaterm = d - (delta/173)

  first_u1 = in_range(163.8067 + 203.4058643*deltaterm + psi - B)
  first_u2 = in_range(358.4108 + 101.2916334*deltaterm + psi - B)
  first_u3 = in_range(5.7129 + 50.2345179*deltaterm + psi - B)
  first_u4 = in_range(224.8151 + 21.4879801*deltaterm + psi - B)

  '..correct for mutual perturbations
  G = 331.18 + 50.310482*deltaterm
  H = 87.4 + 21.569231*deltaterm

  u1 = first_u1 + 0.473*sin((2*(first_u1-first_u2))/radconv)
  u2 = first_u2 + 1.065*sin((2*(first_u2-first_u3))/radconv)
  u3 = first_u3 + 0.165*sin(G/radconv)
  u4 = first_u4 + 0.841*sin(H/radconv)
END SUB

SUB DistFromCenter
'..calculate distance of each satellite from
'..center of Jupiter
SHARED first_u1,first_u2,first_u3,first_u4
SHARED r1,r2,r3,r4
SHARED G,H
  
  r1 = 5.9073 - 0.0244*cos((2*(first_u1-first_u2))/radconv)
  r2 = 9.3991 - 0.0882*cos((2*(first_u2-first_u3))/radconv) 
  r3 = 14.9924 - 0.0216*cos(G/radconv)
  r4 = 26.3699 - 0.1935*cos(H/radconv)
END SUB

SUB calc_x_y(SHORTINT n)
'..calculate rectangular coordinates 
'..of four satellites
SHARED x,y
SHARED r1,r2,r3,r4
SHARED u1,u2,u3,u4
SHARED DE

  case
    n=1 : r=r1:u=u1
    n=2 : r=r2:u=u2
    n=3 : r=r3:u=u3
    n=4 : r=r4:u=u4
  end case 

  x(n) = r*sin(u/radconv)
  y(n) = -r*cos(u/radconv)*sin(DE/radconv)   
END SUB

SUB LONGINT moving_east(SHORTINT moon)
'..return true if moon is moving east.
SHARED lastx,x  

  if lastx(moon) > x(moon) then 
    moving_east = true
  else
    moving_east = false
  end if
END SUB

SUB LONGINT in_disk_region(SHORTINT x,SHORTINT y)
'..return true or false according to whether
'..a satellite is in the region of the disk
'..of Jupiter.

  if point(x-1,y)=JovianColor and point(x+1,y)=JovianColor then
    in_disk_region = true
  else
    in_disk_region = false
  end if    
END SUB

SUB LONGINT behind_disk(SHORTINT xcoord,SHORTINT ycoord,SHORTINT moon)
'..return true or false according to whether
'..a satellite is behind the disk of Jupiter.
 
  if in_disk_region(xcoord,ycoord) and moving_east(moon) then
    behind_disk = true
  else
    behind_disk = false
  end if   
END SUB

SUB RemoveMoons
SHARED x,y
SHORTINT moon,xx,yy,colr

  '..clear moons
  for moon=1 to 4
    xx = xorigin+x(moon)*xscale
    yy = yorigin-y(moon)*yscale
    
    if in_disk_region(xx,yy) then
      '..in transit across disk or behind it
      colr = JovianColor
    else
      colr = black
    end if
    pset (xx,yy),colr
  next
END SUB

SUB ShowJovianSpace
'..display Jupiter and the Galilean satellites
SHARED x,y
SHORTINT xx,yy,moon

  '..plot moons
  for moon=1 to 4
    xx = xorigin+x(moon)*xscale
    yy = yorigin-y(moon)*yscale
    if not behind_disk(xx,yy,moon) then pset (xx,yy),moon
  next

  '..draw Jupiter
  circle (xorigin,yorigin),radius,JovianColor
  paint (xorigin,yorigin),JovianColor
END SUB

SUB DisplayData
'..display Jupiter/satellite data 
CONST startcol=15
SHARED JDE,x,y,rr,delta
SHORTINT moon  

  '..Date & Time
  locate 3,10
  color 1,0
  print date_and_time(JDE);" UT"
  
  '..Earth-Jupiter distance  
  locate 4,10
  color 4,0
  print "Earth-Jupiter Distance (AU): ";
  color 5,0
  print delta;"    " 

  '..Jupiter's Radius Vector
  locate 5,10
  color 6,0
  print "  Sun-Jupiter Distance (AU): ";
  color 5,0
  print rr;"    "

  '..headings
  locate 7,startcol
  color 7,0
  print " Io"
  locate 7,startcol+15
  color 6,0
  print " Europa"
  locate 7,startcol+30
  color 7,0
  print " Ganymede"
  locate 7,startcol+45
  color 6,0
  print " Callisto"
  print

  '..satellite's X coordinate
  locate csrlin,10:print "X: ";
  col=startcol
  for moon=1 to 4
    locate csrlin,col
    color moon
    print x(moon);"    ";
    col=col+15 
  next

  '..satellite's Y coordinate
  print
  locate csrlin,10:print "Y: ";
  col=startcol
  for moon=1 to 4
    locate csrlin,col
    color moon
    print y(moon);"    ";
    col=col+15  
  next
END SUB

'..main
if arg$(1)="?" then 
  print
  print "usage: Jovian date start duration interval"
  print
  print "       where: date is of the form dd mm yyyy"
  print
  print "              start, duration and interval"
  print "              consist of hh mm ss "
  print
  print "              Date and Time are taken to be UT.
  print        
  stop
end if

if argcount=12 then  
  dd = val(arg$(1))
  mm = val(arg$(2))
  yy = val(arg$(3))

  hrs = val(arg$(4))
  mins = val(arg$(5))
  secs = val(arg$(6))

  hr_dur = val(arg$(7))
  min_dur = val(arg$(8))
  sec_dur = val(arg$(9))

  hr_int = val(arg$(10))
  min_int = val(arg$(11))
  sec_int = val(arg$(12))
else
  window 1,"Jovian Satellite Simulation",(0,0)-(640,70),0
  font "topaz",8
  print
  print "Start Date (UT):"
  print
  input "Enter day   ",dd
  input "Enter month ",mm
  input "Enter year  ",yy

  cls
  print
  print "Start Time (UT):"
  print
  input "Enter hours   ",hrs
  input "Enter minutes ",mins
  input "Enter seconds ",secs

  cls
  print
  print "Duration:"
  print
  input "Enter hours   ",hr_dur
  input "Enter minutes ",min_dur
  input "Enter seconds ",sec_dur

  cls
  print
  print "Interval:"
  print
  input "Enter hours   ",hr_int
  input "Enter minutes ",min_int
  input "Enter seconds ",sec_int
  window close 1

  '..An interval of 6 minutes is the finest resolution 
  '..possible with single-precision floating-point math!
  if hr_int=0 and min_int<6 then min_int=6
end if

day_fraction = decimal_hours(hrs,mins,secs) / 24!
JDE = JulianDay(dd,mm,yy) + day_fraction

duration = decimal_hours(hr_dur,min_dur,sec_dur) / 24!
end_point = JDE+duration

interval = decimal_hours(hr_int,min_int,sec_int) / 24!

screen 1,640,200,4,2
window 1,"Jovian Satellite Simulation",(0,0)-(640,200),0,1

font "topaz",8

palette 0,0,0,0		'..black
palette 1,1,.73,0	'..orange (Io)
palette 2,1,.87,.73	'..tan (Europa, Jupiter)
palette 3,.93,.2,0	'..fire engine red (Ganymede) 
palette 4,.8,.6,.53	'..brown (Callisto) 
palette 5,1,1,1		'..white
palette 6,0,.93,.87	'..aqua
palette 7,.33,.87,0	'..green
palette 8,0,0,1		'..blue
palette 9,1,1,.13	'..yellow

MENU 1,0,1,"Project"
MENU 1,1,1,"About..."
MENU 1,2,1,"Quit","Q"

ON MENU GOSUB handle_menu
MENU ON

'..N,S,E,W markers
color 9,0
locate 15,5
print "E"
locate 15,76
print "W"
locate 12,41
print "N"
locate 18,41
print "S"

'..initialise lastX array
for moon=1 to 4
  lastx(moon) = -99
next

first=true

repeat
  JovianEphemeris(JDE)
  AngleFromInfConj
  DistFromCenter

  if not first then 
    RemoveMoons
  else 
    first=false
  end if

  for moon=1 to 4
    if not first then lastx(moon) = x(moon)
    calc_x_y(moon)
  next

  ShowJovianSpace

  DisplayData

  JDE = JDE + interval
until JDE > end_point

'..await menu selection
while -1:sleep:wend

'..trap handlers
handle_menu:
  the_menu = MENU(0)
  the_item = MENU(1)

  if the_menu = 1 and the_item = 1 then
    result = MsgBox("Written in ACE by David Benn","OK")
  end if

  if the_menu = 1 and the_item = 2 then quit
RETURN

quit:
  window close 1
  screen close 1
END
