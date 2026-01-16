{ ** bc ** 

  Unix-style basic calculator with extras.

  Legal operators: +,-,*,/,^,(,)
        functions: sin(n),cos(n),tan(n),log(n),sqr(n),fix(n),int(n)

  Variables are supported.

  bc uses a recursive descent parser.

  usage: bc [?]

  Author: David Benn
    Date: 21st,22nd March 1992,
  	  26th January 1993 }

'..boolean constants
const true=-1&
const false=0&

'..stack 
const maxstack=100
dim stack(maxstack)
shortint stacktop
stacktop=1

'..functions
const maxfunc=7
dim funcs$(maxfunc)

for i%=1 to maxfunc
  read funcs$(i%)
next

data "SIN","COS","TAN","LOG","SQR","FIX","INT"

'..symbols
const alpha=1
const number=2
const plus=3
const minus=4
const mult=5
const div=6
const pow=7
const lparen=8
const rparen=9
const equal=10
const eos=11
const letsym=12
const undef=13

const maxsym=13
{dim sym.name$(maxsym)
for i%=1 to maxsym
 read sym.name$(i%)
next
data alpha,number,plus,minus,mult,div,pow
data lparen,rparen,equal,eos,letsym,undef}

'..reserved words
const maxword=1
dim word$(1)

for i%=1 to maxword
  read word$(i%)
next

data "LET"

'..errors
longint bad
const DIVBYZERO=1
const SYNTAX=2
const STKOVFL=3
const STKUFL=4

'..globals
shortint n,length
ch$=""
equ$=""
obj$=""
sym=undef

'..variables
dim var(25)

for i%=0 to 25
 var(i%)=0
next
	
'..forward references
declare SUB expr   '...factor will call this

{SUB show.sym(n)
shared sym.name$
  print sym.name$(n)
END SUB}

SUB er(n)
shared bad
  case
    n=DIVBYZERO : print "division by zero"
    n=SYNTAX    : print "syntax error"
    n=STKOVFL	: print "stack overflow"
    n=STKUFL	: print "stack underflow"
  end case
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

SUB rsvd.wd%(x$)
shared word$
shortint n

 for i%=1 to maxword
   if x$ = word$(i%) then n=i%
 next

 if n=0 then rsvd.wd%=alpha else rsvd.wd%=n+eos
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
   sym=rsvd.wd%(obj$)
 else  
   '...unsigned numeric constant
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
       obj$="=" : sym=equal
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
    '..variable
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
    funct=6 : push(fix(pop))
    funct=7 : push(clng(pop))
  end case

  func%=funct
END SUB

SUB factor
shared sym,obj$,bad,var
  if sym=number then 
    push(val(obj$))   '...number
  else
    if sym=lparen then
      insymbol
      if bad then exit sub
      expr
      if sym<>rparen then call er(SYNTAX)
    else  
      '..function or variable
      if func%=0 then call push(var(asc(obj$)-asc("A")))
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
  if sym=undef then call er(SYNTAX)
END SUB

SUB assign_var
shared sym,bad,obj$,var

 '..variable assignment
 insymbol
 if sym<>alpha then call er(SYNTAX):exit sub
 variable$=obj$
 insymbol
 if sym=equal then
   insymbol
   expr
   if bad then 
     exit sub
   else
     var(asc(variable$)-asc("A"))=pop
   end if
 end if
END SUB

SUB parse
shared sym,bad
  insymbol
  if sym=eos then exit sub
  if sym=letsym then 
    assign_var
  else
    expr
    if not bad then print pop
  end if
END SUB

SUB usage
  print
  print "Unix-style basic calculator with extras."
  print
  print "operators: + - * / ^ ( )" 
  print "functions: sin(n) cos(n) tan(n) log(n) sqr(n) fix(n) int(n)"
  print
  print "Variables are also supported. There are 26 variables which"
  print "correspond to the first letter of an identifier (ie: A is the"
  print "same as ALTITUDE)."
  print
  print "bc ignores 'flotsam' at the end of a legal line."
  print 
  print "bc is not case sensitive."
  print 
  print "Examples"
  print "--------"
  print 
  print "    (12+2)*3.5-log(7)"
  print "     47.054088"
  print "    let n=log(10)/log(2)"
  print "    n*2.25"
  print "     7.4743376"
  stop
END SUB

'...main
print "* bc *"
if argcount=1 and arg$(1)="?" then call usage

repeat
  bad=false
  stacktop=1
  ch$=" " 
  n=1
  input ,equ$
  equ$=ucase$(equ$)
  if left$(equ$,1) <> "Q" then
    length=len(equ$)
    parse
  end if
until left$(equ$,1)="Q"
