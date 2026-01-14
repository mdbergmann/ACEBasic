{*
** Tic-Tac-Toe
**
** Version 1.0: keyboard-driven
** Version 2.0: gadget-driven
**
** Author: David J Benn
**   Date: 19th,20th,23rd December 1994
**
** Possible enhancements: scoring; font-sensitivity.
*}

DIM voice%(8)

FOR i=0 TO 8
  READ voice%(i)
NEXT

DATA 80,0,160,0,22900,64,10,1,0

'...constants
CONST true=-1, false=0
CONST user=1
CONST comp=2
CONST empty=0
CONST offset=50

'..variables
LONGINT win, moves, tn, UserWantsToPlay
tn=comp
UserWantsToPlay=true

DIM grid(9), grid_x1(9), grid_x2(9), grid_y1(9), grid_y2(9)

WINDOW 1,"TTT v2.0",(offset,offset)-(offset+138,offset+152),14

FOR n=1 TO 9
  READ grid_x1(n),grid_y1(n), grid_x2(n),grid_y2(n)
  GADGET n,ON," ",(grid_x1(n),grid_y1(n))-(grid_x2(n),grid_y2(n)),BUTTON,1
NEXT

READ x1,y1, x2,y2
GADGET 10,ON,"Again?",(x1,y1)-(x2,y2),BUTTON,1

'..First row
DATA 10,10, 40,30
DATA 50,10, 80,30
DATA 90,10, 120,30

'..Second row
DATA 10,40, 40,60
DATA 50,40, 80,60
DATA 90,40, 120,60

'..Third row
DATA 10,70, 40,90
DATA 50,70, 80,90
DATA 90,70, 120,90

'..Again? button
DATA 35,110, 95,130

'...main
RANDOMIZE TIMER : dummy=RND

WHILE UserWantsToPlay
  win=false
  moves=0

  GOSUB clear.grid

  WHILE NOT win AND moves<9
     '...user
     IF tn=user AND NOT win THEN
       GOSUB get.user.move
       IF moves>2 THEN GOSUB win.check
       tn=comp
     END IF

     '...computer
     IF tn=comp AND NOT win AND moves<9 THEN
       GOSUB make.a.move
       IF moves>2 THEN GOSUB win.check
       tn=user
     END IF
  WEND

  IF NOT win THEN
      SAY TRANSLATE$("Game tied."),voice%
      MSGBOX "Game tied.","Continue"
      GOSUB another.game
   ELSE
      '...swap turns after a tie
      IF tn=user THEN tn=comp ELSE tn=user
   END IF
WEND

quit:
  FOR n=1 TO 10 : GADGET CLOSE n : NEXT
  WINDOW CLOSE 1
  STOP

clear.grid:
  '..Close and reopen grid buttons
  FOR n=1 TO 9
   grid(n)=empty
   GADGET CLOSE n
   GADGET n,ON," ",(grid_x1(n),grid_y1(n))-(grid_x2(n),grid_y2(n)),BUTTON,1
  NEXT
  '..Deactivate Again? button
  GADGET 10,OFF
RETURN

get.user.move:
  GADGET WAIT 0
  theGad = GADGET(1)
  IF theGad = 256 THEN quit
  po = theGad
  grid(po)=user
  GADGET CLOSE po
  GADGET po,OFF,"X",(grid_x1(po),grid_y1(po))-(grid_x2(po),grid_y2(po)),BUTTON,1
  ++moves
RETURN

make.a.move:
   po=-1
   player=2

   WHILE player>=1

     IF player=2 THEN n=comp ELSE n=user

     '...search diagonals first
     IF po=-1 THEN
         IF (grid(1)=n) AND (grid(5)=n) AND (grid(9)=empty) THEN
		po=9
	 ELSE
       	     IF (grid(1)=n) AND (grid(5)=empty) AND (grid(9)=n) THEN
	  	 po=5
	     ELSE
       	         IF (grid(1)=empty) AND (grid(5)=n) AND (grid(9)=n) THEN po=1
	     END IF
	 END IF
    END IF

     IF po=-1 THEN
          IF (grid(3)=n) AND (grid(5)=n) AND (grid(7)=empty) THEN
	     po=7
          ELSE
              IF (grid(3)=n) AND (grid(5)=empty) AND (grid(7)=n) THEN
                 po=5
              ELSE
                  IF (grid(3)=empty) AND (grid(5)=n) AND (grid(7)=n) THEN po=3
	      END IF
	  END IF
     END IF

     '...search rows
     IF po=-1 THEN
       i=1
       WHILE i<=7
           IF (grid(i)=n) AND (grid(i+1)=n) AND (grid(i+2)=empty) THEN
            po=i+2
           ELSE
            IF (grid(i)=n) AND (grid(i+1)=empty) AND (grid(i+2)=n) THEN
             po=i+1
            ELSE
             IF (grid(i)=empty) AND (grid(i+1)=n) AND (grid(i+2)=n) THEN po=i
            END IF
           END IF
           i=i+3
       WEND
     END IF

     '...search columns
     IF po=-1 THEN
       FOR i=1 TO 3
           IF (grid(i)=n) AND (grid(i+3)=n) AND (grid(i+6)=empty) THEN
	     po=i+6
           ELSE
             IF (grid(i)=n) AND (grid(i+3)=empty) AND (grid(i+6)=n) THEN
               po=i+3
             ELSE
               IF (grid(i)=empty) AND (grid(i+3)=n) AND (grid(i+6)=n) THEN po=i
             END IF
           END IF
       NEXT
     END IF

     --player
   WEND

   '...make a random selection
   IF po=-1 THEN
      free.pos=false
      WHILE NOT free.pos
        r=INT(RND*9)+1
        IF grid(r)=empty THEN
           po=r
           free.pos=true
        END IF
      WEND
   END IF

   '...claim grid position
   IF po <> -1 THEN
     grid(po)=comp
     GADGET CLOSE po
     GADGET po,OFF,"O",(grid_x1(po),grid_y1(po))-(grid_x2(po),grid_y2(po)),BUTTON,1
   END IF

   ++moves
RETURN

who.won:
     IF tn=user THEN
	SAY TRANSLATE$("You won!"),voice%
	MSGBOX "You won!","Continue"
     ELSE
	SAY TRANSLATE$("I won!"),voice%
	MSGBOX "I won!","Continue"
     END IF
     GOSUB another.game
RETURN

another.game:
  UserWantsToPlay=false
  GADGET 10,ON
  REPEAT
   GADGET WAIT 0
   theGad = GADGET(1)
   IF theGad = 256 THEN quit
   IF theGad = 10 THEN UserWantsToPlay=true
  UNTIL theGad = 256 OR theGad = 10
RETURN

win.check:
   win=0
   player=1

   WHILE player<=2 AND NOT win

     IF player=1 THEN token=user ELSE token=comp

     '...rows
     i=1
     WHILE i<=7 AND NOT win
          IF (grid(i)=token) AND (grid(i+1)=token) AND (grid(i+2)=token) THEN
             win=true
          END IF
          IF (grid(i)=token) AND (grid(i+1)=token) AND (grid(i+2)=token) THEN
             win=true
          END IF
          IF (grid(i)=token) AND (grid(i+1)=token) AND (grid(i+2)=token) THEN
             win=true
	  END IF
          i=i+3
     WEND

     '...columns
     IF NOT win THEN
      FOR i=1 TO 3
          IF (grid(i)=token) AND (grid(i+3)=token) AND (grid(i+6)=token) THEN
             win=true
	  END IF
          IF (grid(i)=token) AND (grid(i+3)=token) AND (grid(i+6)=token) THEN
	     win=true
	  END IF
          IF (grid(i)=token) AND (grid(i+3)=token) AND (grid(i+6)=token) THEN
             win=true
	  END IF
     NEXT
    END IF

     '...diagonals
     IF NOT win THEN
          IF (grid(1)=token) AND (grid(5)=token) AND (grid(9)=token) THEN
	     win=true
	  END IF
          IF (grid(1)=token) AND (grid(5)=token) AND (grid(9)=token) THEN
             win=true
	  END IF
          IF (grid(1)=token) AND (grid(5)=token) AND (grid(9)=token) THEN
             win=true
	  END IF
     END IF

     IF NOT win THEN
          IF (grid(3)=token) AND (grid(5)=token) AND (grid(7)=token) THEN
             win=true
	  END IF
          IF (grid(3)=token) AND (grid(5)=token) AND (grid(7)=token) THEN
             win=true
          END IF
          IF (grid(3)=token) AND (grid(5)=token) AND (grid(7)=token) THEN
	     win=true
	  END IF
     END IF

     ++player

   WEND

   IF win THEN GOSUB who.won

RETURN
