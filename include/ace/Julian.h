{ Julian Date calculations. 
 
  These routines were taken from Peter Duffett-Smith's 
  "Astronomy with your Personal Computer". 
 
  Conversion from line-numbered BASIC to C to ACE-BASIC 
  by David Benn, 2nd,8th,9th April 1993. } 
  
SUB julday(caldate$) 
 
single m1,y1,a,b,c,d,dj

{ This routine calculates the number of days elapsed 
  since the epoch 1900 January 0.5 (ie: 1200 GMT, 31st Dec 1899). } 
 
 '..convert date string (mm-dd-yyyy) into dy,mn,yr
 dy=val(mid$(caldate$,4,2))
 mn=val(mid$(caldate$,1,2))
 yr=val(right$(caldate$,4))

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
 
 julday = dj  '..Return Julian Date (error = -1)
END SUB
 
SUB calday$(dj!) 

single a,b,c,d,g,i,fd

{ This routine converts the number of (Julian) days since 
  1900 January 0.5 into the calendar date. }
 
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

 calday$ = mn$+"-"+dy$+"-"+yr$
END SUB 
