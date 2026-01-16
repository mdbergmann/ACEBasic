'...talking clock

DIM t$(60)     '...need to set aside array of size 60 for words
dim v%(8)

'...read the speech words
FOR i = 1 TO 20
  READ t$(i)                       '...1-20
NEXT
READ t$(30),t$(40),t$(50),t$(60)   '...30,40,50,60

DATA WAHN,TUW,THRXIY,FOHRX,FAYV,SIHKS,SEHVEHN
DATA EYQT,NAYN,TEHN,IYLEHVEHN,TWEHLV,THEHRQTIYN
DATA FOHRXQTIYN,FIHFQTIYN,SIHKSQTIYN,SEHVEHNQTYNN
DATA EYQTIYN,NAYNQTIYN
DATA TWEHNQTIY,THERQTIY,FOHRXQTIY,FIHFQTIY,SIHKSQTIY

'...read voice characteristics 
FOR j = 0 TO 8
  READ v%(j)
NEXT

DATA 80,0,160,0,22900,64,10,0,0    

'.......................................................

'...get the system time
tm$=TIME$

hours$=LEFT$(tm$,2)
min$=MID$(tm$,4,2)
sec$=RIGHT$(tm$,2)

hour=VAL(hours$)
min=VAL(min$)
sec=VAL(sec$)

IF hour > 12 THEN hour=hour-12  '...convert to 12 hour clock
if hour = 0 then hour=12

minunit=VAL(RIGHT$(min$,1))
minten=VAL(LEFT$(min$,1))
secunit=VAL(RIGHT$(sec$,1))
secten=VAL(LEFT$(sec$,1))

'...construct the time string
s$="IHT IHZ-"       '...start of speech string ("it is" & a pause)

'...get the hour speech string
s$=s$ + t$(hour) + ","              '...1 to 12 {"," is a pause}

'...get the minute speech string     ...0...19,20,30,40,50,60
IF min = 0 THEN                           
  s$=s$ + "OHKLAAK"      '...<something> o'clock
ELSE
  IF minten = 0 AND minunit <> 0 THEN s$=s$ + "OH"
  IF minten = 0 OR minten = 1 THEN
    s$=s$ + t$(min)
  ELSE
     IF minten >= 2 THEN    
        s$=s$ + t$(minten*10)
        IF minunit <> 0 THEN  s$=s$ + t$(minunit)
     END IF
  END IF
END IF


'...get the second speech string     ...0...19,20,30,40,50,60
IF sec <> 0 THEN

 '...add the word "and" & a pause either side
 s$=s$ + "-AXND-"

  IF secten = 0 OR secten = 1 THEN
    s$=s$ + t$(sec) 
  ELSE
      IF secten >= 2 THEN    
        s$=s$ + t$(secten*10) 
        IF secunit <> 0 THEN  s$=s$ + t$(secunit)
      END IF
  END IF
  
  s$=s$ + "-SEHKAAND"       '...add the word "second" or "seconds"
  IF sec > 1 THEN s$=s$ + "Z"     

END IF

SAY s$,v%          '...say it!    s$ = total speech string
 
