
' AmigaBASIC needs about 13500 s. for this program, the compiled
' version about 2340 s.

' This program came with the Aminet distribution of the ShareWare BASIC
' compiler, Cursor. Converted to ACE on 5th December 1994 by David Benn.

 'OPTION NOWINDOW,SOMEPCRELATIVE

 ON WINDOW GOTO quit
 WINDOW ON

 XLPos = -2.4
 XRPos = .8
 YDPos = -1.2
 YUPos = 1.2

 MaxIter% = 32

 SCREEN 1,640,200,4,2
 WINDOW 1,"Mandelbrot",(0,0)-(640,200),8,1

 PALETTE 0,0,0,0
 PALETTE 1,1,1,1
 c1 = 0 : c2 = .5 : c3 = 1 : dc1 = 1/6.5 : dc2 = 1/6.5 : dc3 = 1/6.5
 FOR a% = 2 TO 15
   IF c1+dc1 < 0 OR c1+dc1 > 1 THEN dc1 = -dc1
   c1 = c1+dc1
   IF c2+dc2 < 0 OR c2+dc2 > 1 THEN dc2 = -dc2
   c2 = c2+dc2
   IF c3+dc3 < 0 OR c3+dc3 > 1 THEN dc3 = -dc3
   c3 = c3+dc3
   PALETTE a%,c1,c2,c3
 NEXT a%

 t& = TIMER

 XSize = XRPos-XLPos
 YSize = YUPos-YDPos

 XPixelSize = WINDOW(2)
 YPixelSize = WINDOW(3)

 mystep% = 1024
 WHILE mystep%
   FOR px% = 0 TO XPixelSize-1 STEP mystep%
     FOR py% = 0 TO YPixelSize-1 STEP mystep%
       IF (px% AND mystep%) OR (py% AND mystep%) OR (mystep% = 1024) THEN
         c.r = XLPos+px%/XPixelSize*XSize
         c.i = YDPos+(YPixelSize-1-py%)/YPixelSize*YSize
         x.r = 0
         x.i = 0
         num% = 0
         x.r.quadrat = x.r*x.r
         x.i.quadrat = x.i*x.i
         WHILE x.r.quadrat+x.i.quadrat < 1000 AND num% < MaxIter%
           x.i = (x.r+x.r)*x.i+c.i
           x.r = x.r.quadrat-x.i.quadrat+c.r
           x.r.quadrat = x.r*x.r
           x.i.quadrat = x.i*x.i
           num% = num%+1
         WEND
         IF num% = MaxIter% THEN
           mycolor% = 0
         ELSE
           mycolor% = 2+(num% MOD 14)
         END IF
         IF mystep% = 1 THEN
           PSET (px%,py%),mycolor%
         ELSE
           LINE (px%,py%)-(px%+mystep%-1,py%+mystep%-1),mycolor%,BF
         END IF
       END IF
     NEXT
   NEXT
   mystep% = mystep%\2
 WEND

 WINDOW OFF

 'WINDOW 2,"Time:"+STR$((TIMER-t&+86400&) MOD 86400&)+" s.",(0,0)-(640,200),,1
 'BEEP
 'WHILE INKEY$ <> ""
 'WEND
 WHILE INKEY$ = ""
 WEND
 'WINDOW CLOSE 2

quit:
  WINDOW CLOSE 1
  SCREEN CLOSE 1
END
