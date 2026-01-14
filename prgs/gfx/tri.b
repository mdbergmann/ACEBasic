' HiSoft BASIC demo based on Dreier on the German Extras disk
' used with permission

' you can load this into AmigaBASIC to see the difference
' (assumes 80-column text mode)

'" dreierneu
'" Demo schnelles Flächenfüllen
'" P. Kittel, CBM Ffm, 4.4.87, 18.6.88

'..modified for ACE v1.02 by David J Benn, 13.3.1993
'..modified for ACE v2.03 by David J Benn, 10.3.1994

'CLEAR,4000
'CLEAR,7500

sc&=PEEKL(WINDOW(7) + 46) '" Screen-Struktur
Hoehe=PEEKW(sc&+14)       '" Screen-Höhe
IF Hoehe=256 THEN
  ym=250:y1=140:y0=58:ye=119:zl=29 ':PRINT "PAL-Screen"
          ELSE
  ym=200:y1=105:y0=45:ye= 93:zl=20 ':PRINT "NTSC-Screen"
END IF

window 1,"ACE BASIC Demo",(0,0)-(640,200)
PRINT
PRINT "This program illustrates several things:":?
PRINT "1. How fast the Amiga is at colour graphics"
PRINT "2. How fast ACE BASIC for the Amiga is"
PRINT "3. How compatible ACE BASIC is with AmigaBASIC,"
PRINT "   the language supplied with every Amiga."
PRINT
PRINT "If you load the file HBDemo.bas into AmigaBASIC you"
PRINT "will be able to see the difference yourself."
PRINT
'PRINT "HiSoft BASIC for the Amiga is available from your dealer"
'PRINT "or, in case of difficulty, from:"
'PRINT "HiSoft, The Old School, Greenfield, Bedford, MK45 5DE, UK"
'PRINT "                                      Phone (0525) 718181"
PRINT:PRINT
PRINT "Press any key to begin...";

t=TIMER+20
WHILE (INKEY$="") AND (TIMER<t)
WEND

window close 1

'fz=0		'1 is prettier but too slow under AmigaBASIC
fz=1

SCREEN 1,570,ym,4,2
{IF SYSTAB THEN
	t$=" Compiled with HiSoft BASIC"
	REM $event off
	REM $option a-,e-,x-,b-,o-,n-
ELSE
	t$=" Running under AmigaBASIC"
END IF}

t$="Compiled with ACE BASIC"

WINDOW 2,t$+" (ESC to exit)",(0,0)-(510,ym),0,1
x1=250
x2=290:y2=y1
z1=0  :z2=0
co=2

const nn=15
const nn1=16

DIM pr(nn),pg(nn),pb(nn),pra(nn1),pga(nn1),pba(nn1)
FOR i=2 TO nn:PALETTE i,0,0,0:NEXT
fr=0:fg=0:fb=0:pf=0:ff=4000:fs=0:c7=7/15:c6=15*16:c2=15*256
cc=0:cf=1:co2=0
PALETTE 0,.5,.5,.5
COLOR 1
LOCATE 1,2:PRINT "Fast";:     LOCATE 1,50:PRINT "Solid fills";
LOCATE 2,2:PRINT "Graphics" ;:LOCATE 2,50:PRINT "using blitter";
{IF SYSTAB THEN
	LOCATE zl-1,50:PRINT "All with";
        LOCATE zl  ,50:PRINT "HiSoft BASIC!";
END IF}

LOCATE zl-1,50:PRINT "All with";
LOCATE zl  ,50:PRINT "ACE BASIC!";

IF fz THEN
  LOCATE zl/2-1,25:PRINT "Bitte etwas Geduld...";
  END IF
COLOR 2
LOCATE zl-1,2:PRINT "4096";
LOCATE zl  ,2:PRINT "Colours";

'" Die Art der Farbweiterschaltung wird
'" durch die Variablen fs und ff in
'" späteren Zeilen bestimmt.
'" Hier ist viel Raum für eigene
'" Experimente.

ex$=CHR$(27)

WHILE INKEY$<>ex$

  x3=x2 :y3=y2
  z1=z1+.01         :IF z1>6.28 THEN z1=0
  z2=z2+.03*SIN(z1) :IF z2>6.28 THEN z2=0
  z3=z3+z1*SIN(z2)/4:IF z3>6.28 THEN z3=0

  x2=INT(120*(1+SIN(z2))*COS(z3)+x1)
  y2=INT( y0*(1+SIN(z2))*SIN(z3)+ye)
  AREA (x1,y1):AREA (x2,y2):AREA (x3,y3)

  IF fz=0 THEN
    pra(co)=pr(co):pga(co)=pg(co):pba(co)=pb(co)
    PALETTE co,pr(co),pg(co),pb(co)
    END IF

  '" Farbweiterschaltung
  co=co+1:IF co>nn THEN
    co=2
    co2=co2+1
    IF co2>1 OR fz=0 THEN
      co2=0
      fs=fs+.1:IF fs>7 THEN fs=fs-7
      ff=ff+273.16*(1+COS(fs)*1.02):IF ff>4095 THEN ff=ff-4095
      fi=INT(ff)
      ar=fr:ag=fg:ab=fb
      fr=(fi AND 15)/15
      fg=(fi AND 15*16 )/c6
      fb=(fi AND 15*256)/c2  
      pr(15)=fr:pg(15)=fg:pb(15)=fb ' neue Farbe
      cc=cc+1:IF cc>20 THEN cc=0:cf=-cf
      IF cf*(fr+ar)>cf THEN
        fr2=2-fr:m=(fr2-ar)/14:a=ar-m
        FOR i=2 TO 14:pr(i)=a+i*m:IF pr(i)>1 THEN pr(i)=2-pr(i)
          NEXT
              ELSE
        fr2=-fr:m=(fr2-ar)/14:a=ar-m
        FOR i=2 TO 14:pr(i)=a+i*m:IF pr(i)<0 THEN pr(i)=-pr(i)
          NEXT
        END IF
      IF cf*(fg+ag)>cf THEN
        fg2=2-fg:m=(fg2-ag)/14:a=ag-m
        FOR i=2 TO 14:pg(i)=a+i*m:IF pg(i)>1 THEN pg(i)=2-pg(i)
          NEXT
              ELSE
        fg2=-fg:m=(fg2-ag)/14:a=ag-m
        FOR i=2 TO 14:pg(i)=a+i*m:IF pg(i)<0 THEN pg(i)=-pg(i)
          NEXT
        END IF
      IF cf*(fb+ab)>cf THEN
        fb2=2-fb:m=(fb2-ab)/14:a=ab-m
        FOR i=2 TO 14:pb(i)=a+i*m:IF pb(i)>1 THEN pb(i)=2-pb(i)
          NEXT
              ELSE
        fb2=-fb:m=(fb2-ab)/14:a=ab-m
        FOR i=2 TO 14:pb(i)=a+i*m:IF pb(i)<0 THEN pb(i)=-pb(i)
          NEXT
        END IF
      END IF
    END IF

  IF fz THEN
    '" Palette zyklisch umbelegen  
     FOR i=nn+1 TO 3 STEP -1
       pra(i)=pra(i-1): pga(i)=pga(i-1): pba(i)=pba(i-1)
       NEXT
     pra(2)=pra(nn+1): pga(2)=pga(nn+1): pba(2)=pba(nn+1)
     cd=2*co-2: IF cd>nn THEN cd=cd-nn+1
     pra(cd)=pr(co):   pga(cd)=pg(co):   pba(cd)=pb(co)
     FOR i=2 TO nn:PALETTE i,pra(i),pga(i),pba(i):NEXT
     END IF

  COLOR co
  AREAFILL
  WEND

'" Am Schluß sauber aufräumen
WINDOW CLOSE 2
SCREEN CLOSE 1
'IF SYSTAB THEN SYSTEM
END
