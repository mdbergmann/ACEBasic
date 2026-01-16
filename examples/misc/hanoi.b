'...recursive towers of hanoi player

defint N,goal,s,moves

sub show.moves(N,start,goal,spare)
  if n=1 then
    print "Move a ring from";start;"to";goal
  else
    show.moves(n-1,start,spare,goal)
    print "Move a ring from";start;"to";goal
    show.moves(n-1,spare,goal,start)
  end if
end sub

cls
repeat
 input "Enter number of rings (1 or higher)... ",N 
until N>=1
print "To move";N;
if N=1 then 
  print "ring"; 
else 
  print "rings"; 
end if
print " from peg 1 to peg 2:"
print 
show.moves(N,1,2,3)
moves=2^n-1
print:print"It takes";moves;
if moves=1 then print "move." else print "moves."
