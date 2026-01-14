{*
** A Time/Date/Day Server.
** 
** Author: David J Benn
**   Date: 31st August 1994,
**	   1st September 1994
*}

CONST serving = -1&
CONST default = -1&

DECLARE SUB quit

'..set up days
DIM the_day$(6)
for i=0 to 6
  read the_day$(i)
next
DATA Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday

window 1,"Time/Date Server [press Q to quit]",(0,0)-(640,75),7

'..create the server's port.
message open #1,"time server","r"
if err=400 then
  print "Unable to create message port for server!"
  quit
end if

WHILE serving
  '..await a request from a client.
  repeat
    locate 1,1
    print "Date: ";date$
    locate 2,1
    print "Time: ";time$
    if UCASE$(inkey$)="Q" then call quit
    message read #1,request$
    sleep for .1
  until err<>402

  '..decode message.
  client$ = LEFT$(request$,INSTR(request$,"/")-1)
  reqtype$ = MID$(request$,INSTR(request$,"/")+1)
  cls
  locate 4,1
  print "Received request for ";reqtype$;" from ";ucase$(client$);"."

  '..build reply.
  reqtype$ = UCASE$(reqtype$)
  reply$ = ""

  CASE
    reqtype$ = "DATE" : reply$ = date$
    reqtype$ = "TIME" : reply$ = time$
    reqtype$ = "DAY"  : the_date$ = date$:reply$ = the_day$(day)
    reqtype$ = "HELP" : reply$ = "Commands: DATE TIME DAY HELP"
    default  	      : reply$ = "'"+reqtype$+"': unknown command."
  END CASE

  '..open a channel to the client.
  message open #2,client$,"w"
  if err = 400 then
    print "Unable to connect to ";client$;"."
  else
    '..send reply to client.
    message write #2,reply$

    '..wait for client to receive message.
    if err = 403 then 
      print "Error while writing to ";client$;"."
    else
      message wait #2	
    end if
    '..close channel to the client.
    message close #2
  end if
WEND

SUB quit
  CLS
  print "*** Server terminating..."
  sleep for .75
  message close #1
  message close #2
  window close 1
  STOP
END SUB

END
