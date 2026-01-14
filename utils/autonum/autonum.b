{*
** - This program produces a paged and line-numbered document
**   for ACE.DOC format files.
**
** Author: David J Benn
**   Date: 4th,10th,11th,14th,15th January 1994,
**	  30th July 1994,
**	  3rd October 1994
*}

DEFINT a-z

CONST MAX=100,STARTCOL=45,NUMSIZE=4

pagelen=62

DIM content(MAX),page(MAX),section(MAX)

if argcount<>2 and argcount<>3 then
  print "usage: ";arg$(0);" source target [page-length (default=62)]"
  print "   eg: ";arg$(0);" ace.fmt ace.doc" 
  print "       ";arg$(0);" ace.fmt ace.doc 59" 
  stop
end if

open "I",1,arg$(1)

if handle(1)=0& then 
  print "Input file error!"
  stop
end if

open "O",2,arg$(2)

if handle(2)=0& then 
  print "Output file error!"
  close #1
  stop
end if

on break goto quit
break on

print "Paginating ";arg$(1);"..."

open "O",#3,"tmp.doc"

if argcount=3 then pagelen=val(arg$(3))

linecount=0
pagecount=1

'..paginate
while not eof(1)
  line input #1,x$
  print #3,x$
  ++linecount
  if linecount = pagelen then
    print #3," "
    print #3,SPC(34);"- page";pagecount;"-"
    print #3," "
    print "Page";pagecount
    ++pagecount
    linecount=1
  end if
wend

'..need to finish off last page?
if linecount < pagelen then
   for i=linecount to pagelen
     print #3," "
   next
   print #3,SPC(34);"- page";pagecount;"-"
   print "Page";pagecount
end if

close 1,3

print "Looking for section references..."
open "I",1,"tmp.doc"
line_num=0
linecount=0
pagecount=1
refs=0
x$=""
while not eof(1) and instr(x$,"==")=0
  print "-->";line_num
  line input #1,x$
  ++line_num
  ++linecount
  if linecount = pagelen+3 then
     ++pagecount
     linecount=1
  end if
  if instr(STARTCOL,x$,"%%") then 
    content(refs) = line_num
    ++refs
  end if
wend
print "Number of section references found:";refs

print "Looking for sections..."
count=0
while not eof(1) 
  line input #1,x$
  ++line_num
  ++linecount
  if linecount = pagelen+3 then
     ++pagecount
     linecount=1
  end if
  if instr(x$,"$$") then
    section(count) = line_num
    page(count) = pagecount
    ++count
    print "Line";line_num;"= ";mid$(x$,3)
  end if  
wend
close #1

print "Creating ";arg$(2);"..."
open "I",1,"tmp.doc"
linecount=0
count=0
while not eof(1)
  line input #1,x$
  if x$="" then x$=" " '..prevent raw EOS being sent to file! (ACE silliness)
  ++linecount
  print "Line";linecount
  '..contents page entry?
  if content(count) = linecount then
    linenum$=mid$(str$(section(count)),2)
    while len(linenum$) < NUMSIZE
      linenum$ = "."+linenum$
    wend
    y$=mid$(x$,1,instr(STARTCOL,x$,"%%")-1)+linenum$
    pg$=str$(page(count))
    y$=y$+space$(6-len(pg$))+pg$
    print #2,y$
    print "Section: ";y$
    ++count
  else
    '..new section?
    if instr(x$,"$$") then
      section_heading$=mid$(x$,3)
      print #2,section_heading$
      print section_heading$
    else
      '..other line
      print #2,x$
    end if
  end if
wend

quit:
close 1,2,3
