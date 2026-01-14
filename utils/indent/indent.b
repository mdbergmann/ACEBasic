' ACE Basic Indenter
' Version 1.0 by Roland Acton - August 1994
' Internet address: xracton@ccvax.fullerton.edu

' This program is public domain. You may use any part of it you
' wish in a program of your own. Please credit me if you do so.

declare sub shortint ParseCommandLine

declare function AllocMem& library exec
declare function FreeMem& library exec
declare function _Open& library dos
declare function _Close& library dos
declare function _Read& library dos
declare function _Write& library dos

' Change this constant if you want more (or less) indentation.

const indentamount=2

longint srcfilehandle,destfilehandle

shortint indent,bufferpos,buffercount
longint bufferstart,fileline
shortint linepos
longint spacebuffer
shortint z
longint counter,indentskip
shortint keywordcount
longint keywordpointer
shortint foundkeyword,x
longint linepointer
shortint pclsuccess,doweindent
string a$,keyword$
longint longcoerce

library exec
library dos
print "Indenter for ACE Basic"
print "Version 1.0 by Roland Acton - August 1994"
print
pclsuccess=ParseCommandLine()
if pclsuccess=1% then
  bufferstart=AllocMem(256&,0&)
  fileline=AllocMem(256&,0&)
  spacebuffer=AllocMem(256&,0&)

' Strictly speaking, I should check to see if the memory allocation
' fails, but if the system is that low on memory it's going to fail
' for other reasons in short order.

  for counter=spacebuffer to spacebuffer+252& step 4
    pokel counter,&H20202020
  next
  buffercount=_Read(srcfilehandle,bufferstart,256&)
  bufferpos=0%
  indent=0%

  data "ASSEM","CASE","FOR","IF","ELSEIF","REPEAT","STRUCT"
  data "SUB","WHILE"
  data "ELSE"
  data "ENDASSEM","ENDCASE","NEXT","ENDIF","UNTIL","ENDSTRUCT"
  data "ENDSUB","WEND"
  const maxkeywords=18,postrange=10,prerange=10

  longcoerce=varptr(keyword$)
  x=0%
  repeat
    read a$
    for z=1% to len(a$)
      poke longcoerce,asc(mid$(a$,z,1))
      ++longcoerce
    next
    poke longcoerce,0%
    ++longcoerce
    ++x
  until x=maxkeywords

' The section of code below is an internal buffering system. It
' pulls in 256 bytes at a time from the source file and extracts
' lines of source code from them.

  mainloop:
  linepos=0%
  repeat
    z=peek(bufferstart+bufferpos)
    poke fileline+linepos,z
    ++bufferpos
    ++linepos
    if bufferpos=buffercount then
      buffercount=_Read(srcfilehandle,bufferstart,256&)
      bufferpos=0%
    end if
  until z=10% or buffercount=0% or linepos=256%

' It's assumed that no line will be larger than 256 bytes. The extra
' condition above is just to stop the program from crashing if it's
' accidentally run on a binary file.

  for indentskip=fileline to fileline+linepos-1%
    z=peek(indentskip)
    if z<>32% then
      exit for
    end if
  next
  linepos=fileline+linepos-indentskip

' The section of code above is designed to skip any indentation that
' already exists.

' Now we have to determine which keyword, if any, the line begins
' with. We skip over spaces and convert alphabetic characters to
' uppercase.

  keywordcount=1%
  keywordpointer=varptr(keyword$)
  repeat
    linepointer=indentskip
    foundkeyword=1%
    repeat
      z=peek(linepointer)
      while z=32%
        ++linepointer
        z=peek(linepointer)
      wend
      if z>=97% and z<=122% then
        z=z-32%
      end if
      x=peek(keywordpointer)
      if z<>x and x<>0% then
        foundkeyword=0%
      end if
      ++linepointer
      ++keywordpointer
    until x=0%
    if foundkeyword=1% then
      goto keybreak
    end if
    ++keywordcount
  until keywordcount>maxkeywords

' If the line started with a valid keyword, its number is in
' keywordcount.

  keybreak:

' Check for one of the pre-output indent changers.

  if keywordcount>=prerange and keywordcount<=maxkeywords then
    indent=indent-indentamount
    if indent<0% then
      indent=0%
    end if
  end if

' If this is a comment line, or is blank, we do not indent it at
' all.

  a$=chr$(peek(indentskip))+chr$(peek(indentskip+1))+chr$(peek(indentskip+2))
  if left$(a$,1%)="'" or ucase$(a$)="REM" then
    doweindent=0%
  else
    doweindent=1%
  end if

' Output the line.

  if linepos>1% and doweindent=1% then
    longcoerce=indent
    _Write(destfilehandle,spacebuffer,longcoerce)
  end if
  longcoerce=linepos
  _Write(destfilehandle,indentskip,longcoerce)

' Check for one of the post-output indent changers.

  if keywordcount<=postrange then
    indent=indent+indentamount
  end if

' If there's still something left in the input buffer, we go back to
' get the next line.

  if buffercount>0% then
    goto mainloop
  end if
  FreeMem(bufferstart,256&)
  FreeMem(fileline,256&)
  FreeMem(spacebuffer,256&)
  _Close(srcfilehandle)
  _Close(destfilehandle)
end if
library close exec
library close dos



sub shortint ParseCommandLine
  shared srcfilehandle,destfilehandle

  if argcount<>2 then
    print "Error in command line"
    print "Syntax: IndentACE <source-file> <destination-file>"
    parsecommandline=0%
  else
    srcfilehandle=_Open(arg$(1),1005&)
    if srcfilehandle>0& then
      destfilehandle=_Open(arg$(2),1006&)
      if destfilehandle>0& then
        parsecommandline=1%
      else
        _Close(srcfilehandle)
        print "Couldn't open file ";arg$(2)
        parsecommandline=0%
      end if
    else
      print "Couldn't open file ";arg$(1)
      parsecommandline=0%
    end if
  end if
end sub
