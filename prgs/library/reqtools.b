REM An example of using reqtools.library functions.
REM (reqtools.library must be in your LIBS: directory
REM for this program to work). ReqTools.bmap is also
REM required and has been supplied in ACEbmaps:.

#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfx.h>
#include <libraries/reqtools.h> 
#include <funcs/reqtools_funcs.h>

LIBRARY "reqtools.library"

DECLARE STRUCT rtReqInfo *myreq
DECLARE STRUCT rtFileRequester *filereq

REM Message Requester
myreq = rtAllocRequestA(RT_REQINFO,NULL)
dummy$ = "This is a really"+CHR$(10)
dummy$ = dummy$ + "neat message"+CHR$(10)
dummy$ = dummy$ + "requester!"
button$="Sure|Perhaps|No way"
ret = rtEZRequestA(dummy$,button$,NULL,NULL,NULL)
rtFreeRequest(myreq)

REM File Requester
STRING fileBuffer, theDir
filereq = rtAllocRequestA(RT_FILEREQ,NULL)
ok = rtFileRequestA(filereq,fileBuffer,NULL,NULL)
rtFreeRequest(filereq)
theDir = CSTR(filereq->Dir)
IF theDir <> "" AND RIGHT$(theDir,1) <> ":" THEN theDir = theDir+"/"
IF ok THEN 
  print "You chose: ";theDir;fileBuffer
ELSE
  print "Requester cancelled."
END IF

LIBRARY CLOSE
