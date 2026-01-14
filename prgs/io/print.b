{ ** Send a file to the printer **

  If the program is started from the shell,
  the file name is taken to be the first
  argument. Likewise if the program is
  WorkBench launched. Otherwise the 
  program invokes a file requester. 

  If the requested file doesn't exist 
  the program quits with a beep.

  Page size can also be specified.

  Compile thus: bas -O print ACE:SUBmods/WBarg/WBarg.o
}

#include <SUBmods/WBarg.h>

DEFINT a-z

page_size=0

SUB usage
  print "usage: ";arg$(0);" ? | [<filename>][page-size]"
END SUB

'..get the filename
if WBargcount=1 then
  '..Workbench args
  x$ = WBargPath$(1) + WBarg$(1)
else
  if argcount > 0 then
    '..CLI/shell args
    if argcount = 1 then
       x$ = arg$(1)
       if x$ = "?" then 
          usage
          stop
       end if
    else
      if argcount = 2 then 
	 x$ = arg$(1)
	 page_size = val(arg$(2)) 
      else
	 '..too many args
         usage
	 stop
      end if
    end if
  else
    '..no args
    x$ = FileBox$("Select file to print")
  end if
end if

'..print the file
open "I",1,x$

if handle(1)=0 then beep:stop  '..doesn't exist.

open "O",2,"PRT:"
ln$=""
count=0
while not eof(1)
 line input #1,ln$
 print #2,ln$
 ++count
 if page_size > 0 and count = page_size then 
    count=0
    print #2,chr$(12)  '..form feed
 end if
wend

close 1,2
