{*
** Infix Expression Workbench Calculator.
**
** Uses a recursive descent expression parser.
**
**   Author: David J Benn
**     Date: 13th-15th July 1994,
**	     28th November 1995
** 
** Written in ACE BASIC.
**
** ACEcalc version 2.0 compiled with ACE v2.39.
*}

STRING version SIZE 40 : version = "$VER: ACEcalc 2.0 (28.11.95)"

{*** Expression Parser ***}

{*
** Operators: +,-,*,/,^,(,)
** Functions: exp,sin,cos,tan,log,sqr,int
*}
'..boolean constants
CONST true = -1&, false = 0&

'..stack 
CONST maxstack=100
dim stack(maxstack)
shortint stacktop

'..functions
CONST maxfunc=7
dim funcs$(maxfunc)

for i%=1 to maxfunc
  read funcs$(i%)
next

data "SIN","COS","TAN","LOG","SQR","INT","EXP"

'..symbols
CONST number=1
CONST plus=2
CONST minus=3
CONST mult=4
CONST div=5
CONST pow=6
CONST lparen=7
CONST rparen=8
CONST alpha=9
CONST eos=10
CONST undef=11

CONST maxsym=11

'..errors
longint bad
CONST DIVBYZERO=1
CONST SYNTAX=2
CONST STKOVFL=3
CONST STKUFL=4

'..variables to be shared
ch$=""
equ$=""
obj$=""
sym=undef
SHORTINT n,length
STRING the_expr SIZE 24

'..forward references
declare SUB expr   '...factor will call this

SUB reset_parser
SHARED bad, stacktop, ch$, n
  bad=false
  stacktop=1
  ch$=" " 
  n=1
END SUB

SUB er(n)
shared bad, the_expr
  case
    n=DIVBYZERO : the_expr = "DIVISION BY ZERO"
    n=SYNTAX    : the_expr = "SYNTAX ERROR"
    n=STKOVFL	: the_expr = "STACK OVERFLOW"
    n=STKUFL	: the_expr = "STACK UNDERFLOW" '..OVFL/UFL should NOT happen!
  end case
  '..set error flag
  bad=true
END SUB

SUB nextch
shared ch$,equ$,n,length

  if n<=length then
    ch$=mid$(equ$,n,1)
    ++n
  else
    ch$=""
  end if 
END SUB

SUB insymbol
shared ch$,sym,obj$
shortint periods

 obj$=""
 sym=undef

 '...skip whitespace
 if ch$<=" " and ch$<>"" then
   repeat
     nextch
   until ch$>" " or ch$=""
 end if

 '..end of string?
 if ch$="" then sym=eos:exit sub

 '...characters
 if ch$>="A" and ch$<="Z" then
   while ch$>="A" and ch$<="Z"
     obj$=obj$+ch$   
     nextch 
   wend
   sym=alpha
 else  
   '...unsigned numeric CONSTant
   if (ch$>="0" and ch$<="9") or ch$="." then
     sym=number
     while (ch$>="0" and ch$<="9") or ch$="."
       if ch$="." then ++periods
       obj$=obj$+ch$
       nextch
     wend
     if periods > 1 then 
       sym=undef
       er(SYNTAX)
     end if
   else
     '...single character
     obj$=ch$
     case
       obj$="+" : sym=plus
       obj$="-" : sym=minus
       obj$="*" : sym=mult
       obj$="/" : sym=div
       obj$="^" : sym=pow
       obj$="(" : sym=lparen
       obj$=")" : sym=rparen
     end case

     if sym=undef then call er(SYNTAX)
     nextch
   end if
 end if
END SUB

SUB push(x)
shared stacktop,stack

  if stacktop>maxstack then 
    er(STKOVFL)
  else
    stack(stacktop)=x
    ++stacktop
  end if
END SUB

SUB pop
shared stacktop,stack

  --stacktop
  if stacktop<0 then 
    er(STKUFL) 
  else
    pop=stack(stacktop)
  end if
END SUB

SUB func%
shared funcs$,obj$,sym,bad
longint found
shortint funct

  funct=0

  found=false
  i=1
  while i<=maxfunc and not found
    if funcs$(i) = obj$ then funct=i:found=true else ++i
  wend
 
  if funct then 
    '..function
    fun$=funcs$(funct)
  else
    func%=0
    exit sub
  end if

  '...push the argument
  if funct then
    insymbol
    if bad then func%=0:exit sub
    if sym<>lparen then 
      er(SYNTAX)
    else
      insymbol
      if bad then func%=0:exit sub
      expr
      if sym<>rparen then call er(SYNTAX):funct=0
    end if
  end if

  '...which function?
  case
    funct=1 : push(sin(pop))
    funct=2 : push(cos(pop))
    funct=3 : push(tan(pop))
    funct=4 : push(log(pop))
    funct=5 : push(sqr(pop))
    funct=6 : push(clng(pop))
    funct=7 : push(exp(pop))
  end case

  func%=funct
END SUB

SUB factor
shared sym,obj$,bad
  if sym=number then 
    push(val(obj$))   '...number
  else
    '..(expr)
    if sym=lparen then
      insymbol
      if bad then exit sub
      expr
      if sym<>rparen then call er(SYNTAX)
    else  
      '..function?
      if sym=alpha then
        if func%=0 then call er(SYNTAX)
      else
	'..undefined
        er(SYNTAX)
      end if
    end if
  end if
  insymbol
END SUB

SUB expterm
shared sym,bad
  factor
  while sym=pow
    insymbol
    if bad then exit sub
    factor
    op2=pop
    op1=pop
    push(op1^op2)
  wend
END SUB

SUB negterm
shared sym,bad
longint negate
  negate=false
  if sym=minus then negate=true:insymbol:if bad then exit sub 
  if sym=plus then call insymbol:if bad then exit sub
  expterm
  if negate then call push(-pop)  
END SUB
 
SUB term
shared sym,bad
shortint op
  negterm
  while sym=mult or sym=div
    op=sym
    insymbol
    if bad then exit sub
    negterm
    op2=pop
    op1=pop
    if op=mult then
      push(op1*op2)
    else
      if op2<>0 then 
        push(op1/op2) 
      else 
        er(DIVBYZERO)
      end if
    end if
  wend
END SUB
 
SUB expr
shared sym,bad
  term
  while sym=plus or sym=minus
    op=sym
    insymbol
    if bad then exit sub
    term
    op2=pop
    op1=pop
    if op=plus then
      push(op1+op2)
    else
      push(op1-op2) 
    end if
  wend  
END SUB

SUB parse(expr$)
shared sym, equ$, length, n
  reset_parser
  equ$ = UCASE$(expr$)
  length = LEN(equ$)
  insymbol
  if sym=eos then exit sub
  expr
  if sym<>eos then call er(SYNTAX)
END SUB

{* ---oOo--- *}

{*** Calculator ***}

{*
** General CONSTant declarations.
*}
CONST hell_freezes_over = false
CONST MAXKEY = 30
CONST MAXCHARS = 23

{*
** Menu CONSTant declarations.
*}
CONST mProject = 1
CONST iAbout = 1
CONST iQuit = 2


{*
** Global variable declarations.
*}
STRING store SIZE 24
STRING buttonFont SIZE 11:buttonFont = "topaz.font"
SINGLE result
DIM key$(MAXKEY)


{*
** Subprogram declarations.
*}
SUB PlotKeys
SHARED key$, buttonFont
STRING k$ SIZE 4
LONGINT n,xoffset

  '..top row
  FOR n=1& to 5&
    READ k$
    key$(n) = k$
    xoffset = (n-1&)*40&
    GADGET n,ON,k$,(5&+xoffset,25&)-(35&+xoffset,37&),BUTTON,,buttonFont,8,0
  NEXT

  '..2nd row
  FOR n=10& to 6& STEP -1
    READ k$
    key$(n) = k$
    xoffset = (n-6&)*40& 
    GADGET n,ON,k$,(5&+xoffset,40&)-(35&+xoffset,52&),BUTTON,,buttonFont,8,0
  NEXT

  '..3rd row
  FOR n=11& to 15&
    READ k$
    key$(n) = k$
    xoffset = (n-11&)*40&
    GADGET n,ON,k$,(5&+xoffset,55&)-(35&+xoffset,67&),BUTTON,,buttonFont,8,0
  NEXT

  '..4th row
  FOR n=20& to 16& STEP -1
    READ k$
    key$(n) = k$
    xoffset = (n-16&)*40&
    GADGET n,ON,k$,(5&+xoffset,70&)-(35&+xoffset,82&),BUTTON,,buttonFont,8,0
  NEXT

  '..5th row
  FOR n=21& to 25&
    READ k$
    key$(n) = k$
    xoffset = (n-21&)*40&
    GADGET n,ON,k$,(5&+xoffset,85&)-(35&+xoffset,97&),BUTTON,,buttonFont,8,0
  NEXT

  '..6th row
  FOR n=30& to 26& STEP -1
    READ k$
    key$(n) = k$
    xoffset = (n-26&)*40&
    GADGET n,ON,k$,(5&+xoffset,100&)-(35&+xoffset,112&),BUTTON,,buttonFont,8,0
  NEXT

  '..key data
  DATA "7","8","9","(",")"		'..top row
  DATA "-","+","6","5","4"		'..2nd row
  DATA "1","2","3","*","/"		'..3rd row
  DATA "«-","^","=",".","0"		'..4th row
  DATA "CLR","STO","RCL","INT","EXP"	'..5th row
  DATA "SQR","LOG","TAN","COS","SIN"	'..6th row
END SUB

SUB SetUpMenus
  '..Project menu
  MENU mProject,0,1,"Project"
  MENU mProject,iAbout,1, 	"About..." 
  MENU mProject,iQuit,1,  	"Quit          ","Q"
END SUB

SUB update_display
SHARED the_expr
{*
** Update expression display.
*}
  LINE (7,5)-(192,17),0,bf
  LOCATE 2,2
  PRINT the_expr;
END SUB

SUB operation(key_num)
SHARED key$, the_expr, store
SHARED result, bad, length
{*
** Act upon selected key.
*}

  IF bad THEN
    '..Recover from recent error by
    '..resetting parser and calculator.
    reset_parser
    the_expr = ""
    update_display
  END IF

  IF key$(key_num) = "=" THEN
    '..Compute result
    IF the_expr <> "" THEN
      parse(the_expr)
      IF NOT bad THEN 
        result = pop
        the_expr = STR$(result)
      END IF
      IF LEFT$(the_expr,1) = " " THEN the_expr = MID$(the_expr,2)
      update_display
    END IF
    EXIT SUB
  END IF

  IF key$(key_num) = "STO" THEN
    '..Store current expression
    store = the_expr
    EXIT SUB
  END IF

  IF key$(key_num) = "RCL" THEN
    '..Recall stored expression
    IF LEN(the_expr)+LEN(store) <= MAXCHARS THEN the_expr = the_expr+store
    update_display
    EXIT SUB
  END IF

  IF key$(key_num) = "CLR" THEN 
    '..Clear expression
    the_expr = ""
    update_display
    EXIT SUB
  END IF

  IF key$(key_num) = "«-" THEN
    '..Remove right-most character
    the_expr = LEFT$(the_expr,LEN(the_expr)-1)
    update_display
    EXIT SUB
  END IF
  
  '..For all other keys -> Update expression
  IF LEN(the_expr)+LEN(key$(key_num)) <= MAXCHARS THEN 
    the_expr = the_expr+key$(key_num)
    update_display
  END IF
END SUB

SUB check_for_keypress(k$)
SHARED key$
SHORTINT n
{*
** Has a physical key been pressed?
*}
  IF k$<>"" THEN
    '..Was the return/enter key pressed?
    '..(treat as "equal" key)
    IF k$=CHR$(13) THEN k$ = "="

    '..Was the destructive backspace
    '..or DEL key pressed?
    IF k$=CHR$(8) OR k$=CHR$(127) THEN k$ = "«-"

    '..Is it a calculator key?
    FOR n=1 to MAXKEY
      IF k$ = key$(n) THEN EXIT FOR
    NEXT

    '..Act on it!
    IF n>=1 AND n<=MAXKEY THEN CALL operation(n)
  END IF
END SUB

SUB service_menu(x,y)
  IF x = mProject THEN
    IF y = iAbout THEN 
      	MsgBox "Copyright © David Benn, 1994-1995","Continue"
	EXIT SUB	 
    END IF

    IF y = iQuit THEN GOSUB quit
  END IF
END SUB


{*
** Main program.
*}
WINDOW 1,"ACEcalc v2.0",(220,75)-(428,205),30

BEVELBOX (5,4)-(194,18),2

FONT "topaz",8
STYLE 2	'..bold

PlotKeys 
SetUpMenus

ON WINDOW GOSUB quit
ON GADGET GOSUB handle_gadget
ON MENU GOSUB handle_menu

WINDOW ON
GADGET ON
MENU ON

REPEAT
  SLEEP
  check_for_keypress(INKEY$)
UNTIL hell_freezes_over

{* ---oOo--- *}


{* 
** Event handlers.
*}
handle_gadget:
  operation(GADGET(1))
RETURN

handle_menu:
  service_menu(MENU(0),MENU(1))
RETURN

quit:
  '..Clean up and exit.
  MENU CLEAR 
  FOR i=1 to MAXKEY
    GADGET CLOSE i
  NEXT
  WINDOW CLOSE 1
END
