rem $EVENT OFF
rem $option n-o-a-x-

rem Modified for ACE BASIC, 27.03.1993 (occurrences of t! changed to t)

print "All the old PCW Benchmarks..."

dim times(8)	' to hold the times

   t=timer
   FOR K=1 TO 10000
   NEXT K
   t=timer-t:times(1)=t


   t=timer
   K=0
z1:
   K=K+1
 IF K<10000 THEN GOTO z1
  
   t=timer-t:times(2)=t

 t=timer
   K=0
z2:
 K=K+1
 A=(k/k)*k+K-K
    IF K<10000 THEN GOTO z2
   t=timer-t:times(3)=t

   t=timer
   K=0
z3:
 K=K+1
 A=K/2*3+4-5
    IF K<10000 THEN GOTO z3
   t=timer-t:times(4)=t

   t=timer
   K=0
z4:
	 K=K+1
	 A=K/2*3+4-5
    GOSUB s4
    IF K<10000 THEN GOTO z4
    t=timer-t:times(5)=t
	goto skip1
s4:
	 RETURN
skip1:

    t=timer
    K=0
    DIM M(5)
z5:
	K=K+1
    A=K/2*3+4-5
    GOSUB s3
    FOR L=1 TO 5
    NEXT L
	 IF K<10000 THEN GOTO z5
    t=timer-t:times(6)=t
    goto  skip2
s3:
	 RETURN

skip2:
    t=timer
    K=0
    DIM M1(5)
z6:
	 K=K+1
    A=K/2*3+4-5
    GOSUB s6
    FOR L=1 TO 5
    M1(L)=A
	NEXT L
    IF K<10000 THEN GOTO z6
    t=timer-t:times(7)=t
	
goto skip3

s6:
 RETURN

skip3:
	t=timer
	K=0
z7:	K=K+1
	A=K^2
	B=LOG(K)
	C=SIN(K)
	IF K<10000 THEN GOTO z7
   t=timer-t:times(8)=t

t=0
for i%=1 to 8
print "PCW";i%,times(i%)/10
t=t+times(i%)
next i%
print "Average=";t/80

