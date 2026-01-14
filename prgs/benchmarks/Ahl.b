{*
** Ahl Benchmark. Taken from a Pascal program in MacTutor magazine, 
** December 1984 as reprinted in MacTech magazine, December 1994.
**
** The values printed by the MacPascal program
** were:
**
**	Time in seconds = 19
**	Accuracy = 0.000000000000005662
**	Random = 1.16641700000e+6
**
** The slow speed (when compared with ACE) can be accounted for by 
** the fact that MacPascal was an interpreter and that the ACE version 
** uses SINGLE rather EXTENDED precision floating point variables. The
** speed of an accelerated A1200 compared to the original Benchmark
** machine might also have something to do with it! :)
*}

SINGLE a,r,s
SHORTINT i,n
SINGLE result1,result2
SINGLE t1,t2

'..Main.
t1 = TIMER

FOR n=1 TO 100
  a = n
  FOR i=1 TO 10
    a = SQR(a)
    r = r+RND
  NEXT

  FOR i=1 TO 10
    a = a*a
    r = r+RND
  NEXT
  
  s = s+a
NEXT
  
result1 = ABS(1010 - s/5)
result2 = ABS(1000 - r)

t2 = TIMER

PRINT "Time in seconds =";t2-t1
PRINT "Accuracy =";result1
PRINT "Random =";result2

END
