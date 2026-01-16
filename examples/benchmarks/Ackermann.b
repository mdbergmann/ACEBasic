'..Ackermann's function benchmark.
'..It's also a good test of recursion.

defint a,j,m,n,v

sub Ackermann(m,n)
 if m=0 then 
   Ackermann=n+1
   exit sub
 else
   if n=0 then 
     Ackermann(m-1,1)
   else
     Ackermann(m-1,Ackermann(m,n-1))
   end if
 end if
end sub

'...main
k=16
k1=1
for n=1 to 2
 t1=timer
 j=Ackermann(3,n)
 t2=timer
 print j
 if j<>k-3 then print "wrong value -> should be:";k-3
 print "Net CPU time for Ackermann( 3 ,";n;") is";t2-t1;"seconds."
 Num.calls!=(512*k1-15*k+9*n+37)/3
 print "CPU time per call";(t2-t1)/num.calls!;"seconds."
 k1=4*k1
 k=2*k
next
