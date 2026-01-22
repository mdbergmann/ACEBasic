
'..HAM8 screen mode demo in ACE.
'..262,144 colors using Hold-And-Modify with 8 bitplanes.
'..Based on ham.b example.
'
'..Requires AGA chipset (A1200, A4000, CD32).

DEFLNG a-z

CONST modblu = 10
CONST modred = 20
CONST modgrn = 30

'..Check for AGA chipset
IF CHIPSET < 2 THEN
  PRINT "This demo requires AGA chipset."
  PRINT "Please run on A1200, A4000, or CD32."
  END
END IF

'..Open HAM8 lores screen (mode 10)
SCREEN 1,320,200,8,10

PALETTE 0,0,0,0
PALETTE 1,0,.53,.53
PALETTE 2,.67,0,.27
PALETTE 3,.2,.6,0

WINDOW 1,,(0,0)-(320,200),32,1

PRINT "HAM8 Mode Demo"
PRINT "262,144 colors from 256 palette"

'..Demo similar to HAM6 but with more color depth
FOR c=1 TO 15
  COLOR modred+c
  LINE (18*c,40)-(18*c+17,60),,bf
  LINE (18*c,130)-(18*c+17,150),modred+c,bf

  COLOR modgrn+c
  LINE (18*c,70)-(18*c+17,90),,bf
  LINE (18*c,160)-(18*c+17,180),modred+c,bf

  COLOR modblu+c
  LINE (18*c,100)-(18*c+17,120),,bf
NEXT

FOR c=1 TO 3
  COLOR c
  LINE (18,30*c+100)-(18,30*c+120)
  SLEEP FOR .25
NEXT

WHILE INKEY$="":SLEEP:WEND

WINDOW CLOSE 1
SCREEN CLOSE 1
