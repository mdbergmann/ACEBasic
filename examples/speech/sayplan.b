'...Speech Planner (expects Topaz 8 as default system font).

'...Originally written in AmigaBASIC by David Benn (November 1990).
'...Converted to ACE BASIC by David Benn, December 4th 1994.

SCREEN 2,640,200,3,2
WINDOW 2,,(0,0)-(640,200),16,2

PALETTE 0,0,0,0          '...black
PALETTE 1,1,1,1          '...white
PALETTE 2,1,.75,.25      '...red
PALETTE 3,.75,1,.25      '...green
PALETTE 4,.25,.5,1       '...blue
PALETTE 5,0,0,0          '...cursor colour

LOCATE 13,31
COLOR 3,0
PRINT "Please Wait..."

DIM vowel$(12),diphthong$(6),consonant1$(12),consonant2$(13)
DIM special$(11),punct$(7),digit$(9)
DIM phon$(80),phmenu(80)
DIM v%(8),voice$(9)
DIM loval(9),hival(9)

FOR v=0 TO 12
  READ vowel$(v)
  MENU 1,v,1,vowel$(v)
NEXT

FOR d=0 TO 6
  READ diphthong$(d)
  MENU 2,d,1,diphthong$(d)
NEXT

FOR c=0 TO 12
  READ consonant1$(c)
  MENU 3,c,1,consonant1$(c)
NEXT

FOR c=0 TO 13
  READ consonant2$(c)
  MENU 4,c,1,consonant2$(c)
NEXT

FOR s=0 TO 11
  READ special$(s)
  MENU 5,s,1,special$(s)
NEXT

FOR p=0 TO 7 
  READ punct$(p)
  MENU 6,p,1,punct$(p)
NEXT

FOR d=0 TO 9
  READ digit$(d)
  MENU 7,d,1,digit$(d)
NEXT

FOR v=0 TO 9
  READ voice$(v)
  MENU 8,v,1,voice$(v)
NEXT
  
FOR a=0 TO 6
  READ action$
  MENU 9,a,1,action$
NEXT

'...vowels
DATA " V ",IY,EH,AA,AO,ER,AX,IH,AE,AH,UH,OH,IX
'...diphthongs
DATA " DP",EY,OY,OW,AY,AW,UW
'...consonants
DATA " C1 ",R,W,M,NX,S,F,Z,V,CH,"/H",B,D
DATA " C2 ",K,L,Y,N,SH,TH,ZH,DH,J,"/C",P,T,G
'...special symbols
DATA " S ",DX,Q,QX,RX,LX,UL,IL,UM,IM,UN,IN
'...punctuation
DATA " P ",".","?","-",",","(",")",space
'...digits
DATA " D ","1","2","3","4","5","6","7","8","9"
'...speech characteristics
DATA Voice,pitch,inflection,rate,gender,tuning,volume,channel,mode,control
'...actions
DATA Action,"Say",Translate,"Clear","Delete",Help,"Exit"

FOR i=0 TO 8
  READ v%(i)
NEXT
  
'...default speech characteristics
DATA 95,0,140,0,23000,64,10,0,0

FOR j=1 TO 9
  READ loval(j),hival(j)
NEXT

'...lo & hi values for each speech characteristic
DATA 65,320
DATA 0,1
DATA 40,400
DATA 0,1
DATA 5000,28000
DATA 0,64
DATA 0,11
DATA 0,1
DATA 0,2                   
 
s$=""	'...speech string
pc=0    '...phoneme count
lastp=0 '...zero last phoneme  (initially out of range)
HavingFun=-1

GOSUB show
SAY "OHKEY?",v%

ON MENU GOSUB checkmenu  
MENU ON                        '...activate event trapping

WHILE HavingFun
  hue1=RND
  hue2=RND
  hue3=RND
  PALETTE 5,hue1,hue2,hue3 
  time0=TIMER
  WHILE TIMER < time0+.1
  WEND
WEND

checkmenu:
  x=MENU(0)
  y=MENU(1)

  IF LEN(s$)>=80 AND x<8 THEN RETURN    '...speech buffer full!
  
  IF x<>1 THEN x2
  IF y>0 THEN 
    s$=s$+vowel$(y)
    pc=pc+1
    phon$(pc)=vowel$(y)
    phmenu(pc)=x
  END IF  
  GOTO display      
  
  x2:
  IF x<>2 THEN x3
  IF y>0 THEN 
    s$=s$+diphthong$(y)
    pc=pc+1
    phon$(pc)=diphthong$(y)
    phmenu(pc)=x
  END IF  
  GOTO display      
  
  x3:
  IF x<>3 THEN x4
  IF y>0 THEN
    s$=s$+consonant1$(y)
    pc=pc+1
    phon$(pc)=consonant1$(y)
    phmenu(pc)=x
  END IF  
  GOTO display      
  
  x4:
  IF x<>4 THEN x5
  IF y>0 THEN 
    s$=s$+consonant2$(y)
    pc=pc+1
    phon$(pc)=consonant2$(y)
    phmenu(pc)=x
  END IF  
  GOTO display      
  
  x5:
  IF x<>5 THEN x6
  IF y>0 THEN
    s$=s$+special$(y)
    pc=pc+1
    phon$(pc)=special$(y)
    phmenu(pc)=x
  END IF  
  GOTO display      
  
  x6:
  IF x<>6 THEN x7
  IF y=7 THEN 
    s$=s$+" "
    pc=pc+1
    phon$(pc)=" "
    phmenu(pc)=x
    GOTO display
  END IF  
  IF y>0 THEN 
    s$=s$+punct$(y)
    pc=pc+1
    phon$(pc)=punct$(y)
    phmenu(pc)=x
  END IF  
  GOTO display      
  
  x7:
  IF x<>7 THEN x8
  IF y>0 THEN 
    IF phmenu(pc)=1 OR phmenu(pc)=2 AND pc<>0 THEN
      s$=s$+digit$(y)
      pc=pc+1
      phon$(pc)=digit$(y)
      phmenu(pc)=x
    ELSE
      GOSUB badmove
    END IF
  END IF
  GOTO display      
  
  x8:
  IF x<>8 THEN x9
  IF y>0 THEN
    WINDOW 3,"Speech Characteristics",(150,100)-(500,175),0,2
    PRINT
    PRINT"Current ";voice$(y);" =";v%(y-1)
    PRINT
    PRINT"Enter new value..."
    COLOR 3,0
    PRINT"{range:";loval(y);" to";hival(y);"}"
    getvalue:
      INPUT v%(y-1)
      IF v%(y-1) < loval(y) OR v%(y-1) > hival(y) THEN getvalue
    WINDOW CLOSE 3  
    WINDOW OUTPUT 2
    IF s$="" THEN SAY "OHKEY?",v% ELSE SAY s$,v%
  END IF
  RETURN

  x9:
  IF y=1 THEN 
    IF pc<>0 AND s$<>"" THEN 
      SAY s$,v%
    ELSE
      GOSUB badmove
    END IF
  END IF          
  IF y=2 THEN
    WINDOW 3,"Translate text",(1,100)-(640,165),0,2
    COLOR 3,0
    PRINT"Enter ordinary text..." 
    PRINT
    PRINT"> ";
    COLOR 1,0
    INPUT text$
    x$=TRANSLATE$(text$)
    PRINT
    COLOR 2,0
    PRINT x$
    SAY x$,v%
    GOSUB keywait
    WINDOW CLOSE 3
    WINDOW OUTPUT 2
  END IF        
  IF y=3 THEN 
    s$=""
    pc=0                      '...clear string
  END IF  
  IF y=4 AND pc>0 THEN 
    s$=LEFT$(s$,LEN(s$)-LEN(phon$(pc)))  '...delete last
    pc=pc-1
  END IF  
  IF y=5 THEN GOSUB help
  IF y=6 THEN  
       CLS
       MENU CLEAR
       WINDOW CLOSE 2
       SCREEN CLOSE 2      
       STOP
  END IF 

  display:
    GOSUB show

RETURN  


show: 
  CLS 
  LOCATE 3,27
  COLOR 2,0
  PRINT "*** Speech Planner ***"
  LOCATE 8,1
  COLOR 4,0
  PRINT "> ";:COLOR 1,0:PRINT s$;:COLOR 5,0:PRINT "|"
RETURN  


badmove:
 FOR i=1 TO 2
   FOR s=300 TO 500 STEP 30
     SOUND s,1,255,0         '...illegal combination
   NEXT
 NEXT      
RETURN


help:
  WINDOW 3,"Help",(1,17)-(640,185),0,2            
  PRINT
  PRINT "The Speech Planner allows you to experiment with"
  PRINT "speech string construction in two ways:"
  PRINT
  PRINT "          1. By studying the text translation"
  PRINT "             production of phoneme combinations"
  PRINT "             with the Translate option from the"
  PRINT "             Action menu."
  PRINT
  PRINT "          2. By providing access to all Amiga"
  PRINT "             speech phonemes, symbols and voice"
  PRINT "             parameters via pull-down menus."
  PRINT "             Phoneme menus are in the order"
  PRINT "             shown in appendix H of the Amiga"
  PRINT "             BASIC manual."
  PRINT
  PRINT "See sections 8-129 to 8-132 for more details."
  GOSUB keywait
  CLS
  COLOR 1,0
  PRINT 
  PRINT "Pull-Down Menu abbreviations:"
  PRINT
  PRINT "    V  = Vowels"
  PRINT "    DP = Dipthongs"  
  PRINT "    C1 = Consonants"
  PRINT "    C2 = Consonants"  
  PRINT "    S  = Special Symbols"
  PRINT "    P  = Punctuation" 
  PRINT "    D  = Digits"
  GOSUB keywait
  WINDOW CLOSE 3
  WINDOW OUTPUT 2
RETURN  
  

keywait:
  PRINT
  COLOR 3,0
  PRINT"Press any key to continue...";
  WHILE INKEY$=""
  WEND      
RETURN  
