' Serial Stratego
' Written by: Daniel Oberlin

DECLARE FUNCTION ActivateWindow LIBRARY intuition
DECLARE FUNCTION SetWindowTitles LIBRARY intuition

' Some variables that should be integers.
SHORTINT i, j, m0, m1, messmenu, rule1, rule2
SHORTINT movenum, gturn, ourcolor
SHORTINT px, pxa, pxb, py, pya, pyb, pn, pn2, pna, pnb
SHORTINT bx1, by1, bx2, by2, bc
SHORTINT blocked, attack, correct, jump

' Set up initial variables and arrays.
DIM board(9,9), captured(12)
DIM message$(20) : DIM mmessage$(20) : DIM pack%(300) : DIM upack%(8) : DIM fnk$(10)
pc$="123456789S*F  ?+" : num$="0123456789" : vtcode$="HKJr" : messmenu = 5
first% = 63 : null$ = CHR$(1)+CHR$(1)+CHR$(1)+CHR$(1)+CHR$(1)
DIM messbuf$(30) : DIM macro$(10) : for i=1 to 20 : message$(i) = chr$(0) : mmessage$(i) = chr$(0) : next i
screenstat% = -3 : intro%=0
version$ = "Version 1.5"

' This stuff is for the sound subroutines.
declare function xRead&	library
const maxsample=131070, channel=1, CHIP=0, MAXCHIP=2
longint offset&, per&, numsound%
dim wave_ptr&(100)
dim samples_per_second&(10), sz&(10), buffer&(10)
dim soundfile$(10)

' Load preferences.
OPEN "I",2,"stratego.prefs"
IF err<>0 THEN ERMSG$="Error opening preferences file." : GOTO Errr
INPUT #2, baud%
INPUT #2, serstr$
INPUT #2, serdev$
INPUT #2, commod$
INPUT #2, hangup$
INPUT #2, seruni%
INPUT #2, spkdev$
INPUT #2, delim$
INPUT #2, opt%
CLOSE #2

' Load user macros.
OPEN "I",2,"stratego.macros"
IF err<>0 THEN ERMSG$="Error opening preferences file." : GOTO Errr
FOR mac%=1 TO 10
LINE INPUT #2, macro$(mac%)
NEXT mac%
CLOSE #2

' Load sounds.
IF (opt% AND 2) = 0 THEN
numsound%=5
soundfile$(1)="sounds/click.snd"
soundfile$(2)="sounds/ping.snd"
soundfile$(3)="sounds/bomb.snd"
soundfile$(4)="sounds/haha.snd"
soundfile$(5)="sounds/win.snd"
GOSUB Readiffsounds
END IF

' Open Devices
OPEN "O", 3, spkdev$
IF err<>0 THEN ERMSG$="Error opening speak device." : GOTO Errr
screenstat% = -2

SERIAL OPEN 1,seruni%,baud%,serstr$,1024,serdev$
IF err<>0 THEN ERMSG$="Error opening serial device." : CLOSE 3 : GOTO Errr
screenstat% = -1

' Open terminal screen.
SCREEN 1, 640, 200, 1, 2
WINDOW 1, , (0,13)-(640,200) , 32, 1
SetWindowTitles(window(7),-1&,"Serial Stratego "+version$+"   "+"Baud Rate:"+str$(baud%)+" Serial Settings: "+serstr$)

screenstat% = 0

Restart:
SCREEN FORWARD 1
WINDOW OUTPUT 1

GOSUB Inittermmenu

ActivateWindow(window(7))

PALETTE 0, 0, 0, 0
PALETTE 1, 1, 1, 1

FONT "topaz", 8

IF intro%=0 THEN
  CLS
  PRINT
  PRINT "Welcome to Serial STRATEGO ";version$;"      Written By: Daniel Oberlin"
  PRINT 
  PRINT "Now in terminal mode."
  PRINT "Establish link and use the Setup menu to begin the game."
  PRINT
  intro% =1
END IF

' Do Terminal Loop here.
m0 = 0 : m1 = 0
ON MENU GOSUB Termmenuhandler
MENU ON

chars% = serial(1,0) : serial read 1, b$, chars%

Terminaloop:
IF (opt% AND 1) = 0 THEN SLEEP
a$ = INKEY$
IF a$<>"" then serial write 1, a$, 1 : a$=""
chars% = serial(1,0)
IF chars%<>0 THEN serial read 1, b$, chars% : PRINT b$; : b$ = ""

IF m0 = 1 THEN
  m0 = 0
  IF m1 = 3 THEN
    SLEEP FOR 1
    serial write 1, commod$, len(commod$)
    SLEEP FOR 1
    serial write 1, hangup$+chr$(13), len(hangup$)+1
    GOTO Terminaloop
  END IF
  IF m1 = 4 THEN
    GOSUB Closeall
    STOP
  END IF
  IF m1 = 1 THEN
    ourcolor = 0
    GOTO Newgame
  ELSE
    ourcolor = 1
    GOTO Newgame
  END IF
END IF

IF m0 = 2 THEN
  serial write 1, macro$(m1)+CHR$(13), LEN(macro$(m1))+1
  m0 = 0
END IF

GOTO Terminaloop
MENU OFF


' Begin a new game.
Newgame:
opx% = -1 : opy% = -1
gturn  = 1 : rturn% = -1 : lockboard% = 0 : opready% = 0 : gameover% = 0 : m0 = 0 : m1 = 0
movenum  = 0 : rule1 = 0 : rule2 = 1 : ourmess% = 1 : thermess% = 1 : recmode% = 1 : mstat% = 0
FOR i=1 TO 12 : captured(i) = 0 : NEXT i

IF screenstat%=0 THEN
  SCREEN 2, 320, 200, 3, 1
END IF
PALETTE 0, 0, 0, 0
PALETTE 1, 1, 1, 1
IF ourcolor = 0 THEN
  PALETTE 2, 0, 0, 1
  PALETTE 4, 1, 0, 0
ELSE
  PALETTE 4, .4, .4, 1
  PALETTE 2, 1, 0, 0
END IF
PALETTE 3, 0, 1, 0
PALETTE 5, .5, 0, 0
PALETTE 6, 0, 0, .5
IF screenstat%=0 THEN
  WINDOW 2, "Info", (176, 13)-(311, 188), 16, 2
  FONT "topaz", 8
  WINDOW 3, "Game Board", (0, 13)-(175, 194), 16, 2
  FONT "topaz", 8
  screenstat% = 1
END IF

WINDOW OUTPUT 2
CLS
PRINT
PRINT "Setup board."
WINDOW OUTPUT 3
ActivateWindow(window(7))
SetWindowTitles(window(7),-1&,"Serial Stratego "+version$)
SCREEN FORWARD 2

' Load and draw the board.
file$ = "stratego.data"
GOSUB Loadboard
GOSUB Drawboard
WINDOW OUTPUT 3
GOSUB Initmenu


' Let the player switch pieces around to set up
Switchpiece:
lockboard% = 0
GOSUB Gwait
IF m0 = 1 THEN
  m0 = 0
  IF m1 = 1 THEN GOTO Donesetup
  GOTO Switchpiece
END IF
IF rturn% > -1 THEN
  WINDOW OUTPUT 2
  PRINT
  PRINT "No cheating."
  WINDOW OUTPUT 3
  GOTO Switchpiece
END IF
lockboard% = 1
pxa = px
pya = py
pn = board(pxa, pya)
IF pn>12 THEN GOTO Switchpiece
bc = 1
GOSUB Putpiece

IF (opt% AND 2) = 0 THEN
sn% = 1
GOSUB Playsound
END IF

Switchpiece2:
GOSUB Gwait
pxb = px
pyb = py
pn2 = board(pxb, pyb)
IF pn2>12 THEN GOTO Switchpiece2
board(pxb, pyb) = pn : board (pxa, pya) = pn2
bc = 0
px = pxb : py = pyb : pn = board(pxb, pyb) : GOSUB Putpiece
px = pxa : py = pya : pn = board(pxa, pya) : GOSUB Putpiece
IF (opt% AND 2) = 0 THEN
sn% = 1
GOSUB Playsound
END IF
GOTO Switchpiece


' Done setting up.  Wait for opponent to set up.
Donesetup:
lockboard% = 2
send$ = "OK"
GOSUB Sendit
IF opready% = 0 THEN
  WINDOW OUTPUT 2
  PRINT
  PRINT "Wait for setup."
  WINDOW OUTPUT 3
  gturn = 0
  GOSUB Gwait
  IF opready% = 0 THEN
    WINDOW OUTPUT 2
    PRINT
    PRINT "FATAL:"
    PRINT "Error #1"
    WINDOW OUTPUT 3
  END IF
ELSE
  GOSUB Sancheck
END IF

movenum = 1


IF rturn% = -1 AND ourcolor = 1 THEN GOTO Theirturn
IF rturn% = 0 THEN GOTO Theirturn

' It is now our turn.
Ourturn:
gturn = 1 : rturn% = 1
WINDOW OUTPUT 2
PRINT
PRINT "Move #";movenum
PRINT "It is your turn."
WINDOW OUTPUT 3

Whichpiece:
GOSUB Gwait
IF m0 = 3 AND m1 = 2 THEN
  m0 = 0
  send$ = "CON"
  GOSUB Sendit
  WINDOW OUTPUT 2
  PRINT : PRINT "You lose."
  WINDOW OUTPUT 3
  IF (opt% AND 2) = 0 THEN
  sn% = 4
  GOSUB Playsound
  END IF
  GOTO Finish
END IF

pxa = px
pya = py
pn = board(pxa, pya)
pna = pn
IF pn<1 OR pn>10 THEN GOTO Whichpiece
bc = 1 : GOSUB Putpiece

IF opx%<>-1 THEN
  bc = 2 : pn = 13 : px = opx% : py = opy% : GOSUB Putpiece
  opx% = -1 : opy% = -1
END IF

IF (opt% AND 2) = 0 THEN
sn% = 1
GOSUB Playsound
END IF

Wherego:

GOSUB Gwait
pxb = px
pyb = py
pn = board(pxb, pyb)
pnb = pn

IF pxa = pxb AND pya = pyb THEN
  bc = 0
  GOSUB Putpiece
  IF (opt% AND 2) = 0 THEN
  sn% = 1
  GOSUB Playsound
  END IF
  GOTO Whichpiece
END IF

IF pnb<13 THEN GOTO Wherego
IF pna = 9 THEN GOTO Scoutmove

IF pxa = pxb AND pya = pyb + 1 THEN GOTO Okhere
IF pxa = pxb AND pya = pyb - 1 THEN GOTO Okhere
IF pya = pyb AND pxa = pxb + 1 THEN GOTO Okhere
IF pya = pyb AND pxa = pxb - 1 THEN GOTO Okhere

GOTO Wherego

Scoutmove:

blocked = 0
correct = 0
jump = 0

IF pxa = pxb then
  correct = 1
  IF pya > pyb THEN    
    FOR i = (pyb+1) TO (pya-1)
    IF board(pxa, i) <> 14 THEN blocked = 1
    jump = 1
    NEXT i
  ELSE
    FOR i = (pya+1) TO (pyb-1)
    IF board(pxa, i) <> 14 THEN blocked = 1
    jump = 1
    NEXT i
  END IF
END IF

if pya = pyb then
  correct = 1
  IF pxa > pxb THEN
    FOR i = (pxb+1) TO (pxa-1) 
    IF board(i, pya) <> 14 THEN blocked = 1
    jump = 1
    NEXT i
  ELSE
    FOR i = (pxa+1) TO (pxb-1)
    IF board(i, pya) <> 14 THEN blocked = 1
    jump = 1
    NEXT i
  END IF
end if

IF correct = 0 OR blocked = 1 THEN GOTO Wherego

IF pnb = 13 AND rule1 = 0 AND jump = 1 THEN GOTO Wherego
   
Okhere:

send$ = ""
IF pnb = 13 THEN
  attack = 1
  send$ = "A"
ELSE
  attack = 0
  send$ = "M"
END IF

send$ = send$ + MID$(num$, pxa+1, 1) + MID$(num$, pya+1, 1) + MID$(num$, pxb+1, 1) + MID$(num$, pyb+1, 1) 

IF attack = 1 THEN

  send$ = send$ + MID$(pc$, pna, 1)
  GOSUB Sendit
  pnb = 15 : px = pxb : py = pyb : pn = pnb : bc = 3 : GOSUB Putpiece


  gturn = 0  
  GOSUB Gwait
  gturn = 1

  rec$ = RIGHT$(rec$,1)
    
  GOSUB Piecenum
  
  px = pxb : py = pyb : pn = pnb : bc = 3 : GOSUB Putpiece

  IF (opt% AND 2) = 0 THEN
  sn% = 2
  GOSUB Playsound
  END IF

  IF pnb = 11 AND pna <> 8 THEN
    IF (opt% AND 2) = 0 THEN
    SLEEP FOR .25
    sn% = 3
    GOSUB Playsound
    END IF
  END IF

  IF pnb = 12 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "You WIN!!!"
    WINDOW OUTPUT 3
    IF (opt% AND 2) = 0 THEN
    sn% = 5
    GOSUB Playsound
    END IF
    captured(12) = captured(12) + 1 : GOTO Finish 
  END IF
    
  GOSUB Swait

  CASE
  pna = 10 AND pnb = 1: board(pxa, pya) = 14 : board(pxb, pyb) = pna : captured(1) = captured(1) + 1 : goto elabel1
  pnb = 11 AND pna = 8: board(pxa, pya) = 14 : board(pxb, pyb) = pna : captured(11) = captured(11) + 1 : goto elabel1
  pnb = 11 AND pna <>8: board(pxa, pya) = 14 : goto elabel1
  pna = pnb: board(pxa, pya) = 14 : board(pxb, pyb) = 14 : captured(pna) = captured(pna) + 1 : goto elabel1
  pna < pnb: board(pxb, pyb) = pna : board(pxa, pya) = 14 : captured(pnb) = captured(pnb) + 1 : goto elabel1
  END CASE

  IF rule2 = 0 THEN
    board(pxa, pya) = 14
  ELSE
    board(pxa, pya) = 13
    board(pxb, pyb) = 14
  END IF

elabel1:
 
ELSE
  
  GOSUB Sendit
  
  board(pxb, pyb) = pna
  board(pxa, pya) = 14

END IF

pn = board(pxa, pya)
IF pn = 13 THEN
  bc = 2
ELSE
  bc = 0
END IF
px = pxa : py = pya : GOSUB Putpiece

pn = board(pxb, pyb)
IF pn= 13 THEN
  bc = 2
ELSE
  bc = 0
END IF
px = pxb : py = pyb : GOSUB Putpiece
IF (opt% AND 2) = 0 THEN
sn% = 1
GOSUB Playsound
END IF


movenum = movenum +1


' It is now their turn.
Theirturn:
gturn = 0 : rturn% = 0

WINDOW OUTPUT 2
PRINT
PRINT "Move #";movenum
PRINT "Waiting..."
WINDOW OUTPUT 3

GOSUB Gwait

IF rec$="CON" THEN
  WINDOW OUTPUT 2
  PRINT : PRINT "Opponent" : PRINT "concedes:" : PRINT "You WIN!!!"
  WINDOW OUTPUT 3
  IF (opt% AND 2) = 0 THEN
  sn% = 5
  GOSUB Playsound
  END IF
  GOTO Finish
END IF

pxb = 9 - VAL(MID$(rec$, 2, 1)) : pyb = 9 - VAL(MID$(rec$, 3, 1)) : pxa = 9 - VAL(MID$(rec$, 4, 1)) : pya = 9 - VAL(MID$(rec$, 5, 1)) 
pna = board(pxa, pya)

IF LEFT$(rec$, 1) = "A" THEN
  attack = 1
ELSE
  attack = 0
END IF

IF attack = 1 THEN

  rec$ = RIGHT$(rec$, 1) : GOSUB Piecenum


  px = pxb : py = pyb : pn = pnb : bc = 3 : GOSUB Putpiece
  px = pxa : py = pya : pn = pna : bc = 1 : GOSUB Putpiece

  send$ = "V"+MID$(pc$, board(pxa, pya), 1)
  GOSUB Sendit

  IF (opt% AND 2) = 0 THEN
  sn% = 2
  GOSUB Playsound
  END IF

  IF pna = 11 AND pnb <>8 THEN
    IF (opt% AND 2) = 0 THEN
    SLEEP FOR .25
    sn% = 3
    GOSUB Playsound
    END IF
  END IF
  
  gturn  = 1

  IF pna = 12 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "You lose."
    WINDOW OUTPUT 3
    IF (opt% AND 2) = 0 THEN
    sn% = 4
    GOSUB Playsound
    END IF
    GOTO Finish
  END IF

  GOSUB Swait

  gturn  = 0
  
  CASE
  pna = 1 AND pnb = 10: board(pxa, pya) = 13 : board(pxb, pyb) = 14 : goto elabel2
  pna = 11 AND pnb = 8: board(pxa, pya) = 13 : board(pxb, pyb) = 14 : goto elabel2
  pna = 11 AND pnb <>8: board(pxb, pyb) = 14 : captured(pnb) = captured(pnb)+1 : goto elabel2
  pna = pnb: board(pxa, pya) = 14 : board(pxb, pyb) = 14 : captured(pna) = captured(pna)+1 :  goto elabel2
  pna < pnb and rule2 = 1: board(pxb, pyb) = pna : board(pxa, pya) = 14 : captured(pnb) = captured(pnb)+1 : goto elabel2
  pna < pnb and rule2 <>1: board(pxb, pyb) = 14 : captured(pnb) = captured(pnb)+1 : goto elabel2
  END CASE

  board(pxa, pya) = 13
  board(pxb, pyb) = 14
  
elabel2:

ELSE

  board(pxb, pyb) = 14
  board(pxa, pya) = 13

END IF

pn = board(pxa, pya)
IF pn = 13 THEN
  pn = 16 : opx% = pxa : opy% = pya
ELSE
  opx% = -1 : opy% = -1
END IF 
IF pn>12 THEN
  bc = 2
ELSE
  bc = 0
END IF
px = pxa : py = pya : GOSUB Putpiece

pn = board(pxb, pyb)
IF pn=13 THEN
  bc = 2
ELSE
  bc = 0
END IF
px = pxb : py = pyb : GOSUB Putpiece

IF (opt% AND 2) = 0 THEN
sn% = 1
GOSUB Playsound
END IF

movenum = movenum + 1

GOTO Ourturn


' We are finished with the game now.  Only may exit via menu.  Tacky, I know.
Finish:
gturn = 1
gameover% = 1
Finish2:
GOSUB Gwait
GOTO Finish2



Drawboard:
bx1 = 0 : by1 = 0 : bx2 = 161 : by2 = 161
COLOR 5, 0
GOSUB Fillbox

bx1 = 3 : by1 = 3
COLOR 1, 0
GOSUB Fillbox

FOR py=0 TO 9
FOR px=0 TO 9
pn = board(px,py)
IF pn=13 THEN
  bc = 2
ELSE
  bc = 0
END IF
IF pn>0 THEN GOSUB Putpiece
NEXT px
NEXT py

COLOR 6, 0 

bx1 = 37 : by1 = 69 : bx2 = 29 : by2 = 29
GOSUB Fillbox

bx1 = 101
GOSUB Fillbox
RETURN


Putpiece:

' Color the square green to write over old piece.
COLOR 3, 0
bx2 = 13 : by2 = 13
bx1 = px*16 + 5
by1 = py*16 + 5
GOSUB Fillbox

' Blank square.
IF pn = 14 THEN RETURN

' Our color is 4, there's is 2, black is 0, white is 1.
IF bc<2 THEN
	COLOR 4, 0
ELSE
	COLOR 2, 0
END IF

bx2 = 9 : by2 = 9
bx1 = px*16 + 7
by1 = py*16 + 7
GOSUB Fillbox

IF bc=0 THEN
	COLOR 0, 4
END IF
IF bc=1 THEN
	COLOR 1, 4
END IF
IF bc=2 THEN
	COLOR 0, 2
END IF
IF bc=3 THEN
	COLOR 1, 2
END IF

LOCATE  py*2 + 2, px*2 + 2
PRINT MID$(pc$, pn, 1);
RETURN


Fillbox:
AREA (bx1, by1 ) : AREA STEP (bx2, 0) : AREA STEP (0, by2) : AREA STEP (-bx2, 0)
AREAFILL
RETURN


Piecenum:
pnb = 0
FOR i = 1 TO 13
IF rec$ = MID$(pc$, i, 1) THEN pnb = i
NEXT i
RETURN


Loadboard:
OPEN "I",2,file$
IF err<>0 THEN ERMSG$="Error opening "+file$+" to load board." : GOTO Errr
FOR j=0 TO 9
FOR i=0 TO 9
INPUT #2, board(i,j)
NEXT i
NEXT j
INPUT #2, rturn%
CLOSE #2
RETURN


Saveboard:
OPEN "O",2,file$
IF err<>0 THEN ERMSG$="Error opening "+file$+" to save board." : GOTO Errr
FOR j=0 TO 9
FOR i=0 TO 9
PRINT #2, board(i,j)
NEXT i
NEXT j
PRINT #2, rturn%
CLOSE #2
RETURN


' This is the main polling subroutine.  Handles modem, mouse, etc.
Gwait:

ON MENU GOSUB Menuhandler
MENU ON
SLEEP

REM Process menu selection.
IF m0>0 THEN
  IF m0 = 3 AND m1 = 2 AND gturn = 1 AND movenum > 0 THEN RETURN  ' Concede the game.
  IF m0 = 1 AND m1 = 1 AND gturn = 1 AND movenum = 0 THEN RETURN  ' Done setting up.
  m0 = 0
  GOTO Gwait
END IF

REM Process mouse button.
IF MOUSE(0) <> 0 THEN

  IF gturn = 1 AND mstat%=1 THEN
    GOTO Gwait
  END IF

  IF gturn = 1 AND mstat%=0 THEN
    mstat% = 1
    px = MOUSE(1) : py = MOUSE(2)
    px = INT((px-5)/16) : py = INT((py-4)/16)

    IF px<0 OR px>9 OR py<0 OR py>9 OR board(px,py)<1 THEN GOTO Abortmouse

    RETURN

    Abortmouse: 

  END IF

ELSE
  mstat% = 0
END IF

REM Process keyboard
bb$ = INKEY$
IF bb$<> "" THEN
  b$ = bb$
  GOSUB Entermess
END IF

MENU OFF

REM Process Modem.
Procmodem:
GOSUB Getmodem

IF b$ <> "" THEN

  WINDOW OUTPUT 1
  PRINT b$;
  WINDOW OUTPUT 3

  IF b$ <> MID$(delim$, ((ourcolor+1) MOD 2)+1, 1) THEN GOTO Procmodem

  packet$ = ""

  timeflag% = 0
  vtflag% = 0

  Hwait:
  GOSUB Getmodem

  IF b$<> "" THEN

    WINDOW OUTPUT 1
    PRINT b$;
    WINDOW OUTPUT 3

' The following code was added to filter out VT-100 escape sequences which are used with talk.
' These sequences start with "(ESC)[" and end with "H", "K", "J", or "r".
    IF ASC(b$) = 27 THEN
      vtflag% = 1
      GOTO Hwait
    END IF
    IF vtflag%=1 AND b$="[" THEN
      vtflag% = 2
      vtcount% = 0
      GOTO Hwait
    END IF
    IF vtflag%=2 THEN
      vtcount% = vtcount%+1
      IF vtcount%>10 THEN vtflag% = 0
      FOR chkvt%=1 TO LEN(vtcode$)
        IF b$=MID$(vtcode$,chkvt%,1) THEN
          vtflag% = 0
        END IF
      NEXT chkvt%
      GOTO Hwait
    END IF


    IF b$ = MID$(delim$, ((ourcolor+1) MOD 2)+3, 1) THEN GOTO Checkit

    IF ASC(b$) < first%+((ourcolor+1) MOD 2)*32 OR ASC(b$) > first%+((ourcolor+1) MOD 2)*32+31 THEN GOTO Hwait

    packet$ = packet$+b$
    GOTO Hwait
  END IF
    
  SLEEP

  ++timeflag%

  IF timeflag% < 8 THEN GOTO Hwait

REM Timeout error.
  send$ = "R"+STR$(thermess%)
  GOSUB Sendit
  thermess%  = thermess%+1
  WINDOW OUTPUT 2
  PRINT
  PRINT "Data Timeout"
  WINDOW OUTPUT 3
  GOTO Gwait
  
  Checkit:
  GOSUB Decode

REM Checksum error.
  IF rec$ = "ER" THEN 
    send$ = "R"+STR$(thermess%)
    GOSUB Sendit
    thermess%  = thermess%+1
    WINDOW OUTPUT 2
    PRINT
    PRINT "Chksum Err"
    WINDOW OUTPUT 3
    GOTO Gwait
  END IF

REM Message from opponent.  
  IF LEFT$(rec$,1)="Z" THEN
    rec$ = RIGHT$(rec$, LEN(rec$)-1)
    WINDOW OUTPUT 2
    PRINT 
    PRINT "Opponent:"

' Bug when printing CR's in strings.

    FOR i=1 to len(rec$)
      IF mid$(rec$, i, 1)=chr$(13) THEN
        PRINT
      ELSE
        PRINT mid$(rec$, i, 1);
      END IF
    NEXT i
    PRINT

    tell$ = rec$
    GOSUB Sayit
    thermess%  = thermess%+1
    WINDOW OUTPUT 3
    GOTO Gwait
  END IF

REM Ping/Pong received.
  IF LEFT$(rec$,1)="P" THEN
    IF rec$="PING" THEN
      WINDOW OUTPUT 2
      PRINT 
      PRINT "Ping!"
      send$ = "PONG" 
      GOSUB Sendit
    END IF

    IF rec$="PONG" THEN
      WINDOW OUTPUT 2
      PRINT 
      PRINT "Pong!"
    END IF
    thermess%  = thermess%+1
    WINDOW OUTPUT 3
    GOTO Gwait
  END IF

REM Sanity Check received.
  IF LEFT$(rec$, 2)="S1" THEN
    WINDOW OUTPUT 2
    send$="S2"+chr$((ourmess% MOD 10)+2)
    
    IF (ASC(MID$(rec$, 3, 1))-2) <> (thermess% MOD 10) THEN
      thermess% = ASC(MID$(rec$, 3, 1))-2
      PRINT
      PRINT "Sync Error"
      PRINT "Opponent"
      send$ = send$+chr$(2)
    ELSE
      send$ = send$+chr$(3)
    END IF

    sanchk% = 0

    FOR stobodx% = 9 TO 0 STEP -1
    FOR stobody% = 9 TO 0 STEP -1

      bochk% = ASC(MID$(rec$, 4+(9-stobody%)+(9-stobodx%)*10, 1))

      IF bochk% = 3 THEN
        IF board(stobodx%, stobody%)>0 AND board(stobodx%, stobody%)<14 THEN
          sanchk% = 1
        END IF
      END IF

      IF bochk% = 2 THEN
        IF board(stobodx%, stobody%)<1 OR board(stobodx%, stobody%)>12 THEN
          sanchk% = 1
        END IF
      END IF

      IF bochk% = 4 THEN
        IF board(stobodx%, stobody%)<>13 THEN
          sanchk% = 1
        END IF
      END IF

    NEXT stobody%
    NEXT stobodx%

    IF sanchk% = 0 THEN
      send$ = send$+chr$(3)
    ELSE
      PRINT
      PRINT "FATAL:"
      PRINT "Sanity Error"
      send$ = send$+chr$(2)
    END IF

    GOSUB Sendit
    thermess%  = thermess%+1
    WINDOW OUTPUT 3
    GOTO Gwait
  END IF

  
REM Opponent has sent his pieces..
  IF LEFT$(rec$, 1)="X" THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "Getting board."
    WINDOW OUTPUT 3
    FOR stobodx% = 0 TO 9
    FOR stobody% = 0 TO 9
      bochk% = ASC(MID$(rec$, 2+(9-stobody%)+(9-stobodx%)*10, 1))-1
      IF bochk%>0 AND bochk%<13 THEN
      pn = bochk% : px = stobodx% : py = stobody% : bc = 2 : GOSUB Putpiece
      END IF
    NEXT stobody%
    NEXT stobodx%
    thermess%  = thermess%+1
    GOTO Gwait
  END IF


  IF LEFT$(rec$, 2)="S2" THEN
    WINDOW OUTPUT 2
    PRINT
    PRINT "Sanity checked."
    IF (ASC(MID$(rec$, 3, 1))-2) <> (thermess% MOD 10) THEN
      thermess% = ASC(MID$(rec$, 3, 1))-2
      PRINT
      PRINT "Sync Error"
      PRINT "Opponent"
    END IF

    IF ASC(MID$(rec$, 4, 1))=2 THEN
      PRINT
      PRINT "Sync Error"
      PRINT "Our Side"
    END IF

    IF ASC(MID$(rec$, 5, 1))=2 THEN
      PRINT
      PRINT "FATAL:"
      PRINT "Sanity Error"
    END IF

    thermess%  = thermess%+1
    WINDOW OUTPUT 3
    GOTO Gwait
  END IF


REM Rule change.  
  IF LEFT$(rec$,1)="Y" THEN
    
    rec$ = RIGHT$(rec$, LEN(rec$)-2)
    rulech% = VAL(rec$)

    CASE  
    rulech% = 0: rule1 = 0 : MENU 3, 3, 1, "  Scout Strike"
    rulech% = 1: rule1 = 1 : MENU 3, 3, 1, "* Scout Strike"
    rulech% = 2: rule2 = 0 : MENU 3, 4, 1, "  Defender Occupies"
    rulech% = 3: rule2 = 1 : MENU 3, 4, 1, "* Defender Occupies"
    END CASE

    WINDOW OUTPUT 2
    PRINT 
    PRINT "Rule Change."
    WINDOW OUTPUT 3
       
    thermess%  = thermess%+1
    GOTO Gwait

  END IF

REM Resend.  
  IF LEFT$(rec$,1)="R" THEN
    rec$ = RIGHT$(rec$, LEN(rec$)-2)
    rsnum% = VAL(rec$)
    send$ = messbuf$(rsnum% MOD 30)
    GOSUB Sendit

    thermess%  = thermess%+1

    WINDOW OUTPUT 2
    PRINT 
    PRINT "Resend."
    WINDOW OUTPUT 3
    GOTO Gwait
    
  END IF

REM Opponent is done setting up.
  IF rec$ = "OK" THEN
    opready% = 1
    WINDOW OUTPUT 2
    PRINT 
    PRINT "Opponent"
    PRINT "Ready."
    WINDOW OUTPUT 3
    thermess%  = thermess%+1
    IF gturn = 0 THEN RETURN
    GOTO Gwait
  END IF
  
  IF gturn = 1 THEN
      WINDOW OUTPUT 2
      PRINT "FATAL:
      PRINT "Error #2"
      WINDOW OUTPUT 3
  END IF

  thermess%  = thermess%+1

  RETURN
        
END IF

GOTO Gwait:


' This subroutine lets you enter a message to send to the opponent.
Entermess:
  WINDOW OUTPUT 2
  ActivateWindow(window(7))

  PRINT 
  PRINT "Type Message:"
  sendmes$ = chr$(0)
  stormes$ = chr$(0)

  totlen% = 0
  lspc% = 0
  colm% = 1
 
  IF b$<>"" THEN GOTO Gotoneb4
  
  Gettext2:
  IF (opt% AND 1) = 0 THEN SLEEP
  b$ = INKEY$

  IF b$ = "" THEN GOTO Gettext2

  Gotoneb4:

  IF (b$ = CHR$(127) OR b$ = CHR$(8)) THEN
    IF colm%>1 THEN
      totlen% = totlen%-1
      colm% = colm% - 1
      PRINT CHR$(8);
      sendmes$ = LEFT$(sendmes$, LEN(sendmes$)-1)
      stormes$ = LEFT$(stormes$, LEN(stormes$)-1)
      lspc% = 0

      IF colm%>1 THEN
        FOR er% = colm%-1 TO 1 STEP -1
          IF MID$(sendmes$, LEN(sendmes$)-colm%+er%+1, 1) = " " THEN
            lspc% = er%
            er% = 1
          END IF
        NEXT er%
      END IF

    END IF

    GOTO Gettext2

  END IF

  IF totlen% = 79 and b$<>CHR$(13) THEN GOTO Gettext2

  totlen% = totlen%+1

  IF colm% = 16 THEN
    IF lspc% = 0 THEN
      colm% = 0
      sendmes$ = sendmes$+b$+chr$(13)  
      stormes$ = stormes$+b$
      PRINT b$
    ELSE
      FOR er% = 1 to 15-lspc%
        PRINT chr$(8);
      NEXT er%
      PRINT
      PRINT right$(sendmes$,15-lspc%);b$;
      sendmes$ = left$(sendmes$, len(sendmes$)-(15-lspc%))+chr$(13)+right$(sendmes$,15-lspc%)+b$
      stormes$ = stormes$+b$
      colm% = 16-lspc%
      lpsc% = 0
    END IF
  ELSE
    sendmes$ = sendmes$+b$
    stormes$ = stormes$+b$
    PRINT b$;
  END IF

  IF b$=" " THEN
     lspc% = colm%
  END IF

  colm% = colm%+1

  IF b$ = CHR$(13) THEN GOTO Gettext3
  GOTO Gettext2

  Gettext3:

  sendmes$ = left$(sendmes$, len(sendmes$)-1)
  stormes$ = left$(stormes$, len(stormes$)-1)

  PRINT

  send$ = "Z"+sendmes$
  GOSUB Sendit

  tell$ = sendmes$
  GOSUB Sayit          

  WINDOW OUTPUT 3
  ActivateWindow(window(7))

  IF recmode%=1 AND sendmes$<>chr$(13) THEN
    message$(messmenu - 4) = sendmes$
    mmessage$(messmenu - 4) = left$(stormes$, 26) 
    MENU 2, messmenu, 1, mmessage$(messmenu-4)
    messmenu = messmenu + 1
    IF messmenu = 19 THEN messmenu = 5
  END IF

RETURN


Swait:
IF  MOUSE(0) < 0 THEN mstat%=1 : RETURN
SLEEP
GOTO Swait


Initmenu:
MENU 1, 0, 1, "Setup"
MENU 1, 1, 1, "Done  Setting Up"
MENU 1, 2, 1, "----------------"
MENU 1, 3, 1, "Load Setup #1"
MENU 1, 4, 1, "Load Setup #2"
MENU 1, 5, 1, "Load Setup #3"
MENU 1, 6, 1, "Load Setup #4"
MENU 1, 7, 1, "Load Setup #5"
MENU 1, 8, 1, "----------------"
MENU 1, 9, 1, "Save Setup #1"
MENU 1, 10, 1, "Save Setup #2"
MENU 1, 11, 1, "Save Setup #3"
MENU 1, 12, 1, "Save Setup #4"
MENU 1, 13, 1, "Save Setup #5"

MENU 2, 0, 1, "Dialog"
MENU 2, 1, 1, "Send A Message"
IF recmode%=1 then MENU 2, 2, 1, "Message Buffer Is On"
IF recmode%=0 then MENU 2, 2, 1, "Message Buffer Is Off"
MENU 2, 3, 1, "Send Ping"
MENU 2, 4, 1, "--------------------------"

FOR mendex%=5 to 18
  IF mmessage$(mendex%-4)<>chr$(0) THEN
    MENU 2, mendex%, 1, mmessage$(mendex%-4)
  ELSE
    mendex%=18
  END IF
NEXT mendex%

MENU 3, 0, 1, "Game"
MENU 3, 1, 1, "  Rank Report"
MENU 3, 2, 1, "  Concede Game"
IF rule1 = 0 THEN MENU 3, 3, 1, "  Scout Strike"
IF rule1 = 1 THEN MENU 3, 3, 1, "* Scout Strike"
IF rule2 = 0 THEN MENU 3, 4, 1, "  Defender Occupies"
IF rule2 = 1 THEN MENU 3, 4, 1, "* Defender Occupies"
MENU 3, 5, 1, "  Sanity Check"
MENU 3, 6, 1, "  Reveal Pieces"
MENU 3, 7, 1, "  Restart as Red"
MENU 3, 8, 1, "  Restart as Blue"
MENU 3, 9, 1, "  Exit to Terminal"
MENU 3, 10, 1, "  Exit Program"

RETURN


Inittermmenu:
MENU 1, 0, 1, "Setup"
MENU 1, 1, 1, "Setup Game as Red"
MENU 1, 2, 1, "Setup Game as Blue"
MENU 1, 3, 1, "Hangup Modem"
MENU 1, 4, 1, "Exit Program"

MENU 2, 0, 1, "Macros"
FOR mac%=1 TO 10
MENU 2, mac%, 1, LEFT$(macro$(mac%),20)
NEXT mac%
RETURN


Menuhandler:

m0 = MENU(0) : m1 = MENU(1)

IF m0 = 1 THEN
  IF m1>2 AND m1<8 THEN
    IF lockboard% = 0 THEN
      file$ = "setup"+CHR$(48+m1-2)+".data"
      GOSUB Loadboard
      GOSUB Drawboard
    ELSE
      IF lockboard% = 1 THEN
        WINDOW OUTPUT 2
        PRINT
        PRINT "Unselect"
        PRINT "piece first."
      ELSE
        WINDOW OUTPUT 2
        PRINT
        PRINT "You may not"
        PRINT "load a board"
        PRINT "now, you are"
        PRINT "playing!"
      END IF
    END IF
  END IF
  IF m1>8 AND m1<14 THEN
    file$ = "setup"+CHR$(48+m1-8)+".data"
    GOSUB Saveboard
  END IF
END IF

IF m0 = 2 THEN

  IF m1 = 1 THEN
    GOSUB Entermess
  END IF

  IF m1 = 2 THEN
     IF recmode% = 0 THEN
        recmode%  = 1
        MENU 2, 2, 1, "Message Buffer Is On"
     ELSE
        recmode%  = 0
        MENU 2, 2, 1, "Message Buffer Is Off"
     END IF
  END IF

  IF m1 = 3 THEN
    send$ = "PING" 
    GOSUB Sendit
    WINDOW OUTPUT 2
    PRINT
    PRINT "Ping..."
  END IF

  IF m1 > 4 THEN
    send$ = "Z"+message$(m1-4) 
    GOSUB Sendit
    WINDOW OUTPUT 2
    PRINT
    PRINT "To Opponent:"

' Strange when printing CR's in strings.

    FOR er%=1 to len(message$(m1-4))
      IF mid$(message$(m1-4), er%, 1) = chr$(13) THEN
        PRINT
      ELSE
        PRINT mid$(message$(m1-4), er%, 1);
      END IF
    NEXT er%
    PRINT

    tell$ = message$(m1-4)
    GOSUB Sayit
  END IF

END IF

IF m0 = 3 THEN

  IF m1 = 1 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "Pieces Captured:"
    FOR k = 1 TO 12 : PRINT MID$(pc$, k, 1);"  / ";captured(k) : NEXT k
  END IF

  IF m1 = 3 AND ourcolor = 0 AND movenum = 0 THEN
    IF rule1 = 0 THEN
      rule1 = 1
      MENU 3, 3, 1, "* Scout Strike"
      rulech% = 1
     ELSE
      rule1 = 0
      MENU 3, 3, 1, "  Scout Strike"
      rulech% = 0
    END IF
    send$ = "Y"+STR$(rulech%)
    GOSUB Sendit
  END IF

  IF m1 = 4 AND ourcolor = 0 AND movenum = 0 THEN

    IF rule2 = 0 THEN
      rule2 = 1
      MENU 3, 4, 1, "* Defender Occupies"
      rulech% = 3
    ELSE
      rule2  = 0
      MENU 3, 4, 1, "  Defender Occupies"
      rulech% = 2
    END IF
    send$ = "Y"+STR$(rulech%)
    GOSUB Sendit
  END IF

  IF m1 = 5 THEN
  IF gturn = 0 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "Not your turn."
    WINDOW OUTPUT 3
  ELSE
    GOSUB Sancheck
  END IF
  END IF

  IF m1 = 6 THEN
  IF gameover%=0 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "Game not over."
  ELSE
    WINDOW OUTPUT 2
    PRINT : PRINT "Sending board."
    send$ = "X"
    FOR stobodx% = 0 TO 9
    FOR stobody% = 0 TO 9
      IF board(stobodx%, stobody%)>0 AND board(stobodx%, stobody%)<13 THEN
          send$ = send$+CHR$(1+board(stobodx%, stobody%))
        ELSE
          send$ = send$+CHR$(16)
      END IF
    NEXT stobody%
    NEXT stobodx%
    GOSUB Sendit
  END IF
  END IF

  IF m1 = 7 THEN
  IF gameover%=0 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "Game not over."
  ELSE
    ourcolor=0
    GOTO Newgame
  END IF
  END IF

  IF m1 = 8 THEN
  IF gameover%=0 THEN
    WINDOW OUTPUT 2
    PRINT : PRINT "Game not over."
  ELSE
    ourcolor=1
    GOTO Newgame
  END IF
  END IF

  IF m1 = 9 THEN
    GOTO Restart
  END IF

  IF m1 = 10 THEN
    GOSUB Closeall
    STOP
  END IF

END IF

WINDOW OUTPUT 3
ActivateWindow(window(7))

RETURN

Sancheck:
WINDOW OUTPUT 2
PRINT
PRINT "Checking the"
PRINT "boards..."
WINDOW OUTPUT 3
send$ = "S1"+chr$((ourmess% MOD 10)+2)
FOR stobodx% = 0 TO 9
FOR stobody% = 0 TO 9
  IF board(stobodx%, stobody%)>0 AND board(stobodx%, stobody%)<14 THEN
    IF board(stobodx%, stobody%) = 13 THEN
      send$ = send$+CHR$(2)
    ELSE
      send$ = send$+CHR$(4)
    END IF
  ELSE
    send$ = send$+CHR$(3)
  END IF
NEXT stobody%
NEXT stobodx%
GOSUB Sendit
RETURN

Termmenuhandler:
m0 = MENU(0) : m1 = MENU(1)
RETURN

Getmodem:
b$ = ""
chars% = serial(1,0)
IF chars%<>0 THEN serial read 1, b$, 1
RETURN


Sayit:
REM SAY TRANSLATE$(tell$),voice%
PRINT #3, tell$+chr$(13)
RETURN


Closeall:
MENU CLEAR
IF screenstat%>0 THEN
  WINDOW CLOSE 3
  WINDOW CLOSE 2
  SCREEN CLOSE 2
END IF

IF screenstat%>-1 THEN
  WINDOW CLOSE 1
  SCREEN CLOSE 1
END IF

IF screenstat%>-2 THEN
  SERIAL CLOSE 1
END IF

IF screenstat%>-3 THEN
  CLOSE 3
END IF
RETURN


Errr:
GOSUB Closeall
PRINT
PRINT ERMSG$
PRINT
STOP



'
' These are the packet encoding and decoding routines.
'

Sendit:

messbuf$(ourmess% MOD 30) = send$

' Put string into integer array for checksum and packing.
pack%(1) = 0 : pack%(2) = 0
FOR cheki%=1 TO LEN(send$) : pack%(cheki%+2) = ASC(MID$(send$, cheki%, 1)) : NEXT cheki%
packlen% = LEN(send$)+2

' Pad message to even 5 bytes.
IF packlen% MOD 5 <> 0 THEN
  FOR cheki%=1 TO 5-(packlen% MOD 5)
    pack%(cheki%+packlen%) = 0
  NEXT cheki%
  packlen% = packlen%+5-(packlen% MOD 5)
END IF

' Prepend CRC16 checksum
GOSUB Crc16calc
pack%(1) = check& AND 255 : pack%(2) = SHR(check&,8)

' Commented code simulates data errors for testing.
'IF RND(0)<.2 THEN pack%(1) = pack%(1)+1

nmblk%  = packlen%/5
trans$  = MID$(delim$, ourcolor+1, 1)
bas%  = first%+ourcolor*32

' We pack bytes into 5 bit ASCII characters from 63-126 (each player uses 32
' of the 64 available characters).
FOR curblk% = 0 TO nmblk%-1
  trans$  = trans$ + CHR$(bas%+SHR(pack%((curblk%*5)+1),3))
  trans$  = trans$ + CHR$(bas%+SHL((pack%((curblk%*5)+1) AND 7),2) + SHR(pack%((curblk%*5)+2),6))
  trans$  = trans$ + CHR$(bas%+(SHR(pack%((curblk%*5)+2),1) AND 31))
  trans$  = trans$ + CHR$(bas%+SHL((pack%((curblk%*5)+2) AND 1),4) + SHR(pack%((curblk%*5)+3),4))
  trans$  = trans$ + CHR$(bas%+SHL((pack%((curblk%*5)+3) AND 15),1) + SHR(pack%((curblk%*5)+4),7))
  trans$  = trans$ + CHR$(bas%+(SHR(pack%((curblk%*5)+4),2) AND 31))
  trans$  = trans$ + CHR$(bas%+SHL((pack%((curblk%*5)+4) AND 3),3) + SHR(pack%((curblk%*5)+5),5))
  trans$  = trans$ + CHR$(bas%+(pack%((curblk%*5)+5) AND 31))
NEXT curblk%

trans$  = trans$ + MID$(delim$, ourcolor+3, 1)+chr$(13)

' Commented code simulates timeout errors.
'IF RND(0)>.2 THEN

serial write 1, trans$, len(trans$)

'ELSE
'serial write 1, left$(trans$, 3), 3
'END IF

ourmess% = ourmess%+1
RETURN


Decode:

nmblk%  = LEN(packet$)/8
bas%  = first%+((ourcolor+1) MOD 2)*32

FOR curblk% = 0 TO nmblk%-1
  FOR iz% = 1 TO 8 : upack%(iz%) = ASC(MID$(packet$, curblk%*8+iz%, 1)) - bas% : NEXT iz%
  pack%((curblk%*5)+1) = SHL(upack%(1),3)+SHR(upack%(2),2)
  pack%((curblk%*5)+2) = (SHL(upack%(2),6)+SHL(upack%(3),1) AND 254)+SHR(upack%(4),4)
  pack%((curblk%*5)+3) = (SHL(upack%(4),4)+SHR(upack%(5),1)) AND 255
  pack%((curblk%*5)+4) = (SHL(upack%(5),7)+SHL(upack%(6),2) AND 252)+SHR(upack%(7),3)
  pack%((curblk%*5)+5) = (SHL(upack%(7),5)+upack%(8)) AND 255
NEXT curblk%

packlen% = nmblk%*5
GOSUB Crc16calc

IF check& = 0 THEN
  rec$  = ""
  FOR iz% = 3 TO nmblk%*5
    IF pack%(iz%)<>0 THEN rec$ = rec$+chr$(pack%(iz%))
  NEXT iz%
ELSE
  rec$ = "ER"
END IF

RETURN


Crc16calc:
' Calculate CRC16 checksum for the array pack, starting with element
' packlen% and ending with element 1.

CONST poly = &H00018005

check& = SHL(pack%(packlen%),8) + pack%(packlen%-1)

FOR ci% = packlen%-2 TO 1 STEP -1
  FOR cj%=7 TO 0 STEP -1

    dmask% = SHL(1,cj%)

    IF (pack%(ci%) AND dmask%) <> 0 THEN
      check& = SHL(check&,1) + 1
    ELSE
      check& = SHL(check&,1)
    END IF

    IF (check& AND &H00010000) <> 0 THEN
      check& = (check& XOR poly)
    END IF

  NEXT cj%
NEXT ci%

RETURN



{ 
  << play a sound file! >>
  Currently handles IFF 8SVX format.
  Author: David J Benn
  Changed by Dan Oberlin
}


Readiffsounds:

for i=1 to numsound%

'..file sample_size?
open "I",1,soundfile$(i)

sample_size&=lof(1)

if sample_size&=0 then
  ERMSG$="Can't open "+soundfile$(i)+"." : GOTO Errr
end if

 { if IFF 8SVX sample, return
   offset from start of file to
   sample data and sampling rate in
   samples per second. }

'..skip FORM#### ?
dummy$=input$(8,#1)

'..8SVX ?
x$=input$(4,#1)
if x$="8SVX" then

  '..skip VHDR###
  dummy$=input$(8,#1)

  '..skip ULONGs x 3 
  dummy$=input$(12,#1)

  '..get sampling rate bytes
  hi%=asc(input$(1,#1))  '..high byte
  lo%=asc(input$(1,#1))  '..low byte
  samples_per_second&(i)=hi%*256 + lo%

  '..find BODY

  '..skip rest of Voice8Header structure
  dummy$=input$(6,#1)

  offset&=40  '..bytes up to this point
  repeat 
   repeat
     x$=input$(1,#1)
     offset&=offset&+1
   until x$="B" and not eof(1)
   if not eof(1) then
     body$=input$(3,#1)
     offset&=offset&+3
   end if
  until body$="ODY" and not eof(1) 

  if not eof(1) then
    x$=input$(4,#1)  '..skip ####   
    offset&=offset&+4
  else
' Error in file format.
    ERMSG$="Error in soundfile "+soundfile$(i)+"." : GOTO Errr
  end if
else
  close 1
' Error in file.
  ERMSG$="Error in soundfile "+soundfile$(i)+"." : GOTO Errr
end if

sz&(i)=sample_size&-offset&

'..get the sample bytes
buffer&(i)=Alloc(sz&(i),CHIP) '...sample_size& bytes of CHIP RAM
if buffer&(i) = NULL then 
' Not enough chipmem.
  ERMSG$="Not enough chip RAM for sounds." : GOTO Errr
end if

fh& = handle(1)
bytes& = xRead(fh&,buffer&(i),sz&(i))
close 1

next i

return


Playsound:

'..calculate period
per& = 3579546 \ samples_per_second&(sn%)

if sz&(sn%) <= maxsample then
  bytes&=sz&(sn%)
  '..play it in one go
  wave channel,buffer&(sn%),sz&(sn%)
  dur&=.279365*per&*bytes&/1e6*18.2
  if dur&>1 then dur& = dur&-1
  sound per&,dur&,,channel
else
  segments&=sz&(sn%)\maxsample
  buf&=buffer&(sn%)
  szz&=sz&(sn%)

  '..get the segment pointers
  for i&=0 to segments&
    wave_ptr&(i&)=buf&+maxsample*i&
  next

  '..play sample in segments
  for i&=0 to segments&
    if szz& >= maxsample then 
       wave channel,wave_ptr&(i&),maxsample 
       bytes&=maxsample
    else 
       wave channel,wave_ptr&(i&),szz&
       bytes&=szz&
    end if
    dur&=.279365*per&*bytes&/1e6*18.2
    if dur&>1 then dur& = dur&-1
    sound per&,dur&,,channel
    szz&=szz&-maxsample
  next   
end if

return