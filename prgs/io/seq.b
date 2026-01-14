{ A test of sequential file commands & functions:

	WRITE#
	PRINT#
	INPUT#
	LINE INPUT#
	EOF
}

'..some data
x$="test"
a=12.241
qq=-2221
b%=-32
c&=665533

'...write to file
open "O",1,"ram:test"
  write #1,x$,a,b%,c&
  write #1,qq
close 1

'...read from file
open "I",#2,"ram:test"
 input #2,x$,a,b%,c&,qq
 print x$;a;b%;c&;qq
close #2

for i=1 to 3
  print
  '..append to file
  open "A",3,"ram:test"
    print #3,"HELLO"
  close #3

  '..show modified file
  open "I",4,"ram:test"
  while not eof(4)
   line input #4,x$
   print x$
  wend
  close #4
next

KILL "ram:test"
