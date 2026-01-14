'..Display an IFF picture on an appropriate screen.

SUB cleanup
  screen close 1
  iff close #1
END SUB

f$ = FileBox$("Select an IFF file")
if f$="" then stop

iff open #1,f$

if Err <> 0 then 
  MsgBox f$+" is not an IFF file.","Continue"
  stop
end if

'print iff(1,1),iff(1,2),iff(1,3),iff(1,4)

screen 1,iff(1,1),iff(1,2),iff(1,3),iff(1,4)

if Err then 
  MsgBox "Unable to open screen.","Continue"
  iff close #1
else
  iff read #1,1
  if Err then 
    MsgBox "Error reading "+f$+".","Continue"
    cleanup
  else
    while inkey$="" and NOT mouse(0):sleep:wend
    cleanup
  end if
end if
