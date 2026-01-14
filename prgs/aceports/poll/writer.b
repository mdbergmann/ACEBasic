'..Test of ACE messaging functions: writer.

string buffer
msg$="Hello from writer!"

window 1,"Writer",(0,0)-(640,100),0

font "topaz",8
locate 1,1

'..write a message to reader.
repeat
  print "waiting for creation of port called 'reader'."
  message open #1,"reader","w"
  sleep for .1
until err<>400

message write #1,msg$

if err<>403 then 
  print "WRITER -> READER: ";msg$ 
  message wait #1
  PRINT "*** ACK received from reader."
end if


'..create a port for this program called "writer"
message open #2,"writer","R"
if err=400 then 
  print "can't create a message port!"
  goto quit
end if

'..receive a message from reader by polling.
repeat
  print "polling..."
  message read #2,buffer
  sleep for .1
until buffer<>""

if ERR<>402 then print "WRITER <- READER: ";buffer

quit:
print
print "Press a key..."
while inkey$="":sleep:wend
message close #1
message close #2
window close 1
END
