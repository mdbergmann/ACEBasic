{ Easter Day Calculator.

  from "Astronomical Formulae for Calculators", Jean Meeus, 4th ed
        Willmann-Bell.    chapter 4

        Valid for all years in the Gregorian Calendar (1583 on)

        DIVIDE                   by     Quotient      Remainder
        the year X               19        -             A
        the year X              100        B             C
        B                         4        D             E
        B+8                      25        F             -
        B-F+1                     3        G             -
        19*A+B-D-G+15            30        -             H
        C                         4        I             K
        32+2*E+2*I-H-K            7        -             L
        A+11*H+22*L             451        M             -
        H+L-7*M+114              31        N             P

        then N is the number of the Month (3=March, 4=April)
        (P+1)  is the day of the month upon which Easter Sunday falls.

        The extreme dates of Easter are  March 22 (as in 1818, 2285)
				    and  April 25 (as in 1886, 1943, 2038)

  Information supplied by Arlin B Collins     bcollins@utdallas.edu 
}

defint a-z

shortint mn,dy

'..read month names 
'..(only March and April will be used here!)
dim month$(12)

for i=1 to 12
  read month$(i)
next

data January,February,March,April,May,June
data July,August,September,October,November,December


sub usage
 print "usage:	easter yyyy"
 print "	where yyyy is year >= 1583"
 stop
end sub

sub calculate.easter(yr)
shared mn,dy
  a = yr mod 19
  b = yr\100
  c = yr mod 100
  d = b\4
  e = b mod 4 
  f = (b+8)\25
  g = (b-f+1)\3 
  h = (19*A+B-D-G+15) mod 30
  i = c\4
  k = c mod 4
  l = (32+2*E+2*I-H-K) mod 7
  m = (A+11*H+22*L)\451
  mn = (H+L-7*M+114)\31
  dy = ((H+L-7*M+114) mod 31) + 1
end sub

sub future(yr,mn,dy)
  today$=date$
  c.yr = val(mid$(today$,7))
  c.mn = val(mid$(today$,1,2))
  c.dy = val(mid$(today$,4,5))
  future=yr>c.yr or (yr=c.yr and mn>c.mn) or (yr=c.yr and mn=c.mn and dy>c.dy) 
end sub

sub show.date(yr,mn,dy)
shared month$
  print "In";str$(yr);", ";
  print "Easter Sunday ";
  if future(yr,mn,dy) then 
    print "falls on ";   
  else
    print "fell on ";
  end if
  print month$(mn);str$(dy);"."
end sub


'..main
if argcount<>1 then
  usage
else
  yr = val(arg$(1))
  if yr < 1583 then
    usage
  else
    calculate.easter(yr)
    show.date(yr,mn,dy)
  end if
end if
