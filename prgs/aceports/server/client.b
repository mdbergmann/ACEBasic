{*
** Client for Time/Date/Day Server.
**
** Author: David J Benn
**   Date: 31st August 1994,
**	   1st September 1994
*}

LIBRARY "exec.library"

CONST requesting = -1&

DECLARE FUNCTION FindTask&(taskname$) LIBRARY exec 
DECLARE SUB quit

window 1,"Type QUIT to exit",(0,100)-(250,200),7

'..open a channel to the server.
message open #1,"time server","w"
if err = 400 then 
  print "Unable to connect to server."
  print 
  print "Press a key..."
  while inkey$="":sleep:wend
  quit
end if

'..create a reply port for this client based upon process ID.
client$ = "Client"+str$(FindTask(0))
message open #2,client$,"r"
if err = 400 then 
  print "Unable to open a reply port."
  quit
end if

print client$;" ready."

WHILE requesting
  '..get a client request.
  input "> ",request$
  request$ = UCASE$(request$)
  if request$ <> "QUIT" then
    message write #1,client$+"/"+request$
  else
    quit
  end if

  '..wait for server to receive request.
  if err=403 then
    print "Error writing to server!"
    quit
  else
    message wait #1
  end if

  '..await server's reply.  
  message wait #2
  message read #2,info$
  if ERR<>402 then print info$
WEND

SUB quit
  print "*** Client terminating..."
  sleep for .75
  message close #1
  message close #2
  window close 1
  STOP
END SUB

END
