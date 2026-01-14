'..Prints a document, throwing paper to the top-of-form
'..each time "- page" is encountered. The latter is
'..produced by autonum.b and found in ace.doc.

input "Print which file";x$
input "Name of print device [PRT:]";dev$

if dev$="" then dev$="PRT:"

open "I",1,x$

if ERR then 
   print"Can't open file!"
   stop
end if

open "O",2,dev$

if ERR then 
   print"Can't open printer device!"
   stop
end if

ON BREAK goto quit
BREAK ON

while not eof(1)
 line input #1,ln$
 print #2,ln$
 '..form feed?
 if instr(ln$,"- page") then 
    print #2,chr$(12)  
 end if
wend

quit:
close 1,2
