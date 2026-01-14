'..show differences between two files.

deflng a-z

if argcount<>2 then 
  print "usage: ";arg$(0);" <file1> <file2>"
  stop
end if

open "I",#1,arg$(1)
open "I",#2,arg$(2)

count=0

on break goto _exit
break on

while not eof(1) and not eof(2)
  line input #1,x$  
  line input #2,y$
  if x$<>y$ then 
    print "1: ";x$
    print "2: ";y$
    ++count
  end if   
wend

_exit:
  print

  if count=1 then 
    print " 1 difference found."
  else
    print count;"differences found."
  end if

close 1,2
