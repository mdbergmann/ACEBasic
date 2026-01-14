'..Test of ACE messaging functions: reader.

string buffer
msg$="Hello from reader!"

window 1,"Reader",(0,100)-(640,200),0

font "topaz",8
locate 1,1

'..create a port for this program called "reader"
message open #1,"reader","r"
if err=400 then 
  print "can't create a message port!"
  goto quit
end if

'..read a message from writer by polling.
repeat
  print "polling..."
  message read #1,buffer
  sleep for .1
until buffer<>""

if err<>402 then print "READER <- WRITER: ";buffer


'..reply to writer.
repeat
  print "waiting for creation of port called 'writer'."
  message open #2,"writer","w"
  sleep for .1
until err<>400
 
message write #2,msg$

if err<>403 then
  print "READER -> WRITER: ";msg$
  message wait #2	
  PRINT "*** ACK received from writer."
end if

quit:
print
print "Press a key..."
while inkey$="":sleep:wend
message close #1
message close #2
window close 1
END
